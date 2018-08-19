//
//  LoginViewController.swift
//  MyFavoriteMovies
//
//  Created by Jarrod Parkes on 1/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    var appDelegate: AppDelegate!
    var keyboardOnScreen = false
    var config = Constants.defaultConfig
    
    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: BorderedButton!
    @IBOutlet weak var debugTextLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
        
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        config = appDelegate.config!
        
        configureUI()
        
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        userDidTapView(self)
        
        if usernameTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            debugTextLabel.text = "Username or Password Empty."
        } else {
            setUIEnabled(false)
            
            
            // Steps for Authentication...
            // https://www.themoviedb.org/documentation/api/sessions
                
            // Step 1: Create a request token
            getRequestToken()
            // Step 2: Ask the user for permission via the API ("login")
            
            // Step 3: Create a session ID
                
            // Extra Steps...
            // Step 4: Get the user id ;)
            // Step 5: Go to the next view!
            
        }
    }
    
    private func completeLogin() {
        performUIUpdatesOnMain {
            self.debugTextLabel.text = ""
            self.setUIEnabled(true)
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MoviesTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: TheMovieDB
    
    private func getRequestToken() {
        
        /* TASK: Get a request token, then store it (appDelegate.requestToken) and login with the token */
        
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey
        ]
        
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodParameters as [String:AnyObject], withPathExtension: "/authentication/token/new"))
        
        print("request token URL = \(request)")
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request) { (data, urlResponse, error) in
            
            self.displayNetworkErrorsInDebugUI(data: data!, urlResponse: urlResponse!, error: error)
            
            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let newToken = try jsonDecoder.decode(RequestToken.self, from: retrievedData)
                print("newToken = \(newToken)")
                self.appDelegate.requestToken = newToken
                self.loginWithToken(self.appDelegate.requestToken.request_token!)
                if self.appDelegate.requestToken.success != true {
                    performUIUpdatesOnMain {
                        self.setUIEnabled(true)
                        self.debugTextLabel.text = "Could not get request token!"
                    }
                }
            }
            catch {print(error)}
        }
        
        
        /* 7. Start the request */
        task.resume()
    }
    
    private func loginWithToken(_ request_token: String) {
        
        /* TASK: Login, then get a session id */
        // https://www.themoviedb.org/authenticate/{REQUEST_TOKEN}
        let username = self.appDelegate.username
        let password = self.appDelegate.password
        
        /* 1. Set the parameters */
        let methodPerameters: [String:Any] = [Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey, Constants.TMDBParameterKeys.RequestToken: request_token, Constants.TMDBParameterKeys.Username: username!, Constants.TMDBParameterKeys.Password: password!]
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodPerameters as [String:AnyObject], withPathExtension: "/authentication/token/validate_with_login"))
        
        print("*** URL permission authentication - \(request) ")
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTask(with: request) {  (data, urlResponse, error) in
            
            self.displayNetworkErrorsInDebugUI(data: data!, urlResponse: urlResponse!, error: error)
            
            /* 5. Parse the data */
            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let validationToken = try jsonDecoder.decode(Validate_With_Login.self, from: retrievedData)
                print("*** validationToken = \(validationToken)")
                /* 6. Use the data! */
                self.appDelegate.validate_with_login = validationToken
                self.getSessionID(self.appDelegate.validate_with_login.request_token!)
            }
            catch{print(error)}

        }
        /* 7. Start the request */
        task.resume()
    }
    
    private func getSessionID(_ validation_token: String) {
        print("** Tried to get session id with \(validation_token)")
        /* TASK: Get a session ID, then store it (appDelegate.sessionID) and get the user's id */
        
        /* 1. Set the parameters */
        let methodPerameters: [String:Any] = [Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey, Constants.TMDBParameterKeys.RequestToken: self.appDelegate.validate_with_login.request_token!]
        
        /* 2/3. Build the URL, Configure the request */
        // "/authentication/session/new"
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodPerameters as [String : AnyObject], withPathExtension: "/authentication/session/new"))
        /* 4. Make the request */
        print("** URL request for session ID = \(request)")
        
        let task = appDelegate.sharedSession.dataTask(with: request) { (data, urlResponse, error) in

            self.displayNetworkErrorsInDebugUI(data: data!, urlResponse: urlResponse!, error: error)

            /* 5. Parse the data */
            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let newSessionID = try jsonDecoder.decode(SessionID.self, from: retrievedData)
                self.appDelegate.sessionID = newSessionID
                print("** session id = \(String(describing: self.appDelegate.sessionID.session_id))")
                self.getUserID(self.appDelegate.sessionID.session_id!)
            }
            catch {print(error)}


        }
        /* 6. Use the data! */
        /* 7. Start the request */
        task.resume()
    }
    
    private func getUserID(_ sessionID: String) {
        
        /* TASK: Get the user's ID, then store it (appDelegate.userID) for future use and go to next view! */
        
        /* 1. Set the parameters */
        let methodPerameters: [String:Any] = [Constants.TMDBParameterKeys.ApiKey: Constants.TMDBParameterValues.ApiKey, Constants.TMDBParameterKeys.SessionID: self.appDelegate.sessionID.session_id!]
        /* 2/3. Build the URL, Configure the request */
        let request = URLRequest(url: appDelegate.tmdbURLFromParameters(methodPerameters as [String:AnyObject], withPathExtension: "/account"))
        /* 4. Make the request */
        
        print("** Request for user information = \(request)")
        let task = appDelegate.sharedSession.dataTask(with: request) { (data, urlResponse, error) in

            self.displayNetworkErrorsInDebugUI(data: data!, urlResponse: urlResponse!, error: error)

            do {
                let jsonDecoder = JSONDecoder()
                let retrievedData = Data(data!)
                let newAccount = try jsonDecoder.decode(Account.self, from: retrievedData)
                self.appDelegate.account = newAccount
                print("** new account = \(self.appDelegate.account)")
                self.completeLogin()
            }
            catch {print(error)}

        }
        /* 5. Parse the data */
        /* 6. Use the data! */
        /* 7. Start the request */
        task.resume()
    }
    
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
            movieImageView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
            movieImageView.isHidden = false
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    private func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    private func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        self.appDelegate.username = self.usernameTextField.text
        self.appDelegate.password = self.passwordTextField.text
        
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
}

