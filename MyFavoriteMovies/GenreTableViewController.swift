//
//  GenreTableViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - GenreTableViewController: UITableViewController

class GenreTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var movies = [Movie]()
    var genre = Genre()
    var genreID: Int? = nil
    var account = Account()
    var config = Constants.defaultConfig

    // MARK: Tab Outlets
    // They serve as handles to determine the current page view.
    @IBOutlet weak var ActionTab: UITabBarItem!
    @IBOutlet weak var SciFiTab: UITabBarItem!
    @IBOutlet weak var ComedyTab: UITabBarItem!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        config = appDelegate.config!
        account = appDelegate.account

        // create and set logout button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Workaround - I added outlets to each individual
        // genre page, and when they are not nil,
        // that triggers the correct genreID.
        if ActionTab != nil {
            genreID = 28
        } else if SciFiTab != nil {
            genreID = 878
        } else if ComedyTab != nil {
            genreID = 35
        }
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey,
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: "/genre/\(genreID!)/movies"))
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // print("** genre request = \(request)")
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request as URLRequest) { (data, urlResponse, error) in
            
            _ = NetworkErrorGuard(data: data, urlResponse: urlResponse!, error: error)
            
            /* 5. Parse the data */
            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let genreResults = try jsonDecoder.decode(Genre.self, from: retrievedData)
                self.genre = genreResults
                self.movies = self.genre.results!
                // print("** genre loaded = \(String(describing: self.genreID))")
            }
            catch {print(error)}
            
            /* 6. Use the data! */
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    // MARK: Logout
    
    @objc func logout() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - GenreTableViewController (UITableViewController)

extension GenreTableViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell type
        let cellReuseIdentifier = "MovieTableViewCell"
        let movie = movies[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?
        
        // set cell defaults
        cell?.textLabel!.text = movie.title
        cell?.imageView!.image = UIImage(named: "Film Icon")
        cell?.imageView!.contentMode = UIViewContentMode.scaleAspectFit
        
        /* TASK: Get the poster image, then populate the image view */
        if let poster_path = movie.poster_path {
            
            /* 1. Set the parameters */
            // There are none...
            
            /* 2. Build the URL */
            let baseURL = URL(string: config.images.base_url)!
            let url = baseURL.appendingPathComponent("w154").appendingPathComponent(poster_path)
            
            /* 3. Configure the request */
            let request = URLRequest(url: url)
            
            /* 4. Make the request */
            let task = appDelegate.sharedSession.dataTask(with: request) { (data, urlResponse, error) in
                
                _ = NetworkErrorGuard(data: data, urlResponse: urlResponse!, error: error)
                
                /* 5. Parse the data */
                // No need, the data is already raw image data.
                
                /* 6. Use the data! */
                if let image = UIImage(data: data!) {
                    performUIUpdatesOnMain {
                        cell?.imageView!.image = image
                    }
                } else {
                    print("Could not create image from \(String(describing: data))")
                }
            }
            
            /* 7. Start the request */
            task.resume()
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // push the movie detail view
        let controller = storyboard!.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        controller.movie = movies[(indexPath as NSIndexPath).row]
        navigationController!.pushViewController(controller, animated: true)
    }
}

