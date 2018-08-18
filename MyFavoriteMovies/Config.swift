//
//  Config.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 8/17/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct Config: Codable {
    var images: Images
}

struct Images: Codable {
    var base_url: String
    var secure_base_url: String
    var poster_sizes: [String]
    var profile_sizes: [String]
}
