//
//  ShareTableViewCell.swift
//  Blue
//
//  Created by DK on 9/13/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import VGPlayer
import Firebase

class ShareTableViewCell: UITableViewCell {
    @IBOutlet weak var shareUserImageView: UIImageView!
    @IBOutlet weak var shareUserNameLabel: UILabel!
    @IBOutlet weak var shareUserDateLabel: UILabel!
    
    @IBOutlet weak var adminUserImageView: UIImageView!
    @IBOutlet weak var adminUserNameLabel: UILabel!
    @IBOutlet weak var adminDateLabel: UILabel!
    
    
    @IBOutlet weak var btnFeedComment: UIButton!
    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var btnLikeImage: UIButton!
    
    @IBOutlet weak var shareCaptionLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: VGPlayerView!
    
    var player:VGPlayer?
    
    var postType:PostType = .caption
    
    var delegate:FeedPostCellDelegate? = nil
    
    var ref: DatabaseReference = Database.database().reference()
    
    var post:[String:Any] = [String:Any]()
    
    var adminUser:[String:Any] = [String:Any]()
    
    var object:[String:Any] = [String:Any]() {
        didSet(newValue){
            let shareUserID = object[ConstantKey.id] as! String
            let postUserID = object[ConstantKey.userid] as! String
            let postID = object[ConstantKey.postID] as! String
            
            self.shareCaptionLabel.text = object[ConstantKey.caption] as? String
            if let timeStamp = object[ConstantKey.date] as? Double {
                let date = Date(timeIntervalSince1970: timeStamp)
                self.shareUserDateLabel.text = Date().offset(from: date) + " ago"
            }
            
            self.ref.child(ConstantKey.feed).child(postUserID).child(postID).observe(.value) { (snapshot) in
                guard let post = snapshot.value as? [String:Any] else {return}
                self.post = post
                
                if let url = post[ConstantKey.image] as? String {
                    if self.postType == .video {
                        self.player?.replaceVideo(URL(string: url)!)
                    }
                    else if self.postType == .image {
                        self.feedImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
                    }
                }
                
                self.captionLabel.text = post[ConstantKey.caption] as? String
                
                if let timeStamp = post[ConstantKey.date] as? Double {
                    let date = Date(timeIntervalSince1970: timeStamp)
                    self.adminDateLabel.text = Date().offset(from: date) + " ago"
                }
                
                //Set Like Button
                if let likes = post[ConstantKey.likes] as? NSArray {
                    if likes.contains(firebaseUser.uid) {
                        self.btnLikeImage.isSelected = false
                        self.btnLikeImage.tag = 1
                    }
                    else {
                        self.btnLikeImage.isSelected = true
                        self.btnLikeImage.tag = 0
                    }
                    
                    if likes.count == 1 {
                        self.btnLikeCount.setTitle("\(likes.count) Like", for: .normal)
                    }
                    else {
                        self.btnLikeCount.setTitle("\(likes.count) Likes", for: .normal)
                    }
                }
                else {
                    self.btnLikeImage.isSelected = true
                    self.btnLikeImage.tag = 0
                    self.btnLikeCount.setTitle("0 Like", for: .normal)
                }
                
                //Set Comment button
                if let comment = post[ConstantKey.comment] as? [String] {
                    if comment.count == 1 {
                        self.btnFeedComment.setTitle("1 comment", for: .normal)
                    }
                    else {
                        self.btnFeedComment.setTitle("\(comment.count) comments", for: .normal)
                    }
                }
                else {
                    self.btnFeedComment.setTitle("comment", for: .normal)
                }
            }
            
            self.ref.child(ConstantKey.Users).child(postUserID).observeSingleEvent(of: .value) { (snapshot) in
                guard let postUser = snapshot.value as? [String:Any] else {return}
                self.adminUser = postUser
                
                self.adminUserNameLabel.text = postUser[ConstantKey.username] as? String
                if let url = postUser[ConstantKey.image] as? String {
                    self.adminUserImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
            
            self.ref.child(ConstantKey.Users).child(shareUserID).observeSingleEvent(of: .value) { (snapshot) in
                guard let shareUser = snapshot.value as? [String:Any] else {return}
                self.shareUserNameLabel.text = shareUser[ConstantKey.username] as? String
                if let url = shareUser[ConstantKey.image] as? String {
                    self.shareUserImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let playerView = videoPlayerView {
            self.player = VGPlayer(playerView: playerView)
        }
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        if object[ConstantKey.likes] != nil {
            if let delegate = self.delegate {
                delegate.feedLikeDidSelect(user: object)
            }
        }
    }
    
    @IBAction func btnUserProfileAction(_ sender: UIButton) {
        if object[ConstantKey.userid] != nil {
            if let delegate = self.delegate {
                if let id = object[ConstantKey.userid] as? String {
                    if id == firebaseUser.uid {
                        delegate.feedProfileDidSelect(user: object)
                    }
                    else {
                        self.ref.child(ConstantKey.Users).child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String:Any] {
                                self.delegate?.feedProfileDidSelect(user: value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func btnLikeHeartAction(_ sender: UIButton) {
        var likes = NSMutableArray()
        if let like = self.post[ConstantKey.likes] as? NSArray {
            likes = NSMutableArray(array: like)
        }
        let feedID = self.post[ConstantKey.id] as! String
        let userID = self.post[ConstantKey.userid] as! String
        
        if self.btnLikeImage.tag == 0 {
            likes.add(firebaseUser.uid)
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).updateChildValues([ConstantKey.likes:likes]) { (error, refrance) in
                if error == nil {
                    self.btnLikeImage.isSelected = false
                    self.btnLikeImage.tag = 1
                    self.sendLikeNotification()
                }
            }
        }
        else {
            likes.remove(firebaseUser.uid)
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).updateChildValues([ConstantKey.likes:likes]) { (error, refrance) in
                if error == nil {
                    self.btnLikeImage.isSelected = true
                    self.btnLikeImage.tag = 0
                }
            }
        }
    }
    
    @IBAction func btnCommentAction(_ sender: UIButton) {
        if self.post[ConstantKey.userid] != nil {
            if let delegate = self.delegate {
                if let id = self.post[ConstantKey.userid] as? String {
                    if id == firebaseUser.uid {
                        delegate.feedCommentDidSelect(post: self.post, user: self.adminUser)
                    }
                    else {
                        self.ref.child(ConstantKey.Users).child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String:Any] {
                                self.delegate?.feedCommentDidSelect(post: self.post, user: value)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func sendLikeNotification() {
        let adminUserID = self.post[ConstantKey.userid] as! String
        let likedUserID = firebaseUser.uid
        if adminUserID != likedUserID {
            var json = [String:Any]()
            if self.post[ConstantKey.image] != nil {
                if let type = self.post[ConstantKey.contentType] as? String , type == ConstantKey.video {
                }
                else {
                    json[ConstantKey.image] = self.post[ConstantKey.image]
                }
            }
            json[ConstantKey.id] = likedUserID
            json[ConstantKey.date] = Date().timeStamp
            json[ConstantKey.contentType] = NotificationType.like.rawValue
            self.ref.child(ConstantKey.notification).child(adminUserID).child(self.post[ConstantKey.id] as! String).setValue(json) { (error, ref) in
                if error == nil {
                    
                }
            }
        }
    }
    
//    @IBAction func btnShareAction(_ sender: UIButton) {
//        if object[ConstantKey.userid] != nil {
//            if let delegate = self.delegate {
//                if let id = object[ConstantKey.userid] as? String {
//                    if id == firebaseUser.uid {
//                        delegate.feedShareDidSelect(post: object, user: object[ConstantKey.user] as! [String:Any])
//                    }
//                    else {
//                        self.ref.child(ConstantKey.Users).child(id).observeSingleEvent(of: .value) { (snapshot) in
//                            if let value = snapshot.value as? [String:Any] {
//                                self.delegate?.feedShareDidSelect(post: self.object, user: value)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}
