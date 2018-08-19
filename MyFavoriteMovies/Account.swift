//
//  Account.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 8/18/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct Account: Codable {
    var id: Int?
    var iso_639_1: String?
    var iso_3166_1: String?
    var name: String?
    var include_adult: Bool?
    var username: String?
}
