//
//  SignUpViewController.swift
//  Blue
//
//  Created by Tim Schönenberger on 04.07.18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: ViewController {
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var ref: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func alreadyAccountAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        self.handleSignUp()
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
        
        HUD.show()
        Auth.auth().createUser(withEmail: email, password: pass) { user, error in
            HUD.dismiss()
            guard let user = user else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges { error in
                if error == nil {
                    let json = [ConstantKey.id:user.user.uid,
                                ConstantKey.username:firebaseUser.displayName ?? "",
                                ConstantKey.image:user.user.photoURL?.absoluteString ?? "",
                                ConstantKey.email:user.user.email ?? ""]
                    
                    self.ref.child(ConstantKey.Users).child(user.user.uid).setValue(json, withCompletionBlock: { (error, databaseRef) in
                        HUD.dismiss()
                        guard let error = error else {
                            self.setToManinController()
                            return
                        }
                        JDB.error("Data base error ==>%@", error.localizedDescription)
                    })
                } else {
                    print("Error: \(error!.localizedDescription)")
                }
            }
        }
    }
    
    func setToManinController() {
        let pageViewController = Object(PageViewController.self)
        self.navigationController?.setViewControllers([pageViewController], animated: true)
    }
}