// MARK: - LoginViewController (Configure UI)

private extension LoginViewController {
    
    func setUIEnabled(_ enabled: Bool) {
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
        debugTextLabel.text = ""
        debugTextLabel.isEnabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    func configureUI() {
        
        // configure background gradient
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [Constants.UI.LoginColorTop, Constants.UI.LoginColorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        configureTextField(usernameTextField)
        configureTextField(passwordTextField)
    }
    
    func configureTextField(_ textField: UITextField) {
        let textFieldPaddingViewFrame = CGRect(x: 0.0, y: 0.0, width: 13.0, height: 0.0)
        let textFieldPaddingView = UIView(frame: textFieldPaddingViewFrame)
        textField.leftView = textFieldPaddingView
        textField.leftViewMode = .always
        textField.backgroundColor = Constants.UI.GreyColor
        textField.textColor = Constants.UI.BlueColor
        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        textField.tintColor = Constants.UI.BlueColor
        textField.delegate = self
    }
}

// MARK: - LoginViewController (Notifications)

private extension LoginViewController {
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension LoginViewController {
    func displayNetworkErrorsInDebugUI(data: Data, urlResponse: URLResponse, error: Error?) {
        let message = NetworkErrorGuard(data: data, urlResponse: urlResponse, error: error)
        performUIUpdatesOnMain {
            self.setUIEnabled(true)
            if error != nil {
                self.debugTextLabel.text = "Error is \(message)"
            }
//            else {
//                self.debugTextLabel.text = "\(message)"
//            }
            
        }
        
    }
}
