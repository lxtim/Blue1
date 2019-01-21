//
//  LikeViewController.swift
//  Blue
//
//  Created by DK on 8/16/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class LikeViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{
    
    private var likes:[[String:Any]] = [[String:Any]]()
    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var user:[String:Any] = [String:Any]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var likeUsers:[String] = [String]()
        if let like = user[ConstantKey.likes] as? [String] {
            likeUsers = like
        }
        
        self.userRef.observeSingleEvent(of: DataEventType.value) { (snap) in
            if let value = snap.value as? [String:Any] {
                for (k,v) in value {
                    if likeUsers.contains(k) {
                        if let user = v as? [String:Any] {
                            self.likes.append(user)
                        }
                    }
                }
            }
            self.tableView.reloadData()
        }
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let userData = user[ConstantKey.user] as? [String:Any] {
            self.navigationItem.title = userData[ConstantKey.username] as? String
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let userData = user[ConstantKey.user] as? [String:Any] {
            self.navigationItem.title = userData[ConstantKey.username] as? String
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.likes.count
    }
    
    //MARK:- UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchCell", for: indexPath) as! UserSearchCell
        let data = self.likes[indexPath.row]
        cell.title = data[ConstantKey.username] as! String
        cell.imageURLString = data[ConstantKey.image] as! String
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.tableView.bounds.width, height: 1)))
        view.backgroundColor = self.tableView.separatorColor
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    //MARK:- UItableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.likes[indexPath.row]
        let profile = Object(ProfileSegmentViewController.self)
        if let id = user[ConstantKey.id] as? String ,id == firebaseUser.uid {
            profile.isOtherUserProfile = false
        }
        else {
            profile.isOtherUserProfile = true
            profile.userProfileData = user//NSMutableDictionary(dictionary: user)
        }
        self.navigationController?.pushViewController(profile, animated: true)
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
