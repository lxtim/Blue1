//
//  CommentTableViewCell.swift
//  Blue
//
//  Created by DK on 9/11/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    
    var comment:[String:Any] = [String:Any]() {
        didSet {
            
            if let timeStamp = comment[ConstantKey.date] as? Double {
                let date = Date(timeIntervalSince1970: timeStamp)
                
                self.dateLabel.text = Date().offset(from: date) + " ago"
                
            }
            self.commentLabel.text = comment[ConstantKey.comment] as? String
            guard let userid = comment[ConstantKey.userid] as? String else {return}
            
            self.userRef.child(userid).observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? [String:Any] else {return}
                self.userNameLabel.text = value[ConstantKey.username] as? String
                if let url = value[ConstantKey.image] as? String {
                    self.profileImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
        }
    }

}
