//
//  ViewController.swift
//  Blue
//
//  Created by Tim Schönenberger on 04.07.18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            self.performSegue(withIdentifier: "SignInViewController", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "PageViewController", sender: nil)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   

}
