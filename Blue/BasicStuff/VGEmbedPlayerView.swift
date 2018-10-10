//
//  VGEmbedPlayerView.swift
//  Blue
//
//  Created by DK on 10/1/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import VGPlayer

class VGEmbedPlayerView: VGPlayerView {

    var indexPath:IndexPath?
    
    override func configurationUI() {
        super.configurationUI()
        titleLabel.removeFromSuperview()
        timeSlider.minimumTrackTintColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        topView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        bottomView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        closeButton.isHidden = true

        self.timeSlider.isHidden = true
        self.fullscreenButton.isHidden = true
        
//        self.playButtion.snp.makeConstraints { (make) in
//            make.center.equalTo(self.snp.center)
//        }
//        self.addSubview(bottomProgressView)
//        bottomProgressView.snp.makeConstraints { (make) in
//            make.left.equalTo(self.snp.left)
//            make.right.equalTo(self.snp.right)
//            make.bottom.equalTo(self.snp.bottom)
//            make.height.equalTo(3)
//        }
        self.timeLabel.isHidden = true
        self.configureGesture()
    }
    
    public func configureGesture() {
        doubleTapGesture.isEnabled = false
        panGesture.isEnabled = false
    }
    
    override func reloadPlayerView() {
        super.reloadPlayerView()
//        bottomProgressView.setProgress(0, animated: false)
    }
    
    override func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        super.playerDurationDidChange(currentDuration, totalDuration: totalDuration)
//        bottomProgressView.setProgress(Float(currentDuration/totalDuration), animated: true)
    }
    
    func updateView() {
        self.displayControlView(false)
        self.topView.removeFromSuperview()
        self.bottomView.removeFromSuperview()
    }
}
