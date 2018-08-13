//
//  SignInViewController.swift
//  
//
//  Created by Tim Schönenberger on 04.07.18.
//

import UIKit
import Foundation
import Firebase

class SignInViewController: ViewController, UITextFieldDelegate{

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        SignInPressed.isEnabled = false
        
        self.emailField.text = "dharmesh.kathiriya304@gmail.com"
        self.passwordField.text = "123456"
    }
    
    
    @IBOutlet weak var SignInPressed: UIButton!
    
    @IBAction func SignInPressed(_ sender: Any) {
        let email = emailField.text
        let password = passwordField.text
        let formFilled =  email != nil && email != "" && password != nil && password != ""
        if formFilled {
            handleSignIn()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.textFieldChanged(textField)
        return true
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
        self.view.endEditing(true)
        HUD.show()
        Auth.auth().signIn(withEmail: email, password: pass) { user, error in
            HUD.dismiss()
            if error == nil && user != nil {
                self.setPageController()
            } else {
                self.showAlert(error!.localizedDescription)
                JDB.error("logging in:", error!.localizedDescription)
            }
        }
    }
    func setPageController() {
        let object = Object(PageViewController.self)
        self.navigationController?.setViewControllers([object], animated: true)
    }
}
