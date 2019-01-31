//
//  ProfileHeaderViewController.swift
//  Blue
//
//  Created by DK on 1/21/19.
//  Copyright © 2019 Tim. All rights reserved.
//

import UIKit
import Firebase

class ProfileHeaderViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var followStackView: UIStackView!
    
    
//    @IBOutlet weak var captionLabel: UILabel!
    
    var ref = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    
    var userData:[String:Any] = [String:Any]()
    var isOtherUserProfile:Bool = false
    
    var followers:[[String:Any]] = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isOtherUserProfile {
            
            self.checkFollow()
            //self.getNumberOfPost()
            
            if let url = userData[ConstantKey.image] as? String , url != "" {
                self.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
            }
            self.userNameLabel.text = userData[ConstantKey.username] as? String
//            self.captionLabel.text = userData[ConstantKey.caption] as? String
            
        }
        else {
            self.btnFollow.setTitle("Settings", for: .normal)
            self.btnFollow.borderColor = UIColor("4A4A4A")
            self.btnFollow.setTitleColor(UIColor("4A4A4A"), for: .normal)
            self.btnFollow.backgroundColor = .clear
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isOtherUserProfile == false {
            self.userRef.child(firebaseUser.uid).observeSingleEvent(of: .value) { (snapshot) in
                guard let userData = snapshot.value as? [String:Any] else {return}
                if let image = userData[ConstantKey.image] as? String {
                    self.profileImageView.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
                self.userNameLabel.text = userData[ConstantKey.username] as? String
                self.userData = userData
                
                //self.getNumberOfPost()
            }
        }
        
       // self.getFollowers()
       // self.getFollowing()
    }
    
    @IBAction func btnFollowAction(_ sender: UIButton) {
        if self.isOtherUserProfile == false {
            if let segment = self.parent as? ProfileSegmentViewController {
                segment.isBackFromSetting = true
            }
            self.btnSettingAction(sender)
            return
        }
        else if sender.tag == 0 {
            BasicStuff.shared.followArray.add(userData[ConstantKey.id] as! String)
            self.sendFollowNotification()
        }
        else {
            BasicStuff.shared.followArray.remove(userData[ConstantKey.id] as! String)
        }
        BasicStuff.shared.UserData.setValue(BasicStuff.shared.followArray, forKey: ConstantKey.follow)
        
        HUD.show()
        self.userRef.child(firebaseUser.uid).setValue(BasicStuff.shared.UserData) { (error, ref) in
            HUD.dismiss()
            if error == nil  {
                self.checkFollow()
            }
        }
    }
    
    func sendFollowNotification() {
        let adminUserID = userData[ConstantKey.id] as! String
        let followUserID = firebaseUser.uid
        if adminUserID != followUserID {
            var json = [String:Any]()
            json[ConstantKey.image] = userData[ConstantKey.image]
            json[ConstantKey.id] = followUserID
            json[ConstantKey.date] = Date().timeStamp
            json[ConstantKey.contentType] = NotificationType.follow.rawValue
            self.ref.child(ConstantKey.notification).child(adminUserID).child(adminUserID).setValue(json) { (error, ref) in
                if error == nil {
                    
                }
            }
        }
    }
    
    @objc func btnSettingAction(_ sender:UIButton) {
        let object = Object(SettingViewController.self)
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    func checkFollow() {
        if BasicStuff.shared.followArray.contains(userData[ConstantKey.id] as! String) {
            self.btnFollow.tag = 1
            self.btnFollow.setTitle("Following", for: .normal)
//            self.btnFollow.borderColor = UIColor("54C7FC")
            self.btnFollow.setTitleColor(.black, for: .normal)
            self.btnFollow.setBackgroundImage(UIImage(named: "following"), for: UIControl.State.normal)
        }
        else {
            self.btnFollow.tag = 0
            self.btnFollow.setTitle("Follow", for: .normal)
            //self.btnFollow.borderColor = UIColor("54C7FC")
            self.btnFollow.setTitleColor(.white, for: .normal)
//            self.btnFollow.backgroundColor = UIColor("54C7FC")
            self.btnFollow.setBackgroundImage(UIImage(named: "Rectangle"), for: UIControl.State.normal)
            
        }
    }
    
//    func getNumberOfPost() {
//        let userID = userData[ConstantKey.id] as! String
//        self.feedRef.child(userID).observeSingleEvent(of: .value) { (snap) in
//            self.postLabel.text = "\(snap.childrenCount)"
//        }
//    }
    
    func getFollowing() {
        if self.isOtherUserProfile {
            if let following = userData[ConstantKey.follow] as? NSArray {
                self.followingLabel.text = "\(following.count)"
            }
            else {
                self.followingLabel.text = "0"
            }
        }
        else {
            self.followingLabel.text = "\(BasicStuff.shared.followArray.count)"
        }
    }
    
    func getFollowers() {
        self.followers = [[String:Any]]()
        self.userRef.observe(.value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                if let allUsersValue = value.allValues as? [[String:Any]] {
                    self.followers = [[String:Any]]()
                    for item in allUsersValue {
                        if let follow = item[ConstantKey.follow] as? [String] {
                            var id = firebaseUser.uid
                            if self.isOtherUserProfile {
                                id = self.userData[ConstantKey.id] as! String
                            }
                            if follow.contains(id) {
                                self.followers.append(item)
                            }
                        }
                    }
                }
            }
            self.followersLabel.text = "\(self.followers.count)"
        }
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
