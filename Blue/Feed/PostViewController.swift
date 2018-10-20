//
//  PostViewController.swift
//  Blue
//
//  Created by DK on 10/17/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import VGPlayer
import Firebase

class PostViewController: UIViewController {

    
//    var ref: DatabaseReference = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    var shareRef = Database.database().reference().child(ConstantKey.share)
    var notificationRef = Database.database().reference().child(ConstantKey.notification)
    
    
    var object:[String:Any] = [String:Any]()

    
    var player:VGPlayer!
    var playerView : VGEmbedPlayerView!
    

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeImg: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var likebtn: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    
    
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var playerContentView: UIView!
    
    @IBOutlet weak var btnPlayVideo: UIButton!
    
    @IBOutlet weak var btnMore: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setContent()
    }

    
    func setContent() {
        if let user = object[ConstantKey.user] as? [String:Any] {
            self.usernameLbl.text = user[ConstantKey.username] as? String
            if let url = user[ConstantKey.image] as? String {
                self.profileImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
            }
            if let id =  user[ConstantKey.id] as? String , id == firebaseUser.uid {
                self.btnMore.isHidden = false
            }
            else {
                self.btnMore.isHidden = true
            }
        }
        
        if let url = object[ConstantKey.image] as? String {
            if let type = object[ConstantKey.contentType] as? String , type == ConstantKey.video {
                
                let videoURL = URL(string: url)!
                
                playerView = VGEmbedPlayerView()
                player = VGPlayer(playerView: playerView)
                player.backgroundMode = .suspend
                
                self.player.replaceVideo(videoURL)
                
                self.playerContentView.addSubview(self.player.displayView)
                
                if let duration = object[ConstantKey.duration] as? Double , duration < 70 {
                    player.play()
                }
                
                self.player.displayView.snp.remakeConstraints {
                    $0.edges.equalTo(self.playerContentView)
                }
                
                if let thumb = object[ConstantKey.thumb_image] as? String {
                    self.postImg.sd_setImage(with: URL(string: thumb)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
                }
            }
            else {
                self.btnPlayVideo.isHidden = true
                self.postImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
            }
        }
        else {
            self.playerContentView.isHidden = true
        }
        
        self.caption.text = object[ConstantKey.caption] as? String
        
        if let caption = object[ConstantKey.caption] as? String {
            JDB.log("%@", caption)
        }
        
        if let timeStamp = object[ConstantKey.date] as? Double {
            let date = Date(timeIntervalSince1970: timeStamp)
            self.timeAgoLabel.text = Date().offset(from: date) + " ago"
        }
        
        
        //Set Like Button
        if let likes = object[ConstantKey.likes] as? [String] {
            if likes.contains(firebaseUser.uid) {
                self.likeImg.isSelected = false
                self.likeImg.tag = 1
            }
            else {
                self.likeImg.isSelected = true
                self.likeImg.tag = 0
            }
            
            if likes.count == 1 {
                self.likebtn.setTitle("\(likes.count) Like", for: .normal)
            }
            else {
                self.likebtn.setTitle("\(likes.count) Likes", for: .normal)
            }
        }
        else {
            self.likeImg.isSelected = true
            self.likeImg.tag = 0
            self.likebtn.setTitle("0 Like", for: .normal)
        }
        
        //Set Comment button
        if let comment = object[ConstantKey.comment] as? [String] {
            if comment.count == 1 {
                self.btnComment.setTitle("1 comment", for: .normal)
            }
            else {
                self.btnComment.setTitle("\(comment.count) comments", for: .normal)
            }
        }
        else {
            self.btnComment.setTitle("comment", for: .normal)
        }
    }
    
    @IBAction func btnMoreAction(_ sender: UIButton) {
        let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            HUD.show()
            func deleteSharePost() {
                guard let userID = self.object[ConstantKey.userid] as? String else {return}
                guard let postID = self.object[ConstantKey.id] as? String else {return}
                
                self.shareRef.child(userID).observeSingleEvent(of: DataEventType.value, with: { (snap) in
                    if let value = snap.value as? [String:Any] {
                        var sharePostKeys:[String] = [String]()
                        for (k,v) in value {
                            if let sharePost  = v as? [String:Any] {
                                if sharePost[ConstantKey.postID] as! String == postID {
                                    sharePostKeys.append(k)
                                }
                            }
                        }
                        
                        for item in sharePostKeys {
                            self.shareRef.child(userID).child(item).removeValue()
                        }
                        NotificationCenter.default.post(name: NSNotification.Name.RefreshFeedData, object: nil)
                        self.navigationController?.popViewController(animated: true)
                        HUD.dismiss()
                    }
                    else {
                        NotificationCenter.default.post(name: NSNotification.Name.RefreshFeedData, object: nil)
                        self.navigationController?.popViewController(animated: true)
                        HUD.dismiss()
                    }
                })
            }
            
            func deletePost() {
                guard let userID = self.object[ConstantKey.userid] as? String else {return}
                guard let postID = self.object[ConstantKey.id] as? String else {return}
                self.feedRef.child(userID).child(postID).removeValue(completionBlock: { (error, ref) in
                    deleteSharePost()
                })
            }
            
            if let image = self.object[ConstantKey.image] as? String  {
                let storage = Storage.storage()
                if let type = self.object[ConstantKey.contentType] as? String , type == ConstantKey.video {
                    if let thumb = self.object[ConstantKey.thumb_image] as? String {
                        let storageRef = storage.reference(forURL: thumb)
                        storageRef.delete(completion: { (error) in
                            let storageRef = storage.reference(forURL: image)
                            storageRef.delete(completion: { (error) in
                                deletePost()
                            })
                        })
                    }
                }
                else {
                    let storageRef = storage.reference(forURL: image)
                    storageRef.delete(completion: { (error) in
                        deletePost()
                    })
                }
            }
            else {
                deletePost()
            }
            JDB.log("Delete Object ==>%@", self.object)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            
        }
        self.showAlert(message: "Are you sure to delete post ?", actions: yesAction,noAction)
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        if object[ConstantKey.likes] != nil {
            let likeVC = Object(LikeViewController.self)
            likeVC.user = object
            self.navigationController?.pushViewController(likeVC, animated: true)
        }
    }
    
    @IBAction func btnUserProfileAction(_ sender: UIButton) {
        if object[ConstantKey.userid] != nil {
            if let id = object[ConstantKey.userid] as? String {
                if id == firebaseUser.uid {
                    let profile = Object(ProfileViewController.self)
                    profile.isOtherUserProfile = false
                    self.navigationController?.pushViewController(profile, animated: true)
                }
                else {
                    self.userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
                        if let value = snapshot.value as? [String:Any] {
                            let profile = Object(ProfileViewController.self)
                            profile.isOtherUserProfile = true
                            profile.userProfileData = NSMutableDictionary(dictionary: value)
                            self.navigationController?.pushViewController(profile, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnLikeHeartAction(_ sender: UIButton) {
        var likes = NSMutableArray()
        if let like = object[ConstantKey.likes] as? NSArray {
            likes = NSMutableArray(array: like)
        }
        let feedID = object[ConstantKey.id] as! String
        let userID = object[ConstantKey.userid] as! String
        
        if self.likeImg.tag == 0 {
            likes.add(firebaseUser.uid)
            object[ConstantKey.likes] = likes
            self.feedRef.child(userID).child(feedID).updateChildValues([ConstantKey.likes:likes]) { (error, refrance) in
                if error == nil {
                    self.likeImg.isSelected = false
                    self.likeImg.tag = 1
                    self.sendLikeNotification()
                }
            }
        }
        else {
            likes.remove(firebaseUser.uid)
            object[ConstantKey.likes] = likes
            self.feedRef.child(userID).child(feedID).updateChildValues([ConstantKey.likes:likes]) { (error, refrance) in
                if error == nil {
                    self.likeImg.isSelected = true
                    self.likeImg.tag = 0
                }
            }
        }
        self.setContent()
    }
    
    @IBAction func btnCommentAction(_ sender: UIButton) {
        if object[ConstantKey.userid] != nil {
            if let id = object[ConstantKey.userid] as? String {
                if id == firebaseUser.uid {
                    let commentVC = Object(CommentVC.self)
                    commentVC.post = object
                    commentVC.user = object[ConstantKey.user] as! [String:Any]
                    self.navigationController?.pushViewController(commentVC, animated: true)
                }
                else {
                    self.userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
                        if let value = snapshot.value as? [String:Any] {
                            let commentVC = Object(CommentVC.self)
                            commentVC.post = self.object
                            commentVC.user = value
                            self.navigationController?.pushViewController(commentVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    func sendLikeNotification() {
        let adminUserID = object[ConstantKey.userid] as! String
        let likedUserID = firebaseUser.uid
        
        //        if adminUserID != likedUserID {
        var json = [String:Any]()
        if object[ConstantKey.image] != nil {
            if let type = object[ConstantKey.contentType] as? String , type == ConstantKey.video {
            }
            else {
                json[ConstantKey.image] = object[ConstantKey.image]
            }
        }
        json[ConstantKey.id] = likedUserID
        json[ConstantKey.date] = Date().timeStamp
        json[ConstantKey.contentType] = NotificationType.like.rawValue
        self.notificationRef.child(adminUserID).child(object[ConstantKey.id] as! String).setValue(json) { (error, ref) in
            if error == nil {
                
            }
        }
        //        }
        
        self.userRef.child(adminUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? [String:Any] else {return}
            var notificationCount = 0
            if let count = user[ConstantKey.unreadCount] as? Int {
                notificationCount = count
            }
            notificationCount = notificationCount + 1
            self.userRef.child(adminUserID).updateChildValues([ConstantKey.unreadCount:notificationCount])
        }
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        if object[ConstantKey.userid] != nil {
            if let id = object[ConstantKey.userid] as? String {
                if id == firebaseUser.uid {
                    let sharePostVC = Object(SharePostViewController.self)
                    sharePostVC.post = self.object
                    sharePostVC.user = object[ConstantKey.user] as! [String:Any]
                    self.navigationController?.pushViewController(sharePostVC, animated: true)
                }
                else {
                    self.userRef.child(id).observeSingleEvent(of: .value) { (snapshot) in
                        if let value = snapshot.value as? [String:Any] {
                            let sharePostVC = Object(SharePostViewController.self)
                            sharePostVC.post = self.object
                            sharePostVC.user = value
                            self.navigationController?.pushViewController(sharePostVC, animated: true)
                        }
                    }
                }
            }
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
