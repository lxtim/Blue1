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
import VGPlayer

class FeedViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UserSearchDelegate , FeedPostCellDelegate , UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnFavourite: MFBadgeButton!
    
    var ref: DatabaseReference = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    var shareRef = Database.database().reference().child(ConstantKey.share)
    
    var feedData:[[String:Any]] = [[String:Any]]()
    var allFeed:NSDictionary = NSDictionary()
    
    var currentObserver:UInt?
    var isFirstTime:Bool = true
    
    var searchFeedItem:YTBarButtonItemWithBadge?
    
    var player:VGPlayer!
    var playerView : VGEmbedPlayerView!
    var playerViewSize : CGSize?
    var currentPlayIndexPath : IndexPath?
    
    var lastContentOffset: CGFloat = 0.0
    
    var isViewShow:Bool = false
    
    var changeObserver:[String:[UInt]] = [String:[UInt]]()
    
    var refreshControl:UIRefreshControl = UIRefreshControl()
    var selectedIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.isHidden = true
        self.getMyFollowers()
        self.tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCell")
        self.tableView.register(UINib(nibName: "PostWithOutImageCell", bundle: Bundle.main), forCellReuseIdentifier: "PostWithOutImageCell")
        self.tableView.register(UINib(nibName: "VideoCell", bundle: Bundle.main), forCellReuseIdentifier: "VideoCell")
        
        //        self.configurePlayer()
        //        addTableViewObservers()
        //        NotificationCenter.default.addObserver(self, selector: #selector(deleteData), name: NSNotification.Name.RefreshFeedData, object: nil)
        refreshControl.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        self.tableView.addSubview(refreshControl)
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl) {
        self.getFeed()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.navigationController?.setNavigationBarHidden(true, animated: false)
        let searchFeed:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(btnSearchAction(_:)))
        self.parent?.navigationItem.leftBarButtonItem = searchFeed
        self.parent?.navigationItem.title = "Feed"
        
        setRightBar()
        
        
        self.getFeed()
        
        //        if let indexPath = self.tableView.indexPathsForVisibleRows {
        //            tableView.beginUpdates()
        //            tableView.reloadRows(at: indexPath, with: .none)
        //            tableView.endUpdates()
        //        }
        //        self.tableView.reloadData()
        //        self.isViewShow = true
        //        player.play()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.parent?.navigationItem.title = "Feed"
        
        //        if let playIndexPath = currentPlayIndexPath {
        //            if let cell = tableView.cellForRow(at: playIndexPath) as? PostCell {
        //                let visibleCells = tableView.visibleCells
        //                if visibleCells.contains(cell) {
        //                    if cell.type == .video {
        //                        if let url = cell.videoURL {
        //                            self.player.replaceVideo(url)
        //                            cell.playerContentView.addSubview(self.player.displayView)
        //                            if cell.autoPlay {
        //                                player.play()
        //                            }
        //
        //                            self.player.displayView.snp.remakeConstraints {
        //                                $0.edges.equalTo(cell.playerContentView)
        //                            }
        //                        }
        //                    }
        //                    else {
        //                        self.player.displayView.removeFromSuperview()
        //                    }
        //                } else {
        //                    self.player.displayView.removeFromSuperview()
        //                }
        //            } else {
        //                player.cleanPlayer()
        //                if isViewLoaded && (view.window != nil) {
        //                    //
        //                }
        //            }
        //        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        self.player.displayView.removeFromSuperview()
        //        player.cleanPlayer()
        //        currentPlayIndexPath = nil
        //        player.pause()
        //        self.isViewShow = false
    }
    
    deinit {
        //        player.cleanPlayer()
        //        removeTableViewObservers()
        //        NotificationCenter.default.removeObserver(self)
    }
    
    func configurePlayer() {
        playerView = VGEmbedPlayerView()
        player = VGPlayer(playerView: playerView)
        player.backgroundMode = .suspend
    }
    
    @objc func deleteData() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            // self.getFeed()
        }
    }
    
    func setRightBar() {
        //
        //
        //        let addFeedItem:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "btn_add_final"), landscapeImagePhone: #imageLiteral(resourceName: "btn_add_final"), style: UIBarButtonItemStyle.done, target: self, action: #selector(btnAddFeedAction(_:)))
        //        let image = #imageLiteral(resourceName: "Star").withRenderingMode(.alwaysOriginal)
        //        let buttonWithBadge = YTBarButtonItemWithBadge();
        //        self.searchFeedItem = buttonWithBadge
        //        buttonWithBadge.setHandler {
        ////            self.btnShareAction();
        //        }
        //        buttonWithBadge.setImage(image: image);
        var badgeCount = 0
        if let count = BasicStuff.shared.UserData[ConstantKey.unreadCount] as? Int {
            badgeCount = count
        }
        //        self.btnFavourite.badgeValue = "\(badgeCount)"
        
        if badgeCount == 0 {
            self.btnFavourite.setImage(#imageLiteral(resourceName: "Logo_icon"), for: .normal)
        }
        else {
            self.btnFavourite.setImage(#imageLiteral(resourceName: "Logo_notification"), for: .normal)
        }
        //        if let searchFeed = self.searchFeedItem {
        //            searchFeed.setBadge(value: "\(badgeCount)");
        //        }
        //        self.parent?.navigationItem.rightBarButtonItems = [addFeedItem,buttonWithBadge.getBarButtonItem()]
    }
    @IBAction func btnAddFeedAction(_ sender: UIButton) {
        //        let object = Object(NewPostViewController.self)
        //        self.navigationController?.pushViewController(object, animated: true)
        //    }
        //    @objc func btnAddFeedAction(_ sender: UIBarButtonItem) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let object = Object(NewPostViewController.self)
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        
        //    }
        //    @IBAction func btnSearchAction(_ sender: UIBarButtonItem) {
        
        if let navigation = self.storyboard?.instantiateViewController(withIdentifier: "searchNavigation") as? UINavigationController {
            let searchTableController = navigation.viewControllers.first as! UserSearchViewController
            let searchController = UISearchController(searchResultsController: searchTableController)
            searchTableController.searchBar = searchController.searchBar
            searchTableController.delegate = self
            self.present(navigation, animated: false, completion: {})
        }
    }
    
    @IBAction func btnShareAction(_ sender: UIButton) {
        let notificationVC = Object(NotificationContentVC.self)
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }
    func getFeed() {
        HUD.show()
        self.feedData = [[String:Any]]()
        self.userRef.observeSingleEvent(of: DataEventType.value) { (snapshot) in
            if  let value = snapshot.value as? [String:Any] {
                let keys = value.keys.map({$0})
                self.getFeedData(keys, value, index: 0)
                
                for (k,v) in self.changeObserver {
                    for int in v {
                        self.feedRef.child(k).removeObserver(withHandle: int)
                    }
                }
                self.changeObserver.removeAll()
            }
        }
        self.userRef.observe(.childRemoved) { (snapshot) in
            if  let value = snapshot.value as? [String:Any] {
                let keys = value.keys.map({$0})
                self.getFeedData(keys, value, index: 0)
                
                for (k,v) in self.changeObserver {
                    for int in v {
                        self.feedRef.child(k).removeObserver(withHandle: int)
                    }
                }
                self.changeObserver.removeAll()
            }
        }
    }
    
    func observeChangedObject(_ key:String) {
        let changeIndex = self.feedRef.child(key).observe(.childChanged, with: { (snap) in
            if var value = snap.value as? [String:Any] {
                if let id = value[ConstantKey.id] as? String {
                    if let itemIndex = self.feedData.index(where: {($0[ConstantKey.id] as! String) == id }) {
                        let data = self.feedData[itemIndex]
                        let user = data[ConstantKey.user] as! [String:Any]
                        value[ConstantKey.user] = user
                        self.feedData.remove(at: itemIndex)
                        self.feedData.insert(value, at: itemIndex)
                        
                        //                    if let indexPath = self.tableView.indexPathsForVisibleRows {
                        //                        self.tableView.beginUpdates()
                        //                        self.tableView.reloadRows(at: indexPath, with: .none)
                        //                        self.tableView.endUpdates()
                        //                    }
                        
                        //                    let indexPath = IndexPath(row: itemIndex, section: 0)
                        //                    self.tableView.beginUpdates()
                        //                    self.tableView.reloadRows(at: [indexPath], with: .none)
                        //                    self.tableView.endUpdates()
                    }
                    else {
                        let userID = value[ConstantKey.userid] as! String
                        self.userRef.child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let user = snapshot.value as? [String:Any] {
                                value[ConstantKey.user] = user
                                self.feedData.append(value)
                                let sortedArray = self.feedData.sorted(by: {($0[ConstantKey.date] as! Double) > $1[ConstantKey.date] as! Double})
                                self.feedData = sortedArray
                                self.tableView.reloadData()
                            }
                        })
                    }
                }
                else {
                    JDB.log("No ID Found ==>%@", value)
                    //                    self.showAlert("Please check id on feed content line 257")
                }
            }
        })
        
        let removeIndex = self.feedRef.child(key).observe(DataEventType.childRemoved) { (snap) in
            if var value = snap.value as? [String:Any] {
                if let id = value[ConstantKey.id] as? String {
                    if let itemIndex = self.feedData.index(where: { (item) -> Bool in
                        if let itemID = item[ConstantKey.id] as? String , itemID == id {
                            return true
                        }
                        return false
                    }) {
                        self.feedData.remove(at: itemIndex)
                        //                        let indexPath = IndexPath(row: itemIndex, section: 0)
                        //                        self.tableView.beginUpdates()
                        //                        self.tableView.deleteRows(at: [indexPath], with: .none)
                        //                        self.tableView.endUpdates()
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        self.changeObserver[key] = [changeIndex,removeIndex]
    }
    func getFeedData(_ keys:[String], _ sender:[String:Any] , index:Int) {
        if index >= sender.count {
            HUD.dismiss()
            let sortedArray = self.feedData.sorted(by: {($0[ConstantKey.date] as! Double) > $1[ConstantKey.date] as! Double})
            var feedImageData:[[String:Any]] = [[String:Any]]()
            
            //self.feedData = sortedArray
            
//            JDB.log("feeddata ==>%@", sortedArray.count)
//            JDB.log("feeddata ==>%@", sortedArray)
            
            for item in sortedArray {
                if item[ConstantKey.contentType] == nil || item[ConstantKey.contentType] as! String != ConstantKey.video {
                    if let story = item[ConstantKey.storyType] as? String {
                        if story == StoryType.story {
                            // check date for 24 hours
                            if let timeStamp = item[ConstantKey.date] as? Double {
                                let postDate = Date(timeIntervalSince1970: timeStamp)
                                let hours = Date().hours(from: postDate)
                                if hours < storyTime {
                                    feedImageData.append(item)
                                }
                            }
                        }
                        else {
                            feedImageData.append(item)
                        }
                    }
                    else {
                        feedImageData.append(item)
                    }
                }
            }
            self.feedData = feedImageData
            
            //            for i in 0...feedData.count - 1 {
            //                JDB.log("feed data index \(i) ====>%@", feedData[i])
            //            }
            
            if self.feedData.count > 0 {
                self.tableView.isHidden = false
            }
            else {
                self.tableView.isHidden = true
            }
            
            self.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                if let indexPath = self.selectedIndexPath {
                    self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.none, animated: false)
                    self.selectedIndexPath = nil
                }
            })
            
            //            if self.isFirstTime {
            //                self.isFirstTime = false
            //                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            //                    let visibleCell = self.tableView.visibleCells
            //                    for item in visibleCell {
            //                        if let cell = item as? PostCell , cell.type == .video {
            //                            self.currentPlayIndexPath = cell.indexPath
            ////                            self.observeValue(forKeyPath: #keyPath(UITableView.contentOffset), of: self.tableView, change: nil, context: nil)
            //                        }
            //                    }
            //                }
            //            }
            self.refreshControl.endRefreshing()
            return
        }
        else {
            let key = keys[index]
            let userValue = sender[key] as! [String:Any]
            
            if BasicStuff.shared.followArray.contains(key) || firebaseUser.uid == key {
                
                self.feedRef.child(key).observeSingleEvent(of: .value) { (snap) in
                    //
                    //                }
                    //                self.feedRef.child(key).observe(.value, with: { (snap) in
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
                            self.tableView.reloadData()
                            //                            let indexPaths = changedIndex.map({IndexPath(row: $0, section: 0)})
                            //                            self.tableView.reloadRows(at: indexPaths, with: .none)
                        }
                        else {
                            self.tableView.reloadData()
                            let next = index + 1
                            DispatchQueue.main.async {
                                self.getFeedData(keys, sender, index: next)
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            let next = index + 1
                            self.getFeedData(keys, sender, index: next)
                        }
                    }
                }
                self.observeChangedObject(key)
            }
            else {
                DispatchQueue.main.async {
                    let next = index + 1
                    self.getFeedData(keys, sender, index: next)
                }
            }
        }
    }
    func getMyFollowers() {
        HUD.show()
        var localisFirsTime = false
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
                if localisFirsTime == false {
                    localisFirsTime = true
                    self.getFeed()
                }
            }
        }
    }
    
    func addTableViewObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        tableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentOffset), options: options, context: nil)
    }
    
    func removeTableViewObservers() {
        tableView?.removeObserver(self, forKeyPath: #keyPath(UITableView.contentOffset))
    }
    
    //MARK:- UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.feedData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let feed = self.feedData[indexPath.row]
        
        if feed[ConstantKey.image] != nil {
            if let type = feed[ConstantKey.contentType] as? String , type == ConstantKey.video {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "VideoCell") as! PostCell
                cell.type = .video
                cell.object = feed
                cell.delegate = self
                cell.indexPath = indexPath
                //                self.currentPlayIndexPath = indexPath
                //                cell.playCallBack = { (index) in
                //                    if let index = index {
                //                        self.tableView(self.tableView, didSelectRowAt: index)
                //                    }
                //                }
                return cell
            }
            else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
                cell.type = .image
                cell.object = feed
                cell.delegate = self
                cell.indexPath = indexPath
                return cell
            }
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostWithOutImageCell") as! PostCell
            cell.type = .caption
            cell.object = feed
            cell.delegate = self
            cell.indexPath = indexPath
            return cell
        }
    }
    
    //MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = self.feedData[indexPath.row]
        let object = Object(PostViewController.self)
        object.object = feed
        self.selectedIndexPath = indexPath
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    
    //MARK:- FeedPostCellDelegate
    
    func feedLikeDidSelect(user: [String : Any]) {
        let likeVC = Object(LikeViewController.self)
        likeVC.user = user
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    
    func feedProfileDidSelect(user: [String : Any]) {
        let profile = Object(ProfileSegmentViewController.self)//Object(ProfileViewController.self)
        if let id = user[ConstantKey.userid] as? String ,id == firebaseUser.uid {
            profile.isOtherUserProfile = false
        }
        else {
            profile.isOtherUserProfile = true
            profile.userProfileData = user//NSMutableDictionary(dictionary: user)
        }
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    func feedCommentDidSelect(post: [String : Any], user: [String : Any]) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let commentVC = Object(CommentVC.self)
        commentVC.post = post
        commentVC.user = user
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func feedShareDidSelect(post: [String : Any], user: [String : Any]) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let sharePostVC = Object(SharePostViewController.self)
        sharePostVC.post = post
        sharePostVC.user = user
        self.navigationController?.pushViewController(sharePostVC, animated: true)
    }
    
    func feedDidDelete(post: [String : Any], user: [String : Any]) {
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            HUD.show()
            
            func deleteSharePost() {
                
                guard let postID = post[ConstantKey.id] as? String else {return}
                
                self.shareRef.observeSingleEvent(of: DataEventType.value, with: { (snap) in
                    if let value = snap.value as? [String:Any] {
                        
                        var sharePostKeys:[String:String] = [String:String]()
                        for (k,v) in value {
                            if let sharePost = v as? [String:Any] {
                                for (k1,v1) in sharePost {
                                    if let originalPost = v1 as? [String:Any] {
                                        if let pID = originalPost[ConstantKey.postID] as? String , pID == postID {
                                            sharePostKeys[k] = k1
                                        }
                                    }
                                }
                            }
                        }
                        
                        for (k,v) in sharePostKeys {
                            self.shareRef.child(k).child(v).removeValue()
                        }
                        //MARK:- Refresh UI
                        HUD.dismiss()
                        
                        self.tableView.reloadData()
                    }
                    else {
                        //MARK:- Refresh UI
                        HUD.dismiss()
                        self.tableView.reloadData()
                    }
                })
            }
            
            func deletePost() {
                guard let userID = post[ConstantKey.userid] as? String else {return}
                guard let postID = post[ConstantKey.id] as? String else {return}
                self.feedRef.child(userID).child(postID).removeValue(completionBlock: { (error, ref) in
                    deleteSharePost()
                })
            }
            
            if let image = post[ConstantKey.image] as? String  {
                let storage = Storage.storage()
                if let type = post[ConstantKey.contentType] as? String , type == ConstantKey.video {
                    if let thumb = post[ConstantKey.thumb_image] as? String {
                        let storageRef = storage.reference(forURL: thumb)
                        storageRef.delete(completion: { (error) in
                            let storageRef = storage.reference(forURL: image)
                            storageRef.delete(completion: { (error) in
                                deletePost()
                            })
                        })
                    }
                }
                else {
                    let storageRef = storage.reference(forURL: image)
                    storageRef.delete(completion: { (error) in
                        deletePost()
                    })
                }
            }
            else {
                deletePost()
            }
            //            JDB.log("Delete Object ==>%@", self.object)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel) { (action) in
            
        }
        
        self.showAlert(message: "Are you sure to delete post ?", actions: yesAction,noAction)
    }
    
    //MARK:- UserSearchDelegate
    func userDidSelect(_ data: [String:Any]) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let profileVC = Object(ProfileSegmentViewController.self)
        profileVC.isOtherUserProfile = true
        profileVC.userProfileData = data //NSMutableDictionary(dictionary: data)
        self.parent?.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
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


