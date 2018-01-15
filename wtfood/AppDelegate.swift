//
//  AppDelegate.swift
//  wtfood
//
//  Created by Samuel Nayrouz on 12/27/17.
//  Copyright © 2017 Samuel Nayrouz. All rights reserved.
//

import UIKit
import TwitterKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        //twitter login
        TWTRTwitter.sharedInstance().start(withConsumerKey: "CONSUMERKEY", consumerSecret: "CONSUMERSECRET")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let twitterLogin = TWTRTwitter.sharedInstance().application(app, open: url, options: options)
        return twitterLogin
    }
}

