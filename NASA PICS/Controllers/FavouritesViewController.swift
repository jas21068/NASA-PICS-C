//
//  FavouritesViewController.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import UIKit

class FavouritesViewController: UIViewController {

    @IBOutlet weak var colv: UICollectionView!
    
    private var items = [Favourites]()
    private var selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.getData()
    }
    
    private func setup(){
        self.colv.delegate = self
        self.colv.dataSource = self
        self.colv.reloadData()
    }
    
    private func getData(){
        CoreDataManager.shared.getFavs { (error, favourites) in
            DispatchQueue.main.async {
                if let error = error{
                    self.showAlert(title: "Error", message: error) { (_) in }
                }else if let favourites = favourites{
                    self.items = favourites
                    self.colv.reloadData()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next"{
            let vc = segue.destination as! ImageDisplayViewController
            vc.imageTitle = self.items[selectedIndex].title ?? ""
            vc.path = self.items[selectedIndex].hdurl ?? ""
        }
    }

}

extension FavouritesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favCell", for: indexPath) as! FavCollectionViewCell
        cell.img.image = UIImage(contentsOfFile: URL(string: self.items[indexPath.row].hdurl ?? "")?.path ?? "")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = (collectionView.frame.size.width/2)-30
        return CGSize(width: length, height: length)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "next", sender: nil)
    }
    
}
