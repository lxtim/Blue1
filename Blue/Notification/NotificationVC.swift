//
//  NotificationVC.swift
//  Blue
//
//  Created by DK on 9/12/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class NotificationVC: UIViewController , UITableViewDelegate , UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!

    var ref = Database.database().reference()
    var notification:[[String:Any]] = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref.child(ConstantKey.notification).child(firebaseUser.uid).observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [String:Any] else { return }
            self.notification = value.map({$1 as! [String:Any]})
            self.notification = self.notification.sorted(by: {($0[ConstantKey.date] as! Double) > ($1[ConstantKey.date] as! Double) })
            self.tableView.reloadData()
        }
    }
    
    //MARK:- UItableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notification.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as! NotificationTableViewCell
        cell.object = self.notification[indexPath.row]
        cell.index = indexPath.row
        cell.btnProfile.addTarget(self, action: #selector(btnProfileAction(_:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.notification[indexPath.row]
        if let captin = object[ConstantKey.caption] as? String {
            DispatchQueue.main.async {
                self.showAlert(title: "Caption", message: captin, actions: UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                }))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
        view.backgroundColor = UIColor.lightGray
        return view
    }
    
    @objc func btnProfileAction(_ sender:UIButton) {
        
        let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as! NotificationTableViewCell
        
        let profile = Object(ProfileSegmentViewController.self)//Object(ProfileViewController.self)
        
        if let id = cell.user[ConstantKey.id] as? String ,id == firebaseUser.uid {
            profile.isOtherUserProfile = false
        }
        else {
            profile.isOtherUserProfile = true
        }
        profile.userProfileData = cell.user
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.parent?.navigationController?.pushViewController(profile, animated: true)
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
