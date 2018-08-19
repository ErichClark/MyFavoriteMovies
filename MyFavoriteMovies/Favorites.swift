//
//  Favorites.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 8/19/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct Favorites: Codable {
    var page: Int?
    var results: [Movie]?
    var total_pages: Int?
    var total_results: Int?
}
