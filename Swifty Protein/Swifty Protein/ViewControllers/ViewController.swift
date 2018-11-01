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
    @IBOutlet weak var touchIDbutton: UIButton!
    
//    let context:LAContext = LAContext()
    
    
    /*--------------------------------------*/
    /*---------------ACTION-----------------*/
    /*--------------------------------------*/
    
    @IBAction func Login(_ sender: Any)
    {
        if usernameText.text == "admin" && passwordText.text == "admin"
        {
            performSegue(withIdentifier: "listSegue", sender: "")
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: "Username or Password, wrong", preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "listSegue", sender: "")
                    }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "listSegue"
        {
            
        }
    }
    
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
        
        
        // Check if device have TouchID
        var authError: NSError?
        let context:LAContext = LAContext()
        if !context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
        {
            if (authError?.code)! == kLAErrorTouchIDNotEnrolled
            {
                touchIDbutton.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

