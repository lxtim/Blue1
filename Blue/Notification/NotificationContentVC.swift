//
//  NotificationContentVC.swift
//  Blue
//
//  Created by DK on 9/12/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl
import Firebase

class NotificationContentVC: UIViewController {

    @IBOutlet weak var scrollVIew: UIScrollView!
    @IBOutlet weak var segmentView: ScrollableSegmentedControl!
    
    var selectedIndex:Int = 0
    var userRef = Database.database().reference().child(ConstantKey.Users)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentView.segmentStyle = .textOnly
        segmentView.insertSegment(withTitle: "My Notifications", at: 0)
        segmentView.insertSegment(withTitle: "Shared", at: 1)
        segmentView.underlineSelected = true
        segmentView.tintColor = UIColor("4A4A4A")
        
        segmentView.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
        
        segmentView.segmentContentColor = UIColor("4A4A4A")
        segmentView.selectedSegmentContentColor = UIColor("4A4A4A")
        segmentView.backgroundColor = UIColor.white
        
        let normalColorAttribute = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor("4A4A4A")]
        let selectedColorAttribute = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor("4A4A4A")]
        
        
        segmentView.setTitleTextAttributes(normalColorAttribute, for: .normal)
        segmentView.setTitleTextAttributes(selectedColorAttribute, for: .highlighted)
        segmentView.setTitleTextAttributes(selectedColorAttribute, for: .selected)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.userRef.child(firebaseUser.uid).updateChildValues([ConstantKey.unreadCount:0])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        segmentView.selectedSegmentIndex = selectedIndex
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let shared = self.childViewControllers[1] as? ShareVC {
            shared.player.cleanPlayer()
            shared.player.displayView.removeFromSuperview()
            shared.currentPlayIndexPath = nil
        }
    }
    
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        let index = sender.selectedSegmentIndex
        self.selectedIndex = index
        let width = self.scrollVIew.frame.size.width
        let rect:CGRect = CGRect(x: (width * CGFloat(index)), y: 0, width: width, height: scrollVIew.frame.size.height)
        if index == 1 {
            if let shared = self.childViewControllers[index] as? ShareVC {
                shared.getRefresh()
            }
        }
        else {
            if let shared = self.childViewControllers[1] as? ShareVC {
                shared.player.cleanPlayer()
                shared.player.displayView.removeFromSuperview()
            }
        }
        
        self.scrollVIew.scrollRectToVisible(rect, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
