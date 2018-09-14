//
//  NotificationContentVC.swift
//  Blue
//
//  Created by DK on 9/12/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class NotificationContentVC: UIViewController {

    @IBOutlet weak var scrollVIew: UIScrollView!
    @IBOutlet weak var segmentView: ScrollableSegmentedControl!
    
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
        segmentView.selectedSegmentIndex = 0
        
    }

    
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        let index = sender.selectedSegmentIndex
        let width = self.scrollVIew.frame.size.width
        let rect:CGRect = CGRect(x: (width * CGFloat(index)), y: 0, width: width, height: scrollVIew.frame.size.height)
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
