//
//  ViewController.swift
//  Swifty Protein
//
//  Created by Jimmy CHEN-MA on 10/30/18.
//  Copyright © 2018 Jimmy CHEN-MA. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController
{
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    
    /*--------------------------------------*/
    /*---------------ACTION---------------*/
    /*--------------------------------------*/
    
    @IBAction func Login(_ sender: Any)
    {
        
    }
    
    @IBAction func TouchID(_ sender: Any)
    {
        let context:LAContext = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "We need your TouchID", reply: {(wasSuccessful, error) in
                if (wasSuccessful)
                {
                    // TouchID valid, segue to new view
                    print ("TouchID successful")
                }
                else
                {
                    print (error.debugDescription)
                }
            })
        }
    }
    
    /*--------------------------------------*/
    /*---------------OVERRIDE---------------*/
    /*--------------------------------------*/
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loginButton.layer.cornerRadius = 5
        usernameText.layer.cornerRadius = 5
        usernameText.layer.borderWidth = 1
        usernameText.layer.borderColor = UIColor.black.cgColor
        passwordText.layer.cornerRadius = 5
        passwordText.layer.borderWidth = 1
        passwordText.layer.borderColor = UIColor.black.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

