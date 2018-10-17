//
//  PostCell.swift
//  Blue
//
//  Created by Tim Schönenberger on 04.08.18.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import Firebase
import UIKit
import SDWebImage
import VGPlayer

enum PostType:Int {
    case caption = 0
    case image
    case video
}

enum NotificationType:Int {
    case follow = 0
    case like
    case comment
}

protocol FeedPostCellDelegate {
    func feedLikeDidSelect(user:[String:Any])
    func feedProfileDidSelect(user:[String:Any])
    func feedCommentDidSelect(post:[String:Any],user:[String:Any])
    func feedShareDidSelect(post:[String:Any],user:[String:Any])
}
class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeImg: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var likebtn: UIButton!
    @IBOutlet weak var btnComment: UIButton!
    
    
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var playerContentView: UIView!
    
    var type:PostType = .caption
    
    var videoURL:URL?
    var autoPlay:Bool = false
    var indexPath:IndexPath!
    
    //var post: Post!
    var ref: DatabaseReference = Database.database().reference()
    var delegate:FeedPostCellDelegate? = nil
    
    var playCallBack:((IndexPath?) -> Swift.Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    var object:[String:Any]  = [String:Any]() {
        didSet(newValue) {
            if let user = object[ConstantKey.user] as? [String:Any] {
                self.usernameLbl.text = user[ConstantKey.username] as? String
                if let url = user[ConstantKey.image] as? String {
                    self.profileImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
            
            if let url = object[ConstantKey.image] as? String {
                if type == .video {
                    self.videoURL = URL(string: url)!
                    
                    if let duration = object[ConstantKey.duration] as? Double , duration < 70 {
                        self.autoPlay = true
                    }
                    else {
                        self.autoPlay = false
                    }
                    if let thumb = object[ConstantKey.thumb_image] as? String {
                        self.postImg.sd_setImage(with: URL(string: thumb)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
                    }
                }
                else if type == .image {
                    self.postImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
                }
            }
            
            self.caption.text = object[ConstantKey.caption] as? String
            self.caption.isUserInteractionEnabled = false
            
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
    }
    
    @IBAction func btnPlayVideoAction(_ sender: UIButton) {
        if let callback = self.playCallBack {
            callback(indexPath)
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
        if let like = object[ConstantKey.likes] as? NSArray {
            likes = NSMutableArray(array: like)
        }
        let feedID = object[ConstantKey.id] as! String
        let userID = object[ConstantKey.userid] as! String
        
        if self.likeImg.tag == 0 {
            likes.add(firebaseUser.uid)
            object[ConstantKey.likes] = likes
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).updateChildValues([ConstantKey.likes:likes]) { (error, refrance) in
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
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).updateChildValues([ConstantKey.likes:likes]) { (error, refrance) in
                if error == nil {
                    self.likeImg.isSelected = true
                    self.likeImg.tag = 0
                }
            }
        }
    }
    
    @IBAction func btnCommentAction(_ sender: UIButton) {
        if object[ConstantKey.userid] != nil {
            if let delegate = self.delegate {
                if let id = object[ConstantKey.userid] as? String {
                    if id == firebaseUser.uid {
                        delegate.feedCommentDidSelect(post: object, user: object[ConstantKey.user] as! [String:Any])
                    }
                    else {
                        self.ref.child(ConstantKey.Users).child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String:Any] {
                                self.delegate?.feedCommentDidSelect(post: self.object, user: value)
                            }
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
            self.ref.child(ConstantKey.notification).child(adminUserID).child(object[ConstantKey.id] as! String).setValue(json) { (error, ref) in
                if error == nil {
                    
                }
            }
//        }
        
        self.ref.child(ConstantKey.Users).child(adminUserID).observeSingleEvent(of: .value) { (snapshot) in
            guard let user = snapshot.value as? [String:Any] else {return}
            var notificationCount = 0
            if let count = user[ConstantKey.unreadCount] as? Int {
                notificationCount = count
            }
            notificationCount = notificationCount + 1
            self.ref.child(ConstantKey.Users).child(adminUserID).updateChildValues([ConstantKey.unreadCount:notificationCount])
        }
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        if object[ConstantKey.userid] != nil {
            if let delegate = self.delegate {
                if let id = object[ConstantKey.userid] as? String {
                    if id == firebaseUser.uid {
                        delegate.feedShareDidSelect(post: object, user: object[ConstantKey.user] as! [String:Any])
                    }
                    else {
                        self.ref.child(ConstantKey.Users).child(id).observeSingleEvent(of: .value) { (snapshot) in
                            if let value = snapshot.value as? [String:Any] {
                                self.delegate?.feedShareDidSelect(post: self.object, user: value)
                            }
                        }
                    }
                }
            }
        }
    }
}
