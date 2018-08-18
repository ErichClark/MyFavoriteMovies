//
//  updateConfig.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//
//  The config struct stores (persist) information that is used to build image
//  URL's for TheMovieDB. The constant values below were taken from
//  the site on 1/23/15. Invoking the updateConfig convenience method
//  will download the latest using the initializer below to
//  parse the dictionary.
//
//  We will talk more about persistance in a later lesson.
//

import UIKit
import Foundation

extension AppDelegate {

    func updateConfig() {
        
        /* TASK: Get TheMovieDB configuration, and update the config */
        
        /* Grab the app delegate and User Defaults */
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: "/configuration"))
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        print("*** request *** \(request)")
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
            
            /* 5. Parse the data, handle errors  */
            NetworkErrorGuard(data: data, urlResponse: urlResponse!, error: error)
            
            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let newConfig = try jsonDecoder.decode(Config.self, from: retrievedData)
                print("*** newConfig *** = \(newConfig)")
                /* 6. Use the data! See below. */
                self.save(newConfig)
            }
            catch {print(error)}

        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    private func save(_ newConfig: Config) {
        do {
            let plistURL = URL(fileURLWithPath: "config", relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL).appendingPathExtension("plist")
            print("*** plistURL *** = \(plistURL)")
            let plistEncoder = PropertyListEncoder()
            let newConfigPlist = try plistEncoder.encode(newConfig)
            try newConfigPlist.write(to: plistURL)
        
            // Save the date
            defaults.set(Date(), forKey: "lastUpdate")
            print("*** date last updated *** = \(String(describing: defaults.object(forKey: "lastUpdate")))")
        }
        catch {print(error)}
    }
    
}
