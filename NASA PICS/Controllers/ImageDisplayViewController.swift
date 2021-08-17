//
//  ImageDisplayViewController.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import UIKit
import SDWebImage

class ImageDisplayViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    private var loader = UIActivityIndicatorView()
    
    var imageTitle = ""
    var path = ""
    var url = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.name.text = self.imageTitle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.setup()
    }
    
    private func setup(){
        if path != ""{
            self.img.image = UIImage(contentsOfFile: URL(string: path)?.path ?? "")
        }else{
            self.showLoader()
            self.img.sd_setImage(with: URL(string: self.url), placeholderImage: UIImage(), options: .highPriority) { (_, _, _, _) in
                DispatchQueue.main.async {
                    self.hideLoader()
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

}
