//
//  ProfileCollectionViewCell.swift
//  Blue
//
//  Created by DK on 9/15/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase
import VGPlayer

class ProfileCollectionViewCell: UICollectionViewCell {
    var postType:PostType = .caption
    
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var playerView: VGPlayerView!
    
    var player:VGPlayer? = nil
    
    override func awakeFromNib() {
        if let vgPlayerView = self.playerView {
            self.player = VGPlayer(playerView: vgPlayerView)
        }
    }
    
    var object:[String:Any] = [String:Any]() {
        didSet(newValue) {
            if postType == .caption {
                self.postTextView.text = object[ConstantKey.caption] as? String
            }
            if let url = object[ConstantKey.image] as? String {
                if postType == .video {
                    self.player?.replaceVideo(URL(string: url)!)
                }
                else if postType == .image {
                    if let imageView = self.postImageView {
                        imageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
                    }
                }
            }
        }
    }
}
