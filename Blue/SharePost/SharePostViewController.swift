//
//  SharePostViewController.swift
//  Blue
//
//  Created by DK on 9/14/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import VGPlayer
import Firebase

class SharePostViewController: UIViewController {

    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var feedCaptionLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var playerView: VGPlayerView!
    
    
    var post:[String:Any] = [String:Any]()
    var user:[String:Any] = [String:Any]()
    
    var player:VGPlayer?

    
    var ref: DatabaseReference = Database.database().reference()
    
    var contentType:PostType = .caption
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameLabel.text = user[ConstantKey.username] as? String
        if let url = user[ConstantKey.image] as? String {
            self.profileImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
        }
        
        if let content = post[ConstantKey.image] as? String {
            if let type = post[ConstantKey.contentType] as? String , type == ConstantKey.video {
                //Video
                self.feedImageView.isHidden = true
                self.playerView.isHidden = false
                self.player = VGPlayer(playerView: self.playerView)
                self.player?.replaceVideo(URL(string: content)!)
                self.contentType = .video
            }
            else {
                
                //Image
                self.feedImageView.isHidden = false
                self.playerView.isHidden = true
                self.feedImageView.sd_setImage(with: URL(string: content)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
                self.contentType = .image
            }
        }
        else {
            self.playerView.isHidden = true
            self.feedImageView.isHidden = true
            self.contentType = .caption
        }
        
        self.feedCaptionLabel.text = post[ConstantKey.caption] as? String
        
        if let timeStamp = post[ConstantKey.date] as? Double {
            let date = Date(timeIntervalSince1970: timeStamp)
            self.dateLabel.text = Date().offset(from: date) + " ago"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnShareAction(_ sender: UIBarButtonItem) {
        var savedData:[String:Any] = [String:Any]()
        savedData[ConstantKey.id] = firebaseUser.uid
        savedData[ConstantKey.userid] = post[ConstantKey.userid]
        savedData[ConstantKey.postID] = post[ConstantKey.id]
        savedData[ConstantKey.date] = Date().timeStamp
        savedData[ConstantKey.caption] = self.captionTextView.text
        savedData[ConstantKey.contentType] = self.contentType.rawValue
        
        self.ref.child(ConstantKey.share).child(firebaseUser.uid).childByAutoId().setValue(savedData) { (error, dabaseRef) in
            if error == nil {
                self.showAlert("Post Shared Successfully.")
            }
        }
    }
}