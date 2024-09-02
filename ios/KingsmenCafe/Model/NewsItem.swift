//
//  NewsItem.swift
//  KingsmenCafe
//
//  Created by Matthew Wyskiel on 2/27/18.
//  Copyright © 2018 Christian Heritage School. All rights reserved.
//

import Foundation

struct NewsItem: Codable {
    let id: String
    let publishDate: Date
    let content: String

    struct Media: Codable {
        let height: Int
        let width: Int
        let src: URL
    }

    struct Photo: Codable {
        let description: String?
        let media: Media
    }
    let photos: [Photo]?
    let coverPhoto: Photo?

    struct Video: Codable {
        let embedHTML: String
        let length: Double
        let id: String

        enum CodingKeys: String, CodingKey {
            case embedHTML = "embed_html"
            case length, id
        }
    }
    let video: Video?

    struct Event: Codable {
        let name: String
        let description: String
        let start: Date
        let end: Date

        struct Location: Codable {
            let name: String
            let latitude: Double
            let longitude: Double
            let street: String
            let city: String
            let state: String
            let zip: String
            let country: String
        }
        let location: Location
    }

    struct Link: Codable {
        let title: String
        let media: Media
        let url: URL
    }
    let link: Link?

}
