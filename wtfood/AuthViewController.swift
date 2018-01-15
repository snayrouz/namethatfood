//
//  AuthViewController.swift
//  
//
//  Created by Samuel Nayrouz on 1/7/18.
//

import UIKit
import TwitterKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let TwitterLoginBtn = TWTRLogInButton{ (session, error) in
            if error != nil {
                print("Twitter Login Error: \(String(describing: error?.localizedDescription))")
            } else {
                guard let token = session?.authToken else {return}
                guard let secret = session?.authTokenSecret else {return}
                let credential = TwitterAuthProvider.credential(withToken: token, secret: secret)
                SVProgressHUD.show()
                
                Auth.auth().signIn(with: credential, completion: { (user, error) in
                    if error != nil {
                        print("Failed to login with Firebase: \(String(describing: error?.localizedDescription))")
                        return
                    }
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "loggedIn", sender: self)
                })
            }
        }
        
        TwitterLoginBtn.frame = CGRect(x: 15, y: 120, width: view.frame.width - 30, height: 30)
        view.addSubview(TwitterLoginBtn)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
