//
//  Networking.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import Foundation

class Networking{
    
    static var shared = Networking()
    let url = "https://api.nasa.gov/planetary/apod"
    
    func getData<T: Decodable>(objectType: T.Type, completion: @escaping (Result<T>) -> Void) {
        let session = URLSession.shared

        var components = URLComponents(string: self.url)!
        let parameters = ["api_key": "dqv6fBwvTb4RwDppsx2JrAXcuAeDMrdbdKdGRNLM", "start_date": "2020-04-27", "end_date": "2021-04-27"]
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        let request = URLRequest(url: components.url!)
        let task = session.dataTask(with: request, completionHandler: { data, response, error in

            guard error == nil else {
                let appError = APPError.networkError(error!)
                completion(Result.failure(appError))
                return
            }

            guard let data = data else {
                completion(Result.failure(APPError.dataNotFound))
                return
            }

            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                completion(Result.success(decodedObject))
            } catch let error {
                completion(Result.failure(APPError.jsonParsingError(error as! DecodingError)))
            }
        })
        task.resume()
    }
    
}

enum APPError: Error {
    case networkError(Error)
    case dataNotFound
    case jsonParsingError(Error)
    case invalidStatusCode(Int)
}

//Result enum to show success or failure
enum Result<T> {
    case success(T)
    case failure(APPError)
}