extension FeedViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //        if keyPath == #keyPath(UITableView.contentOffset) {
        //            if let playIndexPath = currentPlayIndexPath {
        //                if let cell = tableView.cellForRow(at: playIndexPath) as? PostCell {
        //                    let visibleCells = tableView.visibleCells
        //                    if visibleCells.contains(cell) {
        //                        if cell.type == .video {
        ////                            if self.isViewShow == false {
        ////                                return
        ////                            }
        ////
        ////                            //print("Current indexPath ==>%@", playIndexPath)
        ////                            if let dsPView = player.displayView as? VGEmbedPlayerView {
        ////                                if playIndexPath != dsPView.indexPath {
        ////                                    self.player.cleanPlayer()
        ////                                    self.player.displayView.removeFromSuperview()
        ////                                }
        ////                            }
        ////
        ////                            if let ply = player.player?.isPlaying , ply == true {
        ////
        ////                            }
        ////                            else {
        ////                                let feed = self.feedData[playIndexPath.row]
        ////                                if let type = feed[ConstantKey.contentType] as? String {
        ////                                    if let url = feed[ConstantKey.image] as? String {
        ////                                        if type == ConstantKey.video {
        ////                                            let videoURL = URL(string: url)!
        ////
        ////                                            self.player.replaceVideo(videoURL)
        ////                                            if let view = self.player.displayView as? VGEmbedPlayerView {
        ////                                                view.indexPath = self.currentPlayIndexPath
        ////                                            }
        ////                                            cell.playerContentView.addSubview(self.player.displayView)
        ////
        ////                                            if let duration = feed[ConstantKey.duration] as? Double , duration < 70 {
        ////                                                player.play()
        ////                                            }
        ////
        ////                                            self.player.displayView.snp.remakeConstraints {
        ////                                                $0.edges.equalTo(cell.playerContentView)
        ////                                            }
        ////                                        }
        ////                                    }
        ////                                }
        ////                            }
        //                        }
        //                        else {
        //                            self.player.displayView.removeFromSuperview()
        //                            self.player.cleanPlayer()
        //                        }
        //                    } else {
        //                        self.player.displayView.removeFromSuperview()
        //                        self.player.cleanPlayer()
        //                    }
        //                } else {
        //                    player.cleanPlayer()
        //                    self.player.displayView.removeFromSuperview()
        //                }
        //            }
        //            else {
        //                player.cleanPlayer()
        //                self.player.displayView.removeFromSuperview()
        //            }
        //        }
    }
}
