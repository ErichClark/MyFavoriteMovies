//
//  Genres.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 8/18/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct Genre: Codable {
    var id: Int?
    var page: Int?
    var results: [Movie]?
}

