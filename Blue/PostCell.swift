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


class PostCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    
    
     var post: Post!
    var likesRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
    // Handles Likes
    
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
    if let _ = snapshot.value as? NSNull {
    self.likeImg.image = UIImage(named: "empty-heart")
    } else {
    self.likeImg.image = UIImage(named: "filled-heart")
    }
    })
}

func likeTapped(sender: UITapGestureRecognizer) {
    likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
        if let _ = snapshot.value as? NSNull {
            self.likeImg.image = UIImage(named: "filled-heart")
            self.post.adjustLikes(addLike: true)
            self.likesRef.setValue(true)
        } else {
            self.likeImg.image = UIImage(named: "empty-heart")
            self.post.adjustLikes(addLike: false)
            self.likesRef.removeValue()
        }
    })
}
    
    
    
    


