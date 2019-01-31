//
//  BioViewController.swift
//  Blue
//
//  Created by DK on 1/21/19.
//  Copyright © 2019 Tim. All rights reserved.
//

import UIKit
import Firebase

class BioViewController: UIViewController {
    
    var userData:[String:Any] = [String:Any]()
    var isOtherUserProfile:Bool = false
    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    
    @IBOutlet weak var bioTextView: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isOtherUserProfile {
            self.bioTextView.text = self.userData[ConstantKey.caption] as? String
        }
        else {
            self.userRef.child(firebaseUser.uid).observeSingleEvent(of: .value) { (snapshot) in
                guard let userObject = snapshot.value as? [String:Any] else {return}
                self.bioTextView.text = userObject[ConstantKey.caption] as? String
            }
        }
    }

    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return self.scrollView
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
