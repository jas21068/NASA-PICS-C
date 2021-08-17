//
//  ViewController.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import UIKit
import SDWebImage

class ImageFeedViewController: UIViewController {

    @IBOutlet weak var tablev: UITableView!
    
    private var loader = UIActivityIndicatorView()
    private var items = [APOD]()
    private var selectedIndex = -1
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    private func setup(){
        self.tablev.delegate = self
        self.tablev.dataSource = self
        self.tablev.reloadData()
        self.tablev.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(_getData), for: .touchUpInside)
        loader.frame = self.view.frame
        self.getData()
    }
    
    @objc private func _getData(){
        Networking.shared.getData(objectType: [APOD].self) { (result) in
            DispatchQueue.main.async {
            self.tablev.refreshControl?.endRefreshing()
                switch result {
                    case .success(let object):
                        self.items = object
                        self.items.removeAll(where: {$0.mediaType == "video"})
                        DispatchQueue.main.async {
                            self.tablev.reloadData()
                        }
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription) { (_) in }
                }
            }
        }
    }
    
    private func getData(){
        self.showLoader()
        Networking.shared.getData(objectType: [APOD].self) { (result) in
            DispatchQueue.main.async {
                self.hideLoader()
                switch result {
                    case .success(let object):
                        self.items = object
                        self.items.removeAll(where: {$0.mediaType == "video"})
                        DispatchQueue.main.async {
                            self.tablev.reloadData()
                        }
                    case .failure(let error):
                        self.showAlert(title: "Error", message: error.localizedDescription) { (_) in }
                }
            }
        }
    }
    
    private func showLoader(){
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.loader.startAnimating()
            self.view.addSubview(self.loader)
            self.view.bringSubviewToFront(self.loader)
        }
    }
    
    private func hideLoader(){
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.loader.stopAnimating()
            self.loader.removeFromSuperview()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next"{
            let vc = segue.destination as! ImageDisplayViewController
            vc.imageTitle = self.items[selectedIndex].title ?? ""
            vc.url = self.items[selectedIndex].url ?? ""
        }
    }

}

extension ImageFeedViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tablev.dequeueReusableCell(withIdentifier: "feedCell") as! FeedTableViewCell
        cell.fav.tag = indexPath.section
        cell.fav.addTarget(self, action: #selector(saveToFavourite(sender:)), for: .touchUpInside)
        let url = self.items[indexPath.section].url ?? ""
        cell.img.sd_setImage(with: URL(string: url), placeholderImage: UIImage(), options: .highPriority) { (_, _, _, _) in }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath.section
        self.performSegue(withIdentifier: "next", sender: nil)
    }
    
    @objc func saveToFavourite(sender: UIButton){
        let apod = self.items[sender.tag]
        self.showLoader()
        self.downloadImage(link: apod.url ?? "") { (path) in
            DispatchQueue.main.async {
                self.hideLoader()
            }
            if let path = path{
                CoreDataManager.shared.saveToFav(apod: apod, imagePath: path) { (error) in
                    if let error = error{
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: error) { (_) in }
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.showAlert(title: "Success", message: "Image saved to favourites") { (_) in }
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Something went wrong wile downloading the image") { (_) in }
                }
            }
        }
    }
    
    private func downloadImage(link: String, completion: @escaping (String?) -> ()) {
        if let url = URL(string: link){
            let img = UIImageView()
            img.sd_setImage(with: url, placeholderImage: UIImage(), options: .highPriority) { (image, error, _, _) in
                if let _ = error{
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }else if let image = image{
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileName = link.replacingOccurrences(of: "/", with: "")
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    if let data = image.jpegData(compressionQuality:  1.0),
                       !FileManager.default.fileExists(atPath: fileURL.path) {
                        do {
                            try data.write(to: fileURL)
                            DispatchQueue.main.async {
                                completion(fileURL.absoluteString)
                            }
                        } catch {
                            DispatchQueue.main.async {
                                print(error)
                                completion(nil)
                            }
                        }
                    }else{
                        DispatchQueue.main.async {
                            completion(fileURL.absoluteString)
                        }
                    }
                    return
                }else{
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
    
}
