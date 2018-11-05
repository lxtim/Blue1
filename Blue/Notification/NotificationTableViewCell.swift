//
//  NotificationTableViewCell.swift
//  Blue
//
//  Created by DK on 9/12/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    
    var object:[String:Any] = [String:Any]() {
        didSet(newValue) {
            
            let type:NotificationType = NotificationType(rawValue: object[ConstantKey.contentType] as! Int)!
            let userID = object[ConstantKey.id] as! String
            if let timeStamp = object[ConstantKey.date] as? Double {
                let date = Date(timeIntervalSince1970: timeStamp)
                self.dateLabel.text = Date().offset(from: date) + " ago"
            }
            
            if let image = object[ConstantKey.image] as? String {
                self.contentImageView.sd_setImage(with: URL(string: image)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
            }
            else {
                self.contentImageView.image = nil
            }
            self.userRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? [String:Any] else {return}
                if type == NotificationType.comment {
                    self.titleLabel.text = "\(value[ConstantKey.username] as! String) commented on your content."
                }
                if type == NotificationType.follow {
                    self.titleLabel.text = "\(value[ConstantKey.username] as! String) started following you."
                }
                if type == NotificationType.like {
                    self.titleLabel.text = "\(value[ConstantKey.username] as! String) liked your content."
                }
                if let url = value[ConstantKey.image] as? String {
                    self.profileImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
