//
//  FeedViewController.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase


class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UserSearchDelegate , FeedPostCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    
    var feedData:[[String:Any]] = [[String:Any]]()
    var allFeed:NSDictionary = NSDictionary()
    
    var currentObserver:UInt?
    var isFirstTime:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tableView.isHidden = true
        self.getMyFollowers()
        self.tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCell")
        self.tableView.register(UINib(nibName: "PostWithOutImageCell", bundle: Bundle.main), forCellReuseIdentifier: "PostWithOutImageCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let addFeedItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btn_add_final"), landscapeImagePhone: #imageLiteral(resourceName: "btn_add_final"), style: UIBarButtonItemStyle.done, target: self, action: #selector(btnAddFeedAction(_:)))
        let searchFeed:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(btnSearchAction(_:)))
        
        self.parent?.navigationItem.rightBarButtonItem = addFeedItem
        self.parent?.navigationItem.leftBarButtonItem = searchFeed
        self.parent?.navigationItem.title = "Feed"
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        self.feedData = [[String:Any]]()
        self.userRef.observe(.childAdded) { (snapshot) in
            if BasicStuff.shared.followArray.contains(snapshot.key) || firebaseUser.uid == snapshot.key {
                self.feedRef.child(snapshot.key).observe(.value, with: { (snap) in
                    if let value = snap.value as? [String:Any] {
                        for (k,v) in value {
                            if var data = v as? [String:Any] {
                                data[ConstantKey.user] = snapshot.value
                                data[ConstantKey.id] = k
                                if let index = self.feedData.index(where: {($0[ConstantKey.id] as! String) == k}) {
                                    self.feedData.remove(at: index)
                                    self.feedData.insert(data, at: index)
                                }
                                else {
                                    self.feedData.append(data)
                                    self.isFirstTime = true
                                }
                            }
                        }
                    }
                    
                    let sortedArray = self.feedData.sorted(by: {(one , two) in
                        return  (one["date"] as! String).date > (two["date"] as! String).date
                    })
                    self.feedData = sortedArray
                    if self.isFirstTime {
                        self.isFirstTime = false
                        self.tableView.reloadData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                        if self.feedData.count > 0 {
                            self.tableView.isHidden = false
                        }
                        else {
                            self.tableView.isHidden = true
                        }
                    })
                    
                })
            }
        }
    }
    
    func getMyFollowers() {
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
        let feed = self.feedData[indexPath.row]
        if feed[ConstantKey.image] != nil {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.object = feed
            cell.delegate = self
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostWithOutImageCell", for: indexPath) as! PostWithOutImageCell
            cell.object = feed
            cell.delegate = self
            return cell
        }
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK:- FeedPostCellDelegate
    func postcellDidSelectLike(user: [String : Any]) {
        let likeVC = Object(LikeViewController.self)
        likeVC.user = user
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    //MARK:- UserSearchDelegate
    func userDidSelect(_ data: NSDictionary) {
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
