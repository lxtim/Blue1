//
//  YTBarButtonItemWithBadge.swift
//  YTBarButtonItemWithBadge
//
//  Created by Yasin Turkdogan on 1/4/17.
//  Copyright © 2017 yasinturkdogan. All rights reserved.
//


import Foundation

public typealias SimpleHandler = (() -> ());

public class YTBarButtonItemWithBadge {
    
    private let badgeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20));
    private let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44));
    private var callback:SimpleHandler?
    private let barButtonItem:UIBarButtonItem!
    
    public  init() {
        
        badgeLabel.font = UIFont(name: "HelveticaNeue", size: 11)!
        badgeLabel.textAlignment = .center;
        badgeLabel.layer.masksToBounds = true;
        badgeLabel.layer.cornerRadius = badgeLabel.frame.width / 2;
        badgeLabel.backgroundColor = UIColor.red;
        badgeLabel.textColor = UIColor.white;
        badgeLabel.frame.origin.y = 10;
        
        button.addSubview(badgeLabel);
        barButtonItem = UIBarButtonItem(customView: button);
        
        self.setBadge(value: nil);
        self.setTitle(value: nil);
        self.setImage(image: nil);
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func getBarButtonItem()->UIBarButtonItem {
        return barButtonItem;
    }
    
    @objc private func onClick() {
        callback?();
    }
    
    public func setImage(image:UIImage?) {
        self.button.setImage(image, for: .normal);
        self.button.sizeToFit();
    }
    
    public func setBadge(value:String?) {
        if let string = value {
            if let intValue = Int(string) {
                if intValue == 0 {
                    self.badgeLabel.isHidden = true
                }
                else {
                    self.badgeLabel.isHidden = value == nil
                }
                if intValue > 9 {
                    self.badgeLabel.text = "9+";
                }
                else {
                    self.badgeLabel.text = value;
                }
            }
            else {
                self.badgeLabel.text = value;
            }
        }
        else {
            self.badgeLabel.text = value;
        }
        self.badgeLabel.frame.origin.x = button.frame.width - badgeLabel.frame.width / 2;
    }
    
    public func setTitle(value:String?) {
        self.button.setTitle(value, for: .normal);
        self.button.sizeToFit();
        self.badgeLabel.frame.origin.x = button.frame.width - badgeLabel.frame.width / 2;
    }
    
    public func setHandler(callback:@escaping SimpleHandler) {
        if(button.actions(forTarget: self, forControlEvent: .touchUpInside) == nil) {
            button.addTarget(self, action: #selector(onClick), for: UIControl.Event.touchUpInside);
        }
        self.callback = callback;
    }
}

