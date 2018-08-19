//
//  Movie.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - Movie

struct Movies: Codable {
    var movies: [Movie]?
}

struct Movie: Codable {
    let title: String
    let id: Int
    let poster_path: String?
    
}

// MARK: - Movie: Equatable

extension Movie: Equatable {}

func ==(lhs: Movie, rhs: Movie) -> Bool {
    return lhs.id == rhs.id
}
