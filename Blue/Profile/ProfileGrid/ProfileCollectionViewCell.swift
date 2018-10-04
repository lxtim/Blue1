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
    
    var player: VGPlayer?
    
    var playerView = VGEmbedPlayerView()
    
    @IBOutlet weak var playerContentView: UIView!
    
    override func awakeFromNib() {
       
    }
    
    var object:[String:Any] = [String:Any]() {
        didSet(newValue) {
            if postType == .caption {
                self.postTextView.text = object[ConstantKey.caption] as? String
            }
            if let url = object[ConstantKey.image] as? String {
                if postType == .video {
                    self.player = VGPlayer(playerView: playerView)
                    let url = URL(string: url)!
                    self.player?.replaceVideo(url)
                    self.playerContentView.addSubview((self.player?.displayView)!)
                    self.player?.displayView.snp.remakeConstraints({
                        $0.edges.equalTo(self.playerContentView)
                    })
//                    if let duration = object[ConstantKey.duration] as? Double , duration < 70 {
//                        self.player?.play()
//                    }
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
