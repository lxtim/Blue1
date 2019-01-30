//
//  ProfileSegmentViewController.swift
//  Blue
//
//  Created by DK on 1/21/19.
//  Copyright © 2019 Tim. All rights reserved.
//

import UIKit
import SJSegmentedScrollView

class ProfileSegmentViewController: SJSegmentedViewController , SJSegmentedViewControllerDelegate {
    
    var isOtherUserProfile:Bool = false
    var userProfileData:[String:Any] = [String:Any]()
    
    var index:Int = 0
    var firstTime:Bool = true
    var isBackFromSetting:Bool = false
    
    override func viewDidLoad() {
        
        let userContentVC = Object(UserContentViewController.self)
        if self.isOtherUserProfile {
            userContentVC.userID = userProfileData[ConstantKey.id] as! String
        }
        
        userContentVC.title = "Content"
        
        let followVC = Object(FollowingViewController.self)
        followVC.title = "Follows"
        
        let bioVC = Object(BioViewController.self)
        bioVC.userData = userProfileData
        bioVC.isOtherUserProfile = self.isOtherUserProfile
        bioVC.title = "Bio"
        
        
        let headerController = Object(ProfileHeaderViewController.self)
        headerController.userData = userProfileData
        headerController.isOtherUserProfile = self.isOtherUserProfile
        
        headerViewController = headerController
        segmentControllers = [userContentVC,followVC,bioVC]
        
        headerViewHeight = 110
        selectedSegmentViewHeight = 2.0
        selectedSegmentViewColor = .white //UIColor("4A4A4A")
        segmentBackgroundColor = .white//UIColor("FE6525") //FE5A22
        segmentShadow = SJShadow.light()
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        segmentBounces = true
        segmentViewHeight = 30
        self.delegate = self
        super.viewDidLoad()
        
        for item in self.segments {
            item.titleFont(UIFont(name: "Helvetica", size: 12)!)
            item.titleColor(.lightGray, UIControl.State.normal)
            item.titleColor(.black, UIControl.State.selected)
        }
        // Do any additional setup after loading the view.
    }
    
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        self.index = index
        if index == 1 {
            if self.isOtherUserProfile {
                if let following = userProfileData[ConstantKey.follow] as? NSArray {
                    if following.count > 0 {
                        if let followingVC = controller as?  FollowingViewController {
                            followingVC.followingUsers = following.map({$0 as! String})
                            followingVC.updateTableData()
                        }
                    }
                }
            }
            else {
                if BasicStuff.shared.followArray.count > 0 {
                    if let followingVC = controller as? FollowingViewController {
                        followingVC.followingUsers = BasicStuff.shared.followArray.map({$0 as! String})
                        followingVC.updateTableData()
                    }
                }
            }
        }
    }
    
    func didSelectSegmentAtIndex(_ index: Int) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if firstTime {
            self.firstTime = false
        }
        else {
            if self.isBackFromSetting {
                self.isBackFromSetting = false
                let vc = self.segmentControllers[0]
                vc.viewWillAppear(animated)
            }
            else if self.index != 0 {
                let vc = self.segmentControllers[0]
                vc.viewWillAppear(animated)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
