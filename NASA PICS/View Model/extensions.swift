//
//  extension.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import UIKit

extension UIViewController{
    
    func showAlert(title: String, message: String, completion: @escaping (_ done: String?) -> ()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(_) in
            completion(nil)
        }))
        self.present(alert, animated: true)
    }
    
}
