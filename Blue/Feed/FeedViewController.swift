//
//  FeedViewController.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase


class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UserSearchDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference = Database.database().reference()
    var feedData:NSMutableArray = NSMutableArray()
    var allFeed:NSDictionary = NSDictionary()
    
    var currentObserver:UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tableView.isHidden = true
        self.getMyFollowers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let addFeedItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btn_add_final"), landscapeImagePhone: #imageLiteral(resourceName: "btn_add_final"), style: UIBarButtonItemStyle.done, target: self, action: #selector(btnAddFeedAction(_:)))
        let searchFeed:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(btnSearchAction(_:)))
        
        self.parent?.navigationItem.rightBarButtonItem = addFeedItem
        self.parent?.navigationItem.leftBarButtonItem = searchFeed
        self.parent?.navigationItem.title = "Feed"
        
    }
    
    @objc func btnAddFeedAction(_ sender: UIBarButtonItem) {
        let object = Object(NewPostViewController.self)
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    @IBAction func btnSearchAction(_ sender: UIBarButtonItem) {
        if let navigation = self.storyboard?.instantiateViewController(withIdentifier: "searchNavigation") as? UINavigationController {
            let searchTableController = navigation.viewControllers.first as! UserSearchViewController
            let searchController = UISearchController(searchResultsController: searchTableController)
            searchTableController.searchBar = searchController.searchBar
            searchTableController.delegate = self
            self.present(navigation, animated: false, completion: {})
        }
    }
    
    func getFeed() {
//        HUD.show()
        currentObserver = self.ref.child(ConstantKey.feed).observe(DataEventType.value) { (snapshot) in
//            HUD.dismiss()
            if let value = snapshot.value as? NSDictionary {
                self.allFeed = value
                
                    self.feedData = NSMutableArray()
                    for (k,v) in self.allFeed {
                        if let data = v as? NSDictionary {
                            if let userID = data.value(forKey: ConstantKey.userid) , BasicStuff.shared.followArray.contains(userID) {
                                let mutableData = NSMutableDictionary(dictionary: data)
                                mutableData.setValue(k, forKey: "id")
                                self.feedData.add(mutableData)
                            }
                        }
                    }
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    if self.feedData.count > 0 {
                        self.tableView.isHidden = false
                    }
                    else {
                        self.tableView.isHidden = true
                    }
                })
            }
        }
    }
    
    func getMyFollowers() {
//        HUD.show()
        self.ref.child(ConstantKey.Users).child(firebaseUser.uid).observe(DataEventType.value) { (snapshot) in
            if let snap = snapshot.value as? NSDictionary {
                BasicStuff.shared.UserData = NSMutableDictionary(dictionary: snap)
                if let array = snap.value(forKey: ConstantKey.follow) as? NSArray {
                    BasicStuff.shared.followArray = NSMutableArray(array: array)
                }
                else {
                    BasicStuff.shared.followArray = NSMutableArray(array: [])
                }
                if let observer = self.currentObserver {
                    self.ref.removeObserver(withHandle: observer)
                }
                
                self.getFeed()
            }
        }
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let feed = self.feedData.object(at: indexPath.row) as! NSMutableDictionary
        cell.object = feed
        
        return cell
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK:- UserSearchDelegate
    func userDidSelect(_ data: NSDictionary) {
        JDB.log("selected user data ==>%@", data)
        let profileVC = Object(ProfileViewController.self)
        profileVC.isOtherUserProfile = true
        profileVC.userProfileData = NSMutableDictionary(dictionary: data)
        self.parent?.navigationController?.pushViewController(profileVC, animated: true)
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
