//
//  MovieDetailViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import Foundation

// MARK: - MovieDetailViewController: UIViewController

class MovieDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var isFavorite = false
    var movie: Movie?
    var favorites: Favorites?
    var favoriteResponse: FavoriteResponse?
    var config = Constants.defaultConfig
    
    // MARK: Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        config = appDelegate.config!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let movie = movie {
            
            // setting some defaults...
            posterImageView.image = UIImage(named: "film342.png")
            titleLabel.text = movie.title
            
            /* TASK A: Get favorite movies, then update the favorite buttons */
            /* 1A. Set the parameters */
            let methodParameters = [
                Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
                Constants.TMDBParameterKeys.SessionID: appDelegate.sessionID.session_id
            ]
            
            /* 2/3. Build the URL, Configure the request */
            let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: "/account/\(appDelegate.account.id!)/favorite/movies"))
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            print("*** request for favorites data = \(request)")
            /* 4A. Make the request */
            let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
                
                _ = NetworkErrorGuard(data: data, urlResponse: urlResponse!, error: error)
                
                /* 5A. Parse the data */
                do {
                    let jsonDecoder = JSONDecoder()
                    let retrievedData = Data(data!)
                    let favoritesResult = try jsonDecoder.decode(Favorites.self, from: retrievedData)
                    self.favorites = favoritesResult
                    
                    
                }
                catch {print(error)}
                
                /* 6A. Use the data! */
                for item in (self.favorites?.results)! {
                    print("*** This is a movie result = \(item)")
                    if item.id == movie.id {
                        self.isFavorite = true
                    }
                }
                
                performUIUpdatesOnMain {
                    self.favoriteButton.tintColor = (self.isFavorite) ? nil : .black
                }
            }
            
            /* 7A. Start the request */
            task.resume()
            
            /* TASK B: Get the poster image, then populate the image view */
            if let poster_path = movie.poster_path {
                
                /* 1B. Set the parameters */
                // There are none...
                
                /* 2B. Build the URL */
                let baseURL = URL(string: config.images.base_url)!
                let url = baseURL.appendingPathComponent("w342").appendingPathComponent(poster_path)
                
                /* 3B. Configure the request */
                let request = URLRequest(url: url)
                
                /* 4B. Make the request */
                let task = appDelegate.sharedSession.dataTask(with: request) { (data, urlResponse, error) in
                    
                    _ = (NetworkErrorGuard(data: data, urlResponse: urlResponse!, error: error))
                    
                    /* 5B. Parse the data */
                    // No need, the data is already raw image data.
                    
                    /* 6B. Use the data! */
                    if let image = UIImage(data: data!) {
                        performUIUpdatesOnMain {
                            self.posterImageView!.image = image
                        }
                    } else {
                        print("Could not create image from \(describing: data)")
                    }
                }
                
                /* 7B. Start the request */
                task.resume()
            }
        }
    }
    
    // MARK: Favorite Actions
    
    @IBAction func toggleFavorite(_ sender: AnyObject) {
        
        isFavorite = !isFavorite
        let favoriteMovieForPost = Favorite(media_type: "movie", media_id: movie?.id, favorite: isFavorite)
        
        var postData: Data? = nil
        let parameters = [Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey, Constants.TMDBParameterKeys.SessionID: appDelegate.sessionID.session_id!] as [String : Any]
        
        /* TASK: Add movie as favorite, then update favorite buttons */
        /* 1. Set the parameters */
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(parameters as [String : AnyObject], withPathExtension: "/account/\(appDelegate.account.id!)/favorite"), cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        do {
            let jsonEncoder = JSONEncoder()
            postData = try jsonEncoder.encode(favoriteMovieForPost)
        }
        catch {print(error)}
        
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = Constants.Headers.favorite
//        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Accept")
//        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData
        // print("*** favorite post request = \(request)")
        
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
        
            _ = NetworkErrorGuard(data: data, urlResponse: urlResponse!, error: error)
            
            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let newFavoriteResponse = try jsonDecoder.decode(FavoriteResponse.self, from: retrievedData)
                print("** favorite response = \(String(describing: newFavoriteResponse))")
            }
            catch {print(error)}
            /* 2/3. Build the URL, Configure the request */
        /* 4. Make the request */
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
        
        // If the favorite/unfavorite request completes, then use this code to update the UI...
         
         performUIUpdatesOnMain {
            self.favoriteButton.tintColor = (self.isFavorite) ? nil : UIColor.black
         }
        }
        task.resume()
    }
}
