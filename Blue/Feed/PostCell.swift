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
import PINRemoteImage


class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    //var post: Post!
    var ref: DatabaseReference = Database.database().reference()
    
    var object:NSMutableDictionary  = NSMutableDictionary() {
        didSet(newValue) {
            if let user = object.value(forKey: ConstantKey.user) as? NSDictionary {
                self.usernameLbl.text = user.value(forKey: ConstantKey.username) as? String
            }
            
            if let id = object.value(forKey: ConstantKey.userid) as? String {
                self.ref.child(ConstantKey.Users).child(id).observeSingleEvent(of: DataEventType.value) { (snapshot) in
                    if let snap = snapshot.value as? NSDictionary {
                        self.usernameLbl.text = snap.value(forKey: ConstantKey.username) as? String
                        if let url = snap.value(forKey: ConstantKey.image) as? String {
                            self.profileImg.pin_setImage(from: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"))
                        }
                    }
                }
            }
            

            if let url = object.value(forKey: ConstantKey.image) as? String {
                self.postImg.pin_setImage(from: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"))
            }
            
            self.caption.text = object.value(forKey: ConstantKey.caption) as? String
            
            if let likes = object.value(forKey: ConstantKey.likes) as? NSArray {
                if likes.contains(firebaseUser.uid) {
                    self.likeImg.image = #imageLiteral(resourceName: "Filledheart")
                    self.likeImg.tag = 1
                }
                else {
                    self.likeImg.image = #imageLiteral(resourceName: "Heart unfilled")
                    self.likeImg.tag = 0
                }
                
                self.likeLbl.text = "\(likes.count) Likes"
            }
            else {
                self.likeImg.image = #imageLiteral(resourceName: "Heart unfilled")
                self.likeImg.tag = 0
                self.likeLbl.text = "0 Likes"
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    
    @objc func likeTapped(sender: UITapGestureRecognizer) {
        var likes = NSMutableArray()
        if let like = object.value(forKey: ConstantKey.likes) as? NSArray {
            likes = NSMutableArray(array: like)
        }
        
        let feedID = object.value(forKey: ConstantKey.id) as! String
        if self.likeImg.tag == 0 {
            likes.add(firebaseUser.uid)
            object.setValue(likes, forKey: ConstantKey.likes)
            self.ref.child(ConstantKey.feed).child(feedID).setValue(object) { (error, refrance) in
                if error == nil {
                    self.likeImg.image = #imageLiteral(resourceName: "Filledheart")
                    self.likeImg.tag = 1
                }
            }
        }
        else {
            likes.remove(firebaseUser.uid)
            object.setValue(likes, forKey: ConstantKey.likes)
            self.ref.child(ConstantKey.feed).child(feedID).setValue(object) { (error, refrance) in
                if error == nil {
                    self.likeImg.image = #imageLiteral(resourceName: "Heart unfilled")
                    self.likeImg.tag = 0
                }
            }
        }
        
//        self.ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            if let _ = snapshot.value as? NSNull {
//                self.likeImg.image = UIImage(named: "filled-heart")
//              //  self.post.adjustLikes(addLike: true)
//                self.likesRef.setValue(true)
//            } else {
//                self.likeImg.image = UIImage(named: "empty-heart")
//             //   self.post.adjustLikes(addLike: false)
//                self.likesRef.removeValue()
//            }
//        })
    }
    
    
    
    
    
    
    
    
    
//    // Handles Likes
//    
//    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
//    if let _ = snapshot.value as? NSNull {
//    self.likeImg.image = UIImage(named: "empty-heart")
//    } else {
//    self.likeImg.image = UIImage(named: "filled-heart")
//    }
//    })
}


    
    
    
    


