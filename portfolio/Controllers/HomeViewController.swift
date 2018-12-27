//
//  ViewController.swift
//  portfolio
//
//  Created by Formative Mini on 9/5/18.
//  Copyright © 2018 Formative Web Solutions. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var portfolio: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                if let navController = UIStoryboard(name: "LoggedIn", bundle: nil).instantiateInitialViewController() as? UINavigationController {
                    self.present(navController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    
    @IBAction func loginPressed(_ sender: UIButton) {
        if let navController = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() as? UINavigationController {
            self.present(navController, animated: true, completion: nil)
        }
    }
}

