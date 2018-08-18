//
//  RequestToken.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 8/18/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct RequestToken: Codable {
    var success: Bool?
    var expires_at: String?
    var request_token: String?
}
