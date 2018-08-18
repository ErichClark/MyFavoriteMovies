//
//  AppDelegate.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    var defaults = UserDefaults.standard
    var window: UIWindow?
    
    var sharedSession = URLSession.shared
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    var dateUpdated: Date? = nil
    
    // configuration for TheMovieDB, we'll take care of this for you =)...
    var config: Config? = nil
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // if necessary, update the configuration...
        if configIsCurrent {
            loadConfig()
        } else {
            updateConfig()
        }
        
        return true
    }
    
    func loadConfig() {
        do {
        let fileURL = URL(fileURLWithPath: "config", relativeTo: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL).appendingPathExtension("plist")
        let plistDecoder = PropertyListDecoder()
        let savedPLISTdata = try Data(contentsOf: fileURL)
        let savedConfig = try plistDecoder.decode(Config.self, from: savedPLISTdata)
            config = savedConfig
        }
        catch {print(error)}
        //config = defaults.object(forKey: "config") as? Config ?? Constants.defaultConfig
    }
    
    var configIsCurrent: Bool {
        let defaults = UserDefaults.standard
        guard let lastUpdate = defaults.object(forKey: "lastUpdate") as! Date? else {
        print("Date of last update not found")
        return false
        }
        let daysSinceUpdate = Int(Date().timeIntervalSince(lastUpdate)) / 60*60*24
        if daysSinceUpdate < 7 {
            return true
        } else {
            return false
        }
    }
}

// MARK: Create URL from Parameters

extension AppDelegate {
    
    func tmdbURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.TMDB.ApiScheme
        components.host = Constants.TMDB.ApiHost
        components.path = Constants.TMDB.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

