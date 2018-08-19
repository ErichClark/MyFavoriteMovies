//
//  Genres.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 8/18/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

var GenrePageIDs = ["SciFiTableViewController": 878,
              "ComedyTableViewController": 35,
              "ActionTableViewController": 28
]

struct Genre: Codable {
    var id: Int?
    var page: Int?
    var results: [Movie]?
}

