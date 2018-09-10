//
//  Profile.swift
//  Blue
//
//  Created by Tim Schönenberger on 05.08.18.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage
import VGPlayer


class ProfileViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate , UITableViewDelegate , UITableViewDataSource , FeedPostCellDelegate {
    
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var followStackView: UIStackView!

    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    
    var feedData:[[String:Any]] = [[String:Any]]()
    var allFeed:NSDictionary = NSDictionary()
    
    var isOtherUserProfile:Bool = false
    var userProfileData:NSMutableDictionary = NSMutableDictionary()
    
    var followers:[[String:Any]] = [[String:Any]]()
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCell")
        self.tableView.register(UINib(nibName: "PostWithOutImageCell", bundle: Bundle.main), forCellReuseIdentifier: "PostWithOutImageCell")
        
        self.tableView.isHidden = true
        if isOtherUserProfile {
            self.checkFollow()
            self.getNumberOfPost()
            if let url = userProfileData.value(forKey: ConstantKey.image) as? String {
                self.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
            }
            self.userNameLabel.text = userProfileData.value(forKey: ConstantKey.username) as? String
            self.btnFollow.isHidden = false
        }
        else {
            if let url = firebaseUser.photoURL {
                self.profileImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
            }
            self.userNameLabel.text = firebaseUser.displayName
            self.btnFollow.isHidden = true
            self.getFeed()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let parent = self.parent as? PageViewController {
            let settingItem:UIBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnSettingAction(_:)))
            parent.navigationItem.title = "Profile"
            parent.navigationItem.leftBarButtonItem = nil
            parent.navigationItem.rightBarButtonItem = settingItem
        }
        else {
            self.navigationItem.title = "Profile"
        }
        
        self.getFollowing()
        self.getFollowers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let parent = self.parent as? PageViewController {
            
            let settingItem:UIBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnSettingAction(_:)))
            
            parent.navigationItem.title = "Profile"
            parent.navigationItem.leftBarButtonItem = nil
            parent.navigationItem.rightBarButtonItem = settingItem
        }
        else {
            self.navigationItem.title = "Profile"
        }
    }
    @objc func btnSettingAction(_ sender:UIButton) {
        let object = Object(SettingViewController.self)
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    @IBAction func imageViewDidTapAction(_ sender: UITapGestureRecognizer) {
        if isOtherUserProfile == true {
            return
        }
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Camera", style: .default) { (cameraAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let GalleryAction = UIAlertAction(title: "Photo Library", style: .default) { (gallery) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            
        }
        
        actionSheet.addAction(action)
        actionSheet.addAction(GalleryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true) {}
    }
    @IBAction func btnFollowAction(_ sender: UIButton) {
        if sender.tag == 0 {
            BasicStuff.shared.followArray.add(userProfileData.value(forKey: ConstantKey.id) as! String)
        }
        else {
            BasicStuff.shared.followArray.remove(userProfileData.value(forKey: ConstantKey.id) as! String)
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

    @IBAction func btnFollowersAction(_ sender: UIButton) {
        let action = Object(FollwersViewController.self)
        action.followers = followers
        self.navigationController?.pushViewController(action, animated: true)
    }
    
    @IBAction func btnFollowingAction(_ sender:UIButton) {
        if self.isOtherUserProfile {
            if let following = userProfileData.value(forKey: ConstantKey.follow) as? NSArray {
                if following.count > 0 {
                    let followingVC = Object(FollowingViewController.self)
                    followingVC.followingUsers = following.map({$0 as! String})
                    self.navigationController?.pushViewController(followingVC, animated: true)
                }
                else {
                    return
                }
            }
            else {
                return
            }
        }
        else {
            if BasicStuff.shared.followArray.count > 0 {
                let followingVC = Object(FollowingViewController.self)
                followingVC.followingUsers = BasicStuff.shared.followArray.map({$0 as! String})
                self.navigationController?.pushViewController(followingVC, animated: true)
            }
            else {
                return
            }
        }
    }
    
    func checkFollow() {
        if BasicStuff.shared.followArray.contains(userProfileData.value(forKey: ConstantKey.id) as! String) {
            self.btnFollow.tag = 1
            self.btnFollow.setTitle("Following", for: .normal)
        }
        else {
            self.btnFollow.tag = 0
            self.btnFollow.setTitle("Follow", for: .normal)
        }
    }
    func getFeed() {
        self.feedData = [[String:Any]]()
        self.userRef.child(firebaseUser.uid).observe(.value) { (snapshot) in
            self.feedRef.child(firebaseUser.uid).observe(.value, with: { (snap) in
                if let value = snap.value as? [String:Any] {
                    for (k,v) in value {
                        if var data = v as? [String:Any] {
                            data[ConstantKey.user] = snapshot.value
                            data[ConstantKey.id] = k
                            if let index = self.feedData.index(where: {($0[ConstantKey.id] as! String) == k}) {
                                self.feedData.remove(at: index)
                            }
                            self.feedData.append(data)
                        }
                    }
                }
                
                let sortedArray = self.feedData.sorted(by: {(one , two) in
                    return  (one["date"] as! String).date > (two["date"] as! String).date
                })
                self.feedData = sortedArray
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    if self.feedData.count > 0 {
                        self.tableView.isHidden = false
                    }
                    else {
                        self.tableView.isHidden = true
                    }
                    self.postLabel.text = "\(self.feedData.count)"
                })
            })
        }
    }
    func getFollowing() {
        if self.isOtherUserProfile {
            if let following = userProfileData.value(forKey: ConstantKey.follow) as? NSArray {
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
                                id = self.userProfileData[ConstantKey.id] as! String
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
    
    func getNumberOfPost() {
        let userID = userProfileData.value(forKey: ConstantKey.id) as! String
        self.feedRef.child(userID).observeSingleEvent(of: .value) { (snap) in
            self.postLabel.text = "\(snap.childrenCount)"
        }
    }
    //MARK:- UIImagepickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = image
            
            HUD.show()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueFileName())
            let storageMetaData = StorageMetadata()
            storageMetaData.contentType = "image/png"
            
            imageRef.putData(UIImageJPEGRepresentation(image, 0.8)!, metadata: storageMetaData) { (metadata, error) in
                if metadata == nil {
                    HUD.dismiss()
                    return
                }
                DispatchQueue.main.async {
                    imageRef.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            HUD.dismiss()
                            return
                        }
                        DispatchQueue.main.async {
                            let changeRequest = firebaseUser.createProfileChangeRequest()
                            changeRequest.photoURL = downloadURL
                            changeRequest.commitChanges { error in
                                HUD.dismiss()
                                if error == nil {
                                    let json = [ConstantKey.id:firebaseUser.uid,
                                                ConstantKey.username:firebaseUser.displayName ?? "",
                                                ConstantKey.image:downloadURL.absoluteString,
                                                ConstantKey.email:firebaseUser.email ?? ""]
                                    
                                    self.userRef.child(firebaseUser.uid).setValue(json, withCompletionBlock: { (error, databaseRef) in
                                        HUD.dismiss()
                                        guard let error = error else {
                                            self.showAlert("Profile picture uploaded successfully")
                                            return
                                        }
                                        JDB.error("Data base error ==>%@", error.localizedDescription)
                                    })
                                } else {
                                    print("Error: \(error!.localizedDescription)")
                                }
                            }
                        }
                    })
                }
            }
        }
        
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feed = self.feedData[indexPath.row]
        if feed[ConstantKey.image] != nil {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.object = feed
            cell.delegate = self
            cell.likeImg.isUserInteractionEnabled = false
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostWithOutImageCell", for: indexPath) as! PostWithOutImageCell
            cell.object = feed
            cell.delegate = self
            cell.likeImg.isUserInteractionEnabled = false
            return cell
        }
    }
    
    //MARK:- FeedPostCellDelegate
    func feedLikeDidSelect(user: [String : Any]) {
        let likeVC = Object(LikeViewController.self)
        likeVC.user = user
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    
    func feedProfileDidSelect(user: [String : Any]) {
        let profile = Object(ProfileViewController.self)
        if let id = user[ConstantKey.userid] as? String ,id == firebaseUser.uid {
            profile.isOtherUserProfile = false
        }
        else {
            profile.isOtherUserProfile = true
            profile.userProfileData = NSMutableDictionary(dictionary: user)
        }
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    func feedCommentDidSelect(post: [String : Any], user: [String : Any]) {
        let commentVC = Object(CommentVC.self)
        commentVC.post = post
        self.navigationController?.pushViewController(commentVC, animated: true)
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

