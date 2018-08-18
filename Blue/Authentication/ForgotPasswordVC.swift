//
//  ForgotPasswordVC.swift
//  Blue
//
//  Created by DK on 8/17/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.emailTextField.becomeFirstResponder()
    }

    @IBAction func btnForgotPasswordVerificationAction(_ sender: UIButton) {
        if let email = self.emailTextField.text , email.isValidEmail {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    self.showAlert(error.localizedDescription)
                }
                else {
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (ok) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.showAlert(message: "We sent password reset link to your mail. Please check your email.", actions: okAction)
                }
            }
        }
        else {
            self.showAlert("Invalid email address.")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
