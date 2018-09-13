//
//  ShareTableViewCell.swift
//  Blue
//
//  Created by DK on 9/13/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import VGPlayer

class ShareTableViewCell: UITableViewCell {
    @IBOutlet weak var shareUserImageView: UIImageView!
    @IBOutlet weak var shareUserNameLabel: UILabel!
    @IBOutlet weak var shareUserDateLabel: UILabel!
    
    @IBOutlet weak var adminUserImageView: UIImageView!
    @IBOutlet weak var adminUserNameLabel: UILabel!
    @IBOutlet weak var adminDateLabel: UILabel!
    
    
    @IBOutlet weak var btnFeedComment: UIButton!
    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var btnLikeImage: UIButton!
    
    
    @IBOutlet weak var captionLabel: UITextView!
    
    
    
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: VGPlayerView!
    
    var player:VGPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let playerView = videoPlayerView {
            self.player = VGPlayer(playerView: playerView)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
