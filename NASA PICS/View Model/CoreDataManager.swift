//
//  CoreDataManager.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager{
    
    static var shared = CoreDataManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func saveToFav(apod: APOD, imagePath: String, completion: @escaping (String?) -> ()) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
        request.predicate = NSPredicate(format: "title = %@", apod.title ?? "")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request) as! [Favourites]
            for data in result{
                if data.title == apod.title{
                    completion("Item already exists in favourites")
                    return
                }
            }
        }catch{
            completion(error.localizedDescription)
            return
        }
        let entity = NSEntityDescription.entity(forEntityName: "Favourites", in: context)
        let newFavourite = Favourites(entity: entity!, insertInto: context)
        newFavourite.setValue(imagePath, forKey: "hdurl")
        newFavourite.setValue(apod.title ?? "", forKey: "title")
        newFavourite.setValue(apod.date ?? "", forKey: "date")
        do{
           try context.save()
            completion(nil)
        }catch{
            completion(error.localizedDescription)
        }
    }
    
    func getFavs( completion: @escaping (_ error: String?, _ favourites: [Favourites]?) -> ()) {
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favourites")
        request.returnsObjectsAsFaults = false
        do{
            let result = try context.fetch(request)
            if result.count == 0{
                completion(nil, nil)
                return
            }
            var favourites = [Favourites]()
            for data in result as! [Favourites]{
                favourites.append(data)
            }
            completion(nil, favourites)
        }catch{
            completion(error.localizedDescription, nil)
        }
    }
    
}
