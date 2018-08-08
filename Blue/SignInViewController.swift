//
//  SignInViewController.swift
//  
//
//  Created by Tim Schönenberger on 04.07.18.
//

import UIKit

// For Sign In BTN
@IBDesignable extension UIButton {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
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




import UIKit
import Foundation
import Firebase

class SignInViewController: ViewController, UITextFieldDelegate{

   
        
    @IBOutlet weak var emailField: UITextField!
    
    
    @IBOutlet weak var passwordField: UITextField!
    
     func viewDidAppear() {
        super.viewDidLoad()
        
        let myColor = UIColor.lightGray
        emailField.layer.borderColor = myColor.cgColor
        passwordField.layer.borderColor = myColor.cgColor
       
        emailField.layer.cornerRadius = 7.4
        passwordField.layer.cornerRadius = 7.4
        emailField.layer.borderWidth = 2.0
        passwordField.layer.borderWidth = 2.0
        
     
    }
        

    @IBOutlet weak var SignInPressed: UIButton!
    
    @IBAction func SignInPressed(_ sender: Any) {
    self.dismiss(animated: false, completion: nil)
    }
    
        
        func textFieldChanged(_ target:UITextField) {
            
            let email = emailField.text
            let password = passwordField.text
            let formFilled =  email != nil && email != "" && password != nil && password != ""
            setSignInPressed(enabled: formFilled)
            
            
        }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resigns the target textField and assigns the next textField in the form.
        
        switch textField {
        case emailField:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
            break
        case passwordField:
            handleSignIn()
            break
        default:
            break
        }
        return true
    }
    
    
    
    
    func setSignInPressed(enabled:Bool) {
        if enabled {
            
            SignInPressed.isEnabled = true
        } else {
           
            SignInPressed.isEnabled = false
        }
    }
    
    
    
       @objc func handleSignIn() {
    
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        
        setSignInPressed(enabled: false)
        
        
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            if error == nil && user != nil {
                self.dismiss(animated: false, completion: nil)
                
                
            } else {
                
                print("Error logging in: \(error!.localizedDescription)")
            }
            
 
           
            
            
            
        }
        
      
        
        
    }
    
    

    

}
