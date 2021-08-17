//
//  APOD.swift
//  NASA PICS
//
//  Created by Jaskirat Mangat on 4/27/21.
//

import Foundation

struct APOD : Codable {

    let date : String?
    let explanation : String?
    let hdurl : String?
    let mediaType : String?
    let serviceVersion : String?
    let title : String?
    let url : String?
    
    enum CodingKeys: String, CodingKey {
        case date = "date"
        case explanation = "explanation"
        case hdurl = "hdurl"
        case mediaType = "media_type"
        case serviceVersion = "service_version"
        case title = "title"
        case url = "url"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        explanation = try values.decodeIfPresent(String.self, forKey: .explanation)
        hdurl = try values.decodeIfPresent(String.self, forKey: .hdurl)
        mediaType = try values.decodeIfPresent(String.self, forKey: .mediaType)
        serviceVersion = try values.decodeIfPresent(String.self, forKey: .serviceVersion)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        url = try values.decodeIfPresent(String.self, forKey: .url)
    }

}
