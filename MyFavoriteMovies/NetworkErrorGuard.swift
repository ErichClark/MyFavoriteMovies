//
//  NetworkErrorGuard.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 6/28/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

func NetworkErrorGuard(data: Data?, urlResponse: URLResponse, error: Error?) -> String {
    /* GUARD: Was there an error? */
    
    guard (error == nil) else {
        return "There was an error with your request: \(error!)"
    }
    
    /* GUARD: Did we get a successful 2XX urlResponse? */
    guard let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        return "Your request returned a status code other than 2xx!"
    }
    
    /* GUARD: Was there any data returned? */
    guard data != nil else {
        return "No data was returned by the request!"
    }
    
    return "success!"
}
