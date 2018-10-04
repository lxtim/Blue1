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
    @IBOutlet weak var SignInPressed: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Platform.isSimulator {
            self.emailField.text = "dharmesh.kathiriya304@gmail.com"
        }
        else {
            self.emailField.text = "ketansangani@gmail.com"
        }
        
        self.passwordField.text = "123456"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    

    @IBAction func SignInPressed(_ sender: Any) {
        let email = emailField.text
        let password = passwordField.text
        let formFilled =  email != nil && email != "" && password != nil && password != ""
        if formFilled {
            handleSignIn()
        }
    }
    
    @IBAction func btnForgotPasswordAction(_ sender: UIButton) {
        let forgotPassVC = Object(ForgotPasswordVC.self)
        self.navigationController?.pushViewController(forgotPassVC, animated: true)
    }
    
    //MARK:- UITextFieldDelegate
    
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
    
    
    
    //MARK:- Handle Sign in
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
        Auth.auth().signIn(withEmail: email, password: pass) { authDataResult, error in
            if error == nil && authDataResult != nil {
                if let result = authDataResult {
                    firebaseUser = result.user
                    self.setPageController()
                }
                else {
                    HUD.dismiss()
                }
            } else {
                self.showAlert(error!.localizedDescription)
                JDB.error("logging in:", error!.localizedDescription)
                HUD.dismiss()
            }
        }
    }
    func setPageController() {
        
//        let storage = Storage.storage()
//        let ref = storage.reference(forURL: "https://firebasestorage.googleapis.com/v0/b/blue-6a7f0.appspot.com/o/image%2FlDRis15092018121519.png?alt=media&token=62a10c86-4dd7-4b5c-aa82-5386a89dc3bd")
//
//        ref.delete { (error) in
//            if let error = error {
//                JDB.error("%@", error)
//            }
//        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            let object = Object(PageViewController.self)
            self.navigationController?.setViewControllers([object], animated: true)
            HUD.dismiss()
        }
    }
}
