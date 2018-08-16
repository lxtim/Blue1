//
//  PostWithOutImageCell.swift
//  Blue
//
//  Created by DK on 8/16/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class PostWithOutImageCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likebtn: UIButton!
    @IBOutlet weak var likeImg: UIButton!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    var ref: DatabaseReference = Database.database().reference()
    
    var delegate:FeedPostCellDelegate? = nil
    
    var object:[String:Any]  = [String:Any]() {
        didSet(newValue) {
            if let user = object[ConstantKey.user] as? [String:Any] {
                self.usernameLbl.text = user[ConstantKey.username] as? String
                if let url = user[ConstantKey.image] as? String {
                    self.profileImg.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
            self.caption.text = object[ConstantKey.caption] as? String
            self.timeAgoLabel.text = Date().offset(from: (object[ConstantKey.date] as! String).date) + " ago"
            if let likes = object[ConstantKey.likes] as? NSArray {
                if likes.contains(firebaseUser.uid) {
                    self.likeImg.setImage(#imageLiteral(resourceName: "Filledheart"), for: .normal)
                    self.likeImg.tag = 1
                }
                else {
                    self.likeImg.setImage(#imageLiteral(resourceName: "Heart unfilled"), for: .normal)
                    self.likeImg.tag = 0
                }
                
                self.likebtn.setTitle("\(likes.count) Likes", for: .normal)
            }
            else {
                self.likeImg.setImage(#imageLiteral(resourceName: "Heart unfilled"), for: .normal)
                self.likeImg.tag = 0
                self.likebtn.setTitle("0 Likes", for: .normal)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func btnLikeAction(_ sender: UIButton) {
        if object[ConstantKey.likes] != nil {
            if let delegate = self.delegate {
                delegate.postcellDidSelectLike(user: object)
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
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).setValue(object) { (error, refrance) in
                if error == nil {
                    self.likeImg.setImage(#imageLiteral(resourceName: "Filledheart"), for: .normal)
                    self.likeImg.tag = 1
                }
            }
        }
        else {
            likes.remove(firebaseUser.uid)
            object[ConstantKey.likes] = likes
            self.ref.child(ConstantKey.feed).child(userID).child(feedID).setValue(object) { (error, refrance) in
                if error == nil {
                    self.likeImg.setImage(#imageLiteral(resourceName: "Heart unfilled"), for: .normal)
                    self.likeImg.tag = 0
                }
            }
        }
    }
    
}
