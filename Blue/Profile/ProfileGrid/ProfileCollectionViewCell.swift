//
//  ProfileCollectionViewCell.swift
//  Blue
//
//  Created by DK on 9/15/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase
import BMPlayer

class ProfileCollectionViewCell: UICollectionViewCell {
    var postType:PostType = .caption
    
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var player: BMPlayer!
    
    
    override func awakeFromNib() {
        if let playerView = player {
            playerView.updateUI(false)
            playerView.panGesture.isEnabled = false
            playerView.controlView.timeSlider.isEnabled = false
            playerView.controlView.fullscreenButton.isHidden = true
            playerView.controlView.timeSlider.isHidden = true
            playerView.controlView.totalTimeLabel.isHidden = true
            playerView.controlView.progressView.isHidden = true
        }
    }
    
    var object:[String:Any] = [String:Any]() {
        didSet(newValue) {
            if postType == .caption {
                self.postTextView.text = object[ConstantKey.caption] as? String
            }
            if let url = object[ConstantKey.image] as? String {
                if postType == .video {
                    let asset = BMPlayerResource(url: URL(string: url)!)
                    player.setVideo(resource: asset)
                    if let duration = object[ConstantKey.duration] as? Double , duration < 70 {
                        self.player?.play()
                    }
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
