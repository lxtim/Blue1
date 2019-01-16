//
//  SettingViewController.swift
//  Blue
//
//  Created by DK on 8/15/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

enum FeedLayout:Int {
    case list = 0
    case grid
}

class SettingViewController: UIViewController , UITextViewDelegate {
   
    
    @IBOutlet weak var profileCaptionTextView: UITextView!
    
    var ref = Database.database().reference()
    
    var user:[String:Any] = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileCaptionTextView.textContainer.maximumNumberOfLines = 3
        profileCaptionTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        self.ref.child(ConstantKey.Users).child(firebaseUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userData = snapshot.value as? [String:Any] else {return}
            self.user = userData
            
            if let layout = self.user[ConstantKey.layout] as? Int {
                let feedLayout = FeedLayout(rawValue: layout)!
                if feedLayout == FeedLayout.list {
                    self.btnList.isSelected = true
                    self.btnGrid.isSelected = false
                }
                else {
                    self.btnList.isSelected = false
                    self.btnGrid.isSelected = true
                }
            }
            else {
                self.btnList.isSelected = true
                self.btnGrid.isSelected = false
            }
            
            if let caption = self.user[ConstantKey.caption] as? String {
                self.profileCaptionTextView.text = caption
            }
        }
    }
    
    @IBOutlet weak var btnList: UIButton!
    @IBOutlet weak var btnGrid: UIButton!
    
    @IBAction func btnLogountAction(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            JDB.log("Setting User default ==>%@", UserDefaults.standard.dictionaryRepresentation)
            let signInViewController = Object(SignInViewController.self)
            self.navigationController?.setViewControllers([signInViewController], animated: true)
        } catch let error {
            JDB.error("Error login ==>%@", error.localizedDescription)
        }
    }

    @IBAction func btnLayoutAction(_ sender: UIButton) {
        var layout:FeedLayout = .list
        if sender == btnList {
            self.btnList.isSelected = true
            self.btnGrid.isSelected = false
            layout = .list
        }
        else {
            self.btnGrid.isSelected = true
            self.btnList.isSelected = false
            layout = .grid
        }
        self.ref.child(ConstantKey.Users).child(firebaseUser.uid).updateChildValues([ConstantKey.layout:layout.rawValue])
    }
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if let font = textView.font {
//            JDB.log("Line height ==>%@", font.lineHeight)
//        }
//        let numberOFline =  textView.numberOfLines()
//        if numberOFline > 3 {
//            return false
//        }
//        return true
//    }
    func textViewDidEndEditing(_ textView: UITextView) {
        self.ref.child(ConstantKey.Users).child(firebaseUser.uid).updateChildValues([ConstantKey.caption:profileCaptionTextView.text])
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
