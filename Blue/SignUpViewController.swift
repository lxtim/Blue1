//
//  SignUpViewController.swift
//  Blue
//
//  Created by Tim Schönenberger on 04.07.18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit


//For SignUP btn
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth2: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius2: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor2: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}


import Firebase

class SignUpViewController: ViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var nextPressed: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myColor = UIColor.lightGray
        email.layer.borderColor = myColor.cgColor
        password.layer.borderColor = myColor.cgColor
        username.layer.borderColor = myColor.cgColor
        
        email.layer.cornerRadius = 7.4
        password.layer.cornerRadius = 7.4
        username.layer.cornerRadius = 7.4
        
        email.layer.borderWidth = 2.0
        password.layer.borderWidth = 2.0
        username.layer.borderWidth = 2.0
    }
    
    
    @IBAction func nextPressed(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    
    
    
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = self.email.text
        let password = self.password.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
        nextPressed(formFilled)
    }
    
    
    
    
    @objc func handleSignUp() {

        guard let username = username.text else { return }
        guard let email = email.text else { return }
        guard let pass = password.text else { return }
        
        
        nextPressed(false)

        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil  {
                print("User created!")
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = username
                
                changeRequest?.commitChanges { error in
                    if error == nil {
                        print("User display name changed!")
                        self.dismiss(animated: false, completion: nil)
                    } else {
                        print("Error: \(error!.localizedDescription)")
                    }
                }
                
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        

}
        
        
}

}
