//
//  Profile.swift
//  Blue
//
//  Created by Tim Schönenberger on 05.08.18.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage
import VGPlayer


class ProfileViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate , UITableViewDelegate , UITableViewDataSource , FeedPostCellDelegate , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var btnFollow: UIButton!
    
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!
    
    @IBOutlet weak var followStackView: UIStackView!

    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var ref = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    
    var feedData:[[String:Any]] = [[String:Any]]()
    var allFeed:NSDictionary = NSDictionary()
    
    var isOtherUserProfile:Bool = false
    var userProfileData:NSMutableDictionary = NSMutableDictionary()
    
    var followers:[[String:Any]] = [[String:Any]]()
    
    
    var player: VGPlayer?
    var playerView = VGCollectionPlayerView()
    var currentPlayIndexPath : IndexPath?
    
    var lastContentOffset: CGFloat = 0.0
    
    var layoutType:FeedLayout = FeedLayout.list {
        didSet(newValue) {
            if self.layoutType == .list {
                self.collectionView.isHidden = true
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            else {
                self.collectionView.isHidden = false
                self.tableView.isHidden = true
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCell")
        self.tableView.register(UINib(nibName: "PostWithOutImageCell", bundle: Bundle.main), forCellReuseIdentifier: "PostWithOutImageCell")
        self.tableView.register(UINib(nibName: "VideoCell", bundle: Bundle.main), forCellReuseIdentifier: "VideoCell")
        
        
        self.collectionView.register(UINib(nibName: "ProfileTextCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProfileTextCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProfileImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProfileImageCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProfileVideoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProfileVideoCollectionViewCell")
        
        self.tableView.isHidden = true
        self.collectionView.isHidden = true
        
        if isOtherUserProfile {
            self.checkFollow()
            self.getNumberOfPost()
            if let url = userProfileData.value(forKey: ConstantKey.image) as? String {
                self.profileImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
            }
            self.userNameLabel.text = userProfileData.value(forKey: ConstantKey.username) as? String
//            self.btnFollow.setTitle("Follow", for: .normal)
//            self.btnFollow.borderColor = UIColor("54C7FC")
//            self.btnFollow.setTitleColor(UIColor("54C7FC"), for: .normal)
//            self.btnFollow.backgroundColor = .clear
        }
        else {
            self.btnFollow.setTitle("Settings", for: .normal)
            self.btnFollow.borderColor = UIColor("9B9B9B")
            self.btnFollow.setTitleColor(UIColor("9B9B9B"), for: .normal)
            self.btnFollow.backgroundColor = .clear
            self.getFeed()
        }
        self.addObserver()
    }
    
    func addObserver() {
        let option:NSKeyValueObservingOptions = [.new , .initial]
        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: option, context: nil)
    }
    
    func removeObjserver() {
        self.scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    deinit {
        self.removeObjserver()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isOtherUserProfile {
            self.captionLabel.text = userProfileData[ConstantKey.caption] as? String
//            if let layout = userProfileData[ConstantKey.layout] as? Int {
//                self.layoutType = FeedLayout(rawValue: layout)!
//            }
        }
        else {
            self.userRef.child(firebaseUser.uid).observeSingleEvent(of: .value) { (snapshot) in
                guard let userData = snapshot.value as? [String:Any] else {return}
                if let image = userData[ConstantKey.image] as? String {
                    self.profileImageView.sd_setImage(with: URL(string: image)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
                self.captionLabel.text = userData[ConstantKey.caption] as? String
                self.userNameLabel.text = userData[ConstantKey.username] as? String
                
                if let layout = userData[ConstantKey.layout] as? Int {
                    self.layoutType = FeedLayout(rawValue: layout)!
                }
                else {
                    self.layoutType = .list
                }
            }
        }
        
        if let parent = self.parent as? PageViewController {
            let settingItem:UIBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnSettingAction(_:)))
            parent.navigationItem.title = "Profile"
            parent.navigationItem.leftBarButtonItem = nil
//            parent.navigationItem.rightBarButtonItems = [settingItem]
        }
        else {
            self.navigationItem.title = "Profile"
        }
        
        self.scrollView.scrollRectToVisible(CGRect(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.size.width, height: 50)), animated: false)
        self.getFollowing()
        self.getFollowers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let parent = self.parent as? PageViewController {
            
            let settingItem:UIBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.done, target: self, action: #selector(btnSettingAction(_:)))
            
            parent.navigationItem.title = "Profile"
            parent.navigationItem.leftBarButtonItem = nil
//            parent.navigationItem.rightBarButtonItems = [settingItem]
        }
        else {
            self.navigationItem.title = "Profile"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.removeFromSuperview()
        player?.cleanPlayer()
        currentPlayIndexPath = nil
    }
    @objc func btnSettingAction(_ sender:UIButton) {
        let object = Object(SettingViewController.self)
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    @IBAction func imageViewDidTapAction(_ sender: UITapGestureRecognizer) {
        if isOtherUserProfile == true {
            return
        }
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Camera", style: .default) { (cameraAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let GalleryAction = UIAlertAction(title: "Photo Library", style: .default) { (gallery) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.allowsEditing = false
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in
            
        }
        
        actionSheet.addAction(action)
        actionSheet.addAction(GalleryAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true) {}
    }
    @IBAction func btnFollowAction(_ sender: UIButton) {
        if self.isOtherUserProfile == false {
            self.btnSettingAction(sender)
         return
        }
        else if sender.tag == 0 {
            BasicStuff.shared.followArray.add(userProfileData.value(forKey: ConstantKey.id) as! String)
            self.sendFollowNotification()
        }
        else {
            BasicStuff.shared.followArray.remove(userProfileData.value(forKey: ConstantKey.id) as! String)
        }
        BasicStuff.shared.UserData.setValue(BasicStuff.shared.followArray, forKey: ConstantKey.follow)
        
        HUD.show()
        self.userRef.child(firebaseUser.uid).setValue(BasicStuff.shared.UserData) { (error, ref) in
            HUD.dismiss()
            if error == nil  {
                self.checkFollow()
            }
        }
    }

    func sendFollowNotification() {
        let adminUserID = userProfileData[ConstantKey.id] as! String
        let followUserID = firebaseUser.uid
        if adminUserID != followUserID {
            var json = [String:Any]()
            json[ConstantKey.image] = userProfileData[ConstantKey.image]
            json[ConstantKey.id] = followUserID
            json[ConstantKey.date] = Date().timeStamp
            json[ConstantKey.contentType] = NotificationType.follow.rawValue
            self.ref.child(ConstantKey.notification).child(adminUserID).child(adminUserID).setValue(json) { (error, ref) in
                if error == nil {

                }
            }
        }
    }
    
    @IBAction func btnFollowersAction(_ sender: UIButton) {
        let action = Object(FollwersViewController.self)
        action.followers = followers
        self.navigationController?.pushViewController(action, animated: true)
    }
    
    @IBAction func btnFollowingAction(_ sender:UIButton) {
        if self.isOtherUserProfile {
            if let following = userProfileData.value(forKey: ConstantKey.follow) as? NSArray {
                if following.count > 0 {
                    let followingVC = Object(FollowingViewController.self)
                    followingVC.followingUsers = following.map({$0 as! String})
                    self.navigationController?.pushViewController(followingVC, animated: true)
                }
                else {
                    return
                }
            }
            else {
                return
            }
        }
        else {
            if BasicStuff.shared.followArray.count > 0 {
                let followingVC = Object(FollowingViewController.self)
                followingVC.followingUsers = BasicStuff.shared.followArray.map({$0 as! String})
                self.navigationController?.pushViewController(followingVC, animated: true)
            }
            else {
                return
            }
        }
    }
    
    func checkFollow() {
        if BasicStuff.shared.followArray.contains(userProfileData.value(forKey: ConstantKey.id) as! String) {
            self.btnFollow.tag = 1
            self.btnFollow.setTitle("Following", for: .normal)
            self.btnFollow.borderColor = UIColor("54C7FC")
            self.btnFollow.setTitleColor(UIColor("54C7FC"), for: .normal)
            self.btnFollow.backgroundColor = .clear
        }
        else {
            self.btnFollow.tag = 0
            self.btnFollow.setTitle("Follow", for: .normal)
            self.btnFollow.borderColor = UIColor("54C7FC")
            self.btnFollow.setTitleColor(.white, for: .normal)
            self.btnFollow.backgroundColor = UIColor("54C7FC")
            
        }
    }
    func getFeed() {
        self.feedData = [[String:Any]]()
        self.userRef.child(firebaseUser.uid).observe(.value) { (snapshot) in
            self.feedRef.child(firebaseUser.uid).observe(.value, with: { (snap) in
                if let value = snap.value as? [String:Any] {
                    var isItemChanged:Bool = false
                    var changedIndex:[Int] = [Int]()
                    
                    for (k,v) in value {
                        if var data = v as? [String:Any] {
                            data[ConstantKey.user] = snapshot.value
                            data[ConstantKey.id] = k
                            if let index = self.feedData.index(where: {($0[ConstantKey.id] as! String) == k}) {
                                self.feedData.remove(at: index)
                                changedIndex.append(index)
                                isItemChanged = true
                            }
                            self.feedData.append(data)
                        }
                    }
                    if isItemChanged {
                        let indexPaths = changedIndex.map({IndexPath(row: $0, section: 0)})
                        self.tableView.reloadRows(at: indexPaths, with: .none)
                    }
                    else {
                        let sortedArray = self.feedData.sorted(by: {($0[ConstantKey.date] as! Double) > $1[ConstantKey.date] as! Double})
                        self.feedData = sortedArray
                        self.tableView.reloadData()
                        self.collectionView.reloadData()
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                            self.postLabel.text = "\(self.feedData.count)"
                        })
                    }
                }
            })
        }
    }
    func getFollowing() {
        if self.isOtherUserProfile {
            if let following = userProfileData.value(forKey: ConstantKey.follow) as? NSArray {
                self.followingLabel.text = "\(following.count)"
            }
            else {
                self.followingLabel.text = "0"
            }
        }
        else {
            self.followingLabel.text = "\(BasicStuff.shared.followArray.count)"
        }
    }
    
    func getFollowers() {
        self.followers = [[String:Any]]()
        self.userRef.observe(.value) { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                if let allUsersValue = value.allValues as? [[String:Any]] {
                    self.followers = [[String:Any]]()
                    for item in allUsersValue {
                        if let follow = item[ConstantKey.follow] as? [String] {
                            var id = firebaseUser.uid
                            if self.isOtherUserProfile {
                                id = self.userProfileData[ConstantKey.id] as! String
                            }
                            if follow.contains(id) {
                                self.followers.append(item)
                            }
                        }
                    }
                }
            }
            self.followersLabel.text = "\(self.followers.count)"
        }
    }
    
    func getNumberOfPost() {
        let userID = userProfileData.value(forKey: ConstantKey.id) as! String
        self.feedRef.child(userID).observeSingleEvent(of: .value) { (snap) in
            self.postLabel.text = "\(snap.childrenCount)"
        }
    }
    //MARK:- UIImagepickerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = image
            
            HUD.show()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueImageFileName())
            let storageMetaData = StorageMetadata()
            storageMetaData.contentType = "image/png"
            
            imageRef.putData(UIImageJPEGRepresentation(image, 0.8)!, metadata: storageMetaData) { (metadata, error) in
                if metadata == nil {
                    HUD.dismiss()
                    return
                }
                DispatchQueue.main.async {
                    imageRef.downloadURL(completion: { (url, error) in
                        guard let downloadURL = url else {
                            HUD.dismiss()
                            return
                        }
                        DispatchQueue.main.async {
                            let changeRequest = firebaseUser.createProfileChangeRequest()
                            changeRequest.photoURL = downloadURL
                            changeRequest.commitChanges { error in
                                HUD.dismiss()
                                if error == nil {
                                    let json = [ConstantKey.id:firebaseUser.uid,
                                                ConstantKey.username:firebaseUser.displayName ?? "",
                                                ConstantKey.image:downloadURL.absoluteString,
                                                ConstantKey.email:firebaseUser.email ?? ""]
                                    
                                    self.userRef.child(firebaseUser.uid).setValue(json, withCompletionBlock: { (error, databaseRef) in
                                        HUD.dismiss()
                                        guard let error = error else {
                                            self.showAlert("Profile picture uploaded successfully")
                                            return
                                        }
                                        JDB.error("Data base error ==>%@", error.localizedDescription)
                                    })
                                } else {
                                    print("Error: \(error!.localizedDescription)")
                                }
                            }
                        }
                    })
                }
            }
        }
        
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
                cell.indexPath = indexPath
                cell.likeImg.isUserInteractionEnabled = false
                self.currentPlayIndexPath = indexPath
                cell.playCallBack = ({ [weak self] (indexPath: IndexPath?) -> Void in
                    guard let strongSelf = self else { return }
                    guard let index = indexPath else {return}
                    let feed = strongSelf.feedData[index.row]
                    strongSelf.addPlayer(cell, data: feed)
                    strongSelf.currentPlayIndexPath = indexPath
                })
                return cell
            }
            else {
                let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
                cell.type = .image
                cell.object = feed
                cell.delegate = self
                
                cell.likeImg.isUserInteractionEnabled = false
                return cell
            }
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostWithOutImageCell") as! PostCell
            cell.type = .caption
            cell.object = feed
            cell.delegate = self
            cell.likeImg.isUserInteractionEnabled = false
            return cell
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
        self.navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func feedShareDidSelect(post: [String : Any], user: [String : Any]) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 15)/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.feedData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feed = self.feedData[indexPath.row]
        if feed[ConstantKey.image] != nil {
            if let type = feed[ConstantKey.contentType] as? String , type == ConstantKey.video {
                let cell = collectionView.dequeueReusableCell(.video, indexPath: indexPath)
                cell.object = feed
                cell.indexPath = indexPath
                cell.playCallBack = ({ [weak self] (indexPath: IndexPath?) -> Void in
                    guard let strongSelf = self else { return }
                    guard let index = indexPath else {return}
                    let feed = strongSelf.feedData[index.row]
                    strongSelf.addPlayer(cell, data: feed)
                    strongSelf.currentPlayIndexPath = indexPath
                })
                return cell
            }
            else {
                let cell = collectionView.dequeueReusableCell(.image, indexPath: indexPath)
                cell.object = feed
                return cell
            }
        }
        else {
            let cell = collectionView.dequeueReusableCell(.caption, indexPath: indexPath)
            cell.object = feed
            return cell
        }
    }
    
    func addPlayer(_ cell: PostCell,data:[String:Any]) {
        if player != nil {
            player?.cleanPlayer()
        }
        configurePlayer()
        
        guard let player = player else {return}
        
        cell.contentView.addSubview(player.displayView)
        player.displayView.snp.makeConstraints {
            $0.edges.equalTo(cell.playerContentView)
        }
        
        if let url = data[ConstantKey.image] as? String {
            if cell.type == .video {
                player.replaceVideo(URL(string:url)!)
                player.play()
            }
        }
    }
    
    func addPlayer(_ cell: ProfileCollectionViewCell,data:[String:Any]) {
        if player != nil {
            player?.cleanPlayer()
        }
        configurePlayer()
        
        guard let player = player else {return}
        
        cell.contentView.addSubview(player.displayView)
        player.displayView.snp.makeConstraints {
            $0.edges.equalTo(cell.playerContentView)
        }
        
        if let url = data[ConstantKey.image] as? String {
            if cell.postType == .video {
                player.replaceVideo(URL(string:url)!)
                player.play()
            }
        }
    }
    
    func configurePlayer() {
        playerView = VGCollectionPlayerView()
        player = VGPlayer(playerView: playerView)
        player?.backgroundMode = .suspend
    }
    
    //MARK:- UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var scrollDirection: ScrollDirection!
        
        if lastContentOffset < scrollView.contentOffset.y {
//            print("Going up!")
            scrollDirection = ScrollDirection.up
        }else if lastContentOffset > scrollView.contentOffset.y {
//            print("Going down!")
            scrollDirection = ScrollDirection.down
        }
        lastContentOffset = scrollView.contentOffset.y
        
        var y = scrollView.contentOffset.y
        
        if scrollDirection == .up {
            y = y + self.scrollView.frame.size.height - 100
        }
        else {
            y = y + 100
        }
        
        let point = CGPoint(x: scrollView.contentOffset.x, y: y)
        if self.layoutType == .list {
            if let indexPath = self.tableView.indexPathForRow(at: point) {
                let feed = self.feedData[indexPath.row]
                if let type = feed[ConstantKey.contentType] as? String {
                    if type == ConstantKey.video {
                        if self.currentPlayIndexPath != indexPath {
                            player?.displayView.removeFromSuperview()
                            player?.cleanPlayer()
                        }
                        
                        self.currentPlayIndexPath = indexPath
                        if self.player == nil {
                            self.configurePlayer()
                        }
                        
                        guard let player = self.player else {return}
                        if let url = feed[ConstantKey.image] as? String {
                            let videoURL = URL(string: url)!
                            if let cell = self.tableView.cellForRow(at: indexPath) as? PostCell {
                                if player.player?.isPlaying == true {
                                    
                                }
                                else {
                                    player.replaceVideo(videoURL)
                                    
                                    cell.playerContentView.addSubview(player.displayView)
                                    
                                    if let duration = feed[ConstantKey.duration] as? Double , duration < 70 {
                                        player.play()
                                    }
                                    
                                    player.displayView.snp.remakeConstraints {
                                        $0.edges.equalTo(cell.playerContentView)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        else {
            if let indexPath = self.collectionView.indexPathForItem(at: point) {
                let feed = self.feedData[indexPath.item]
                if let type = feed[ConstantKey.contentType] as? String {
                    if type == ConstantKey.video {
                        if self.currentPlayIndexPath != indexPath {
                            player?.displayView.removeFromSuperview()
                            player?.cleanPlayer()
                        }
                    }
                }
            }
        }
    }

    
    //MARK:- Observe Value
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scroll = object as? UIScrollView {
            if scroll == self.scrollView {
                if keyPath == #keyPath(UIScrollView.contentOffset) {
                    if self.layoutType == .list {
                        self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
                        self.tableView.layoutIfNeeded()
                    }
                    if self.layoutType == .grid {
                        self.tableViewHeightConstraint.constant = self.collectionView.contentSize.height
                        self.tableView.layoutIfNeeded()
                    }
                }
            }
        }
        if let collectionView = object as? UICollectionView , collectionView == self.collectionView {
            if keyPath == #keyPath(UICollectionView.contentOffset) {
                if let playIndexPath = currentPlayIndexPath {
                    guard let player = self.player else {
                        return
                    }
                    
                    if let cell = self.collectionView.cellForItem(at: playIndexPath) as? ProfileCollectionViewCell {
                        let visibleCells = self.collectionView.visibleCells
                        if visibleCells.contains(cell) {
                            cell.playerContentView.addSubview(player.displayView)
                            player.displayView.snp.remakeConstraints {
                                $0.edges.equalTo(cell.playerContentView)
                            }
                        } else {
                            player.displayView.removeFromSuperview()
                            player.cleanPlayer()
                        }
                    }
                }
            }
        }
        
        if let tableView = object as? UITableView , tableView == self.tableView {
            if keyPath == #keyPath(UITableView.contentOffset) {
                if let playIndexPath = currentPlayIndexPath {
                    guard let player = self.player else {
                        return
                    }
                    
                    if let cell = self.tableView.cellForRow(at: playIndexPath) as? PostCell {
                        let visibleCells = self.tableView.visibleCells
                        if visibleCells.contains(cell) {
                            
                            //print("Current indexPath ==>%@", playIndexPath)
                            if let dsPView = player.displayView as? VGEmbedPlayerView {
                                if playIndexPath != dsPView.indexPath {
                                    player.cleanPlayer()
                                    player.displayView.removeFromSuperview()
                                }
                            }
                            
                            if let ply = player.player?.isPlaying , ply == true {
                                
                            }
                            else {
                                let feed = self.feedData[playIndexPath.row]
                                if let type = feed[ConstantKey.contentType] as? String {
                                    if let url = feed[ConstantKey.image] as? String {
                                        if type == ConstantKey.video {
                                            let videoURL = URL(string: url)!
                                            
                                            player.replaceVideo(videoURL)
                                            if let view = player.displayView as? VGEmbedPlayerView {
                                                view.indexPath = self.currentPlayIndexPath
                                            }
                                            cell.playerContentView.addSubview(player.displayView)
                                            
                                            if let duration = feed[ConstantKey.duration] as? Double , duration < 70 {
                                                player.play()
                                            }
                                            
                                            player.displayView.snp.remakeConstraints {
                                                $0.edges.equalTo(cell.playerContentView)
                                            }
                                        }
                                    }
                                    else {
                                        player.displayView.removeFromSuperview()
                                        player.cleanPlayer()
                                    }
                                }
                                else {
                                    player.displayView.removeFromSuperview()
                                    player.cleanPlayer()
                                }
                            }
                        }
                        else {
                            player.displayView.removeFromSuperview()
                            player.cleanPlayer()
                        }
                    }
                }
            }
        }
    }
}

extension UICollectionView {
    func dequeueReusableCell(_ postType:PostType , indexPath:IndexPath) -> ProfileCollectionViewCell {
        var identifire = ""
        switch postType {
        case .caption:
            identifire = "ProfileTextCollectionViewCell"
            break
        case .image:
            identifire = "ProfileImageCollectionViewCell"
            break
        case .video:
            identifire = "ProfileVideoCollectionViewCell"
            break
        }
        let cell = self.dequeueReusableCell(withReuseIdentifier: identifire, for: indexPath) as! ProfileCollectionViewCell
        cell.postType = postType
        return cell
    }
}

