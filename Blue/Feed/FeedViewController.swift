//
//  FeedViewController.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase
import YTBarButtonItemWithBadge

class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UserSearchDelegate , FeedPostCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    
    var feedData:[[String:Any]] = [[String:Any]]()
    var allFeed:NSDictionary = NSDictionary()
    
    var currentObserver:UInt?
    var isFirstTime:Bool = true
    
    var searchFeedItem:YTBarButtonItemWithBadge?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tableView.isHidden = true
        self.getMyFollowers()
        self.tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCell")
        self.tableView.register(UINib(nibName: "PostWithOutImageCell", bundle: Bundle.main), forCellReuseIdentifier: "PostWithOutImageCell")
        self.tableView.register(UINib(nibName: "VideoCell", bundle: Bundle.main), forCellReuseIdentifier: "VideoCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let searchFeed:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(btnSearchAction(_:)))
        self.parent?.navigationItem.leftBarButtonItem = searchFeed
        self.parent?.navigationItem.title = "Feed"
        
        setRightBar()
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        let addFeedItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btn_add_final"), landscapeImagePhone: #imageLiteral(resourceName: "btn_add_final"), style: UIBarButtonItemStyle.done, target: self, action: #selector(btnAddFeedAction(_:)))
//        let searchFeed:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(btnSearchAction(_:)))
//
//        self.parent?.navigationItem.rightBarButtonItem = addFeedItem
//        self.parent?.navigationItem.leftBarButtonItem = searchFeed
        setRightBar()
        self.parent?.navigationItem.title = "Feed"
    }
    
    
    func setRightBar() {
        let addFeedItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btn_add_final"), landscapeImagePhone: #imageLiteral(resourceName: "btn_add_final"), style: UIBarButtonItemStyle.done, target: self, action: #selector(btnAddFeedAction(_:)))
        let image = #imageLiteral(resourceName: "Star").withRenderingMode(.alwaysOriginal)
        let buttonWithBadge = YTBarButtonItemWithBadge();
        self.searchFeedItem = buttonWithBadge
        buttonWithBadge.setHandler {
            self.btnShareAction(UIBarButtonItem())
        }
        buttonWithBadge.setImage(image: image);
        var badgeCount = 0
        if let count = BasicStuff.shared.UserData[ConstantKey.unreadCount] as? Int {
            badgeCount = count
        }
        if let searchFeed = self.searchFeedItem {
            searchFeed.setBadge(value: "\(badgeCount)");
        }
        self.parent?.navigationItem.rightBarButtonItems = [addFeedItem,buttonWithBadge.getBarButtonItem()]
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
    
    @objc func btnShareAction(_ sender:UIBarButtonItem) {
        let notificationVC = Object(NotificationContentVC.self)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    func getFeed() {
        self.feedData = [[String:Any]]()
        self.userRef.observe(.value) { (snapshot) in
            if  let value = snapshot.value as? [String:Any] {
                let keys = value.keys.map({$0})
                self.getFeedData(keys, value, index: 0)
            }
        }
    }
    
    func getFeedData(_ keys:[String], _ sender:[String:Any] , index:Int) {
        if index >= sender.count {
            let sortedArray = self.feedData.sorted(by: {($0[ConstantKey.date] as! Double) > $1[ConstantKey.date] as! Double})
            self.feedData = sortedArray
            if self.isFirstTime {
                self.isFirstTime = false
            }
            
            if self.feedData.count > 0 {
                self.tableView.isHidden = false
            }
            else {
                self.tableView.isHidden = true
            }
            
            self.tableView.reloadData()
            return
        }
        else {
            let key = keys[index]
            let userValue = sender[key] as! [String:Any]
            
            if BasicStuff.shared.followArray.contains(key) || firebaseUser.uid == key {
                self.feedRef.child(key).observe(.value, with: { (snap) in
                    if let value = snap.value as? [String:Any] {
                        var isItemChanged:Bool = false
                        var changedIndex:[Int] = [Int]()
                        for (k,v) in value {
                            if var data = v as? [String:Any] {
                                data[ConstantKey.user] = userValue
                                data[ConstantKey.id] = k
                                if let itemIndex = self.feedData.index(where: {($0[ConstantKey.id] as! String) == k}) {
                                    self.feedData.remove(at: itemIndex)
                                    self.feedData.insert(data, at: itemIndex)
                                    changedIndex.append(itemIndex)
                                    isItemChanged = true
                                }
                                else {
                                    self.feedData.append(data)
                                    self.isFirstTime = true
                                }
                            }
                        }
                        
                        if isItemChanged {
                            let indexPaths = changedIndex.map({IndexPath(row: $0, section: 0)})
                            self.tableView.reloadRows(at: indexPaths, with: .none)
                        }
                        else {
                            self.tableView.reloadData()
                            let next = index + 1
                            DispatchQueue.main.async {
                                self.getFeedData(keys, sender, index: next)
                            }
                        }
                    }
                })
            }
            else {
                let next = index + 1
                DispatchQueue.main.async {
                    self.getFeedData(keys, sender, index: next)
                }
            }
        }
    }
    func getMyFollowers() {
        self.ref.child(ConstantKey.Users).child(firebaseUser.uid).observe(DataEventType.value) { (snapshot) in
            if let snap = snapshot.value as? NSDictionary {
                BasicStuff.shared.UserData = NSMutableDictionary(dictionary: snap)
                self.setRightBar()
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
            if let type = feed[ConstantKey.contentType] as? String , type == ConstantKey.video {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! PostCell
                cell.type = .video
                cell.object = feed
                cell.delegate = self
                return cell
            }
            else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
                cell.type = .image
                cell.object = feed
                cell.delegate = self
                return cell
            }
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostWithOutImageCell") as! PostCell
            cell.type = .caption
            cell.object = feed
            cell.delegate = self
            return cell
        }
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell  = cell as? PostCell {
            if let player = cell.player {
                player.pause()
            }
        }
    }
    //MARK:- FeedPostCellDelegate
    
    func feedLikeDidSelect(user: [String : Any]) {
        let likeVC = Object(LikeViewController.self)
        likeVC.user = user
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    
    func feedProfileDidSelect(user: [String : Any]) {
        let profile = Object(ProfileViewController.self)
        if let id = user[ConstantKey.userid] as? String ,id == firebaseUser.uid {
            profile.isOtherUserProfile = false
        }
        else {
            profile.isOtherUserProfile = true
            profile.userProfileData = NSMutableDictionary(dictionary: user)
        }
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    func feedCommentDidSelect(post: [String : Any], user: [String : Any]) {
        let commentVC = Object(CommentVC.self)
        commentVC.post = post
        commentVC.user = user
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func feedShareDidSelect(post: [String : Any], user: [String : Any]) {
        let sharePostVC = Object(SharePostViewController.self)
        sharePostVC.post = post
        sharePostVC.user = user
        self.navigationController?.pushViewController(sharePostVC, animated: true)
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
