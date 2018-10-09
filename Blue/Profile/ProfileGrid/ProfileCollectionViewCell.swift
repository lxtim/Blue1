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
    var playerView = VGCollectionPlayerView()
    
    @IBOutlet weak var playerContentView: UIView!
    
    var indexPath:IndexPath?
    
    var playCallBack:((IndexPath?) -> Swift.Void)?
    override func awakeFromNib() {
       
    }
    
    var object:[String:Any] = [String:Any]() {
        didSet(newValue) {
            if postType == .caption {
                self.postTextView.text = object[ConstantKey.caption] as? String
            }
            if let url = object[ConstantKey.image] as? String {
                if postType == .video {
                    if let thumb = object[ConstantKey.thumb_image] as? String {
                        self.postImageView.sd_setImage(with: URL(string: thumb)!, placeholderImage: #imageLiteral(resourceName: "Filledheart"), options: .continueInBackground, completed: nil)
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
    
    @IBAction func btnPlayAction(_ sender:UIButton) {
        
        if let callback = self.playCallBack {
            callback(indexPath)
        }
    }
}
