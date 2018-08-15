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

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    //var post: Post!
    var ref: DatabaseReference = Database.database().reference()
    
    var object:[String:Any]  = [String:Any]() {
        didSet(newValue) {
            if let user = object[ConstantKey.user] as? [String:Any] {
                self.usernameLbl.text = user[ConstantKey.username] as? String
                if let url = user[ConstantKey.image] as? String {
                    self.profileImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
            if let url = object[ConstantKey.image] as? String {
                self.postImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
            }
            
            self.caption.text = object[ConstantKey.caption] as? String
            self.timeAgoLabel.text = Date().offset(from: (object[ConstantKey.date] as! String).date) + " ago"
            if let likes = object[ConstantKey.likes] as? NSArray {
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
        if let like = object[ConstantKey.likes] as? NSArray {
            likes = NSMutableArray(array: like)
        }
        let feedID = object[ConstantKey.id] as! String
        let userID = object[ConstantKey.userid] as! String
        
        if self.likeImg.tag == 0 {
            likes.add(firebaseUser.uid)
            object[ConstantKey.likes] = likes
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).setValue(object) { (error, refrance) in
                if error == nil {
                    self.likeImg.image = #imageLiteral(resourceName: "Filledheart")
                    self.likeImg.tag = 1
                }
            }
        }
        else {
            likes.remove(firebaseUser.uid)
            object[ConstantKey.likes] = likes
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).setValue(object) { (error, refrance) in
                if error == nil {
                    self.likeImg.image = #imageLiteral(resourceName: "Heart unfilled")
                    self.likeImg.tag = 0
                }
            }
        }
    }
}


    
    
    
    


