//
//  NetworkErrorGuard.swift
//  MyFavoriteMovies
//
//  Created by Erich Clark on 6/28/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

func NetworkErrorGuard(data: Data?, response: URLResponse, error: Error?) {
    /* GUARD: Was there an error? */
    guard (error == nil) else {
        print("There was an error with your request: \(error!)")
        return
    }
    
    /* GUARD: Did we get a successful 2XX response? */
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        print("Your request returned a status code other than 2xx!")
        return
    }
    
    /* GUARD: Was there any data returned? */
    guard data != nil else {
        print("No data was returned by the request!")
        return
    }
    
}
