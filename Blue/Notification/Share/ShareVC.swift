//
//  ShareVC.swift
//  
//
//  Created by DK on 9/12/18.
//

import UIKit
import Firebase
import VGPlayer

class ShareVC: UIViewController , UITableViewDataSource , UITableViewDelegate ,FeedPostCellDelegate {

    
    @IBOutlet weak var shareTableView: UITableView!

    var follow:[String] = [String]()
    
    var ref = Database.database().reference()
    
    var shareTableData:[[String:Any]] = [[String:Any]]()
    
    var player : VGPlayer!
    var playerView : VGEmbedPlayerView!
    var currentPlayIndexPath : IndexPath?
    var playerViewSize : CGSize?
    
    var isViewShow:Bool = false
    var isFirstTime:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shareTableView.register(UINib(nibName: "ShareTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareTableViewCell")
        self.shareTableView.register(UINib(nibName: "ShareImageTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareImageTableViewCell")
        self.shareTableView.register(UINib(nibName: "ShareVideoTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareVideoTableViewCell")
        
        self.configurePlayer()
        addTableViewObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        player.pause()
        self.isViewShow = false
    }
    
    deinit {
        if player != nil {
            player.cleanPlayer()
        }
        self.removeTableViewObservers()
    }
    
    func configurePlayer() {
        playerView = VGEmbedPlayerView()
        player = VGPlayer(playerView: playerView)
        player.backgroundMode = .suspend
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func getRefresh() {
        self.follow = BasicStuff.shared.followArray.map({$0 as! String})
        self.follow.append(firebaseUser.uid)
        self.shareTableData = [[String:Any]]()
        self.isFirstTime = true
        self.getShareData(count: 0)
    }
    func addTableViewObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        self.shareTableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentOffset), options: options, context: nil)
    }
    
    func removeTableViewObservers() {
        self.shareTableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentOffset))
    }
    
    
    //func get All FollowData
    func getShareData(count:Int) {
        if count >= self.follow.count {
            self.getShareContent(count:0)
            return
        }
        let id = self.follow[count]
        
        self.ref.child(ConstantKey.share).child(id).observeSingleEvent(of: .value) { (snapshot) in
            if let response = snapshot.value as? [String:Any] {
                JDB.log("Response ==>%@", response)
                let data = response.map({$1 as! [String:Any]})
                for item in data {
                    self.shareTableData.append(item)
                }
                
            }
            let nextCount = count + 1
            DispatchQueue.main.async {
                self.getShareData(count: nextCount)
            }
        }
    }
    
    func getShareContent(count:Int) {
        
        if count >= self.shareTableData.count {
            self.shareTableData = self.shareTableData.sorted(by: {($0[ConstantKey.date] as! Double) > ($1[ConstantKey.date] as! Double)})
            JDB.log("Share data ==>%@", self.shareTableData)
            if self.isFirstTime {
                self.isFirstTime = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    let visibleCell = self.shareTableView.visibleCells
                    for item in visibleCell {
                        if let cell = item as? ShareTableViewCell , cell.postType == .video {
                            self.currentPlayIndexPath = cell.indexPath
                            self.observeValue(forKeyPath: #keyPath(UITableView.contentOffset), of: self.shareTableView, change: nil, context: nil)
                        }
                    }
                }
            }
            self.shareTableView.reloadData()
            return
        }
        else {
            
            let object = self.shareTableData[count]
            
            let postUserID = object[ConstantKey.userid] as! String
            let postID = object[ConstantKey.postID] as! String

            self.ref.child(ConstantKey.feed).child(postUserID).child(postID).observe(.value) { (snapshot) in
                if let post = snapshot.value as? [String:Any] {
                    self.shareTableData[count][ConstantKey.post] = post
                }
                let nextCount = count + 1
                DispatchQueue.main.async {
                    self.getShareContent(count: nextCount)
                }
            }
        }
    }
    
    //MARK:- UItableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.shareTableData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = shareTableData[indexPath.row]
        let contentType:PostType = PostType(rawValue: object[ConstantKey.contentType] as! Int)!
        let cell = tableView.dequeueReusableCell(postType: contentType)
        
        if contentType == .video {
            self.currentPlayIndexPath = indexPath
        }
        
        cell.indexPath = indexPath
        cell.object = object
        cell.delegate = self
        self.currentPlayIndexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
        view.backgroundColor = UIColor.lightGray
        return view
    }
    
    func addPlayer(_ cell: UITableViewCell) {
        if player != nil {
            player.cleanPlayer()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
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
}

extension UITableView {
    func dequeueReusableCell(postType:PostType) -> ShareTableViewCell {
        var identifire = ""
        switch postType {
        case .caption:
            identifire = "ShareTableViewCell"
            break
        case .image:
            identifire = "ShareImageTableViewCell"
            break
        case .video:
            identifire = "ShareVideoTableViewCell"
            break
        }
        let cell = self.dequeueReusableCell(withIdentifier: identifire) as! ShareTableViewCell
        cell.postType = postType
        return cell
    }
}

extension ShareVC {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(UITableView.contentOffset) {
            
            if let playIndexPath = currentPlayIndexPath {
                if let cell = shareTableView.cellForRow(at: playIndexPath) as? ShareTableViewCell {
                    if player.displayView.isFullScreen { return }
                    let visibleCells = shareTableView.visibleCells
                    if visibleCells.contains(cell) {
                        let object = self.shareTableData[playIndexPath.row]
                        
                        if let type = object[ConstantKey.contentType] as? Double {
                            if let post = object[ConstantKey.post] as? [String:Any] {
                                if let url = post[ConstantKey.image] as? String {
                                    if type == 2 {
                                        let videoURL = URL(string: url)!
                                        
                                        self.player.replaceVideo(videoURL)
                                        
                                        if let view = self.player.displayView as? VGEmbedPlayerView {
                                            view.indexPath = self.currentPlayIndexPath
                                        }
                                        cell.playerContentView.addSubview(self.player.displayView)
                                        
                                        if let duration = post[ConstantKey.duration] as? Double , duration < 70 {
                                            player.play()
                                        }
                                        
                                        self.player.displayView.snp.remakeConstraints {
                                            $0.edges.equalTo(cell.playerContentView)
                                        }
                                    }
                                    else {
                                        self.player.displayView.removeFromSuperview()
                                        self.player.cleanPlayer()
                                    }
                                }
                            }
                        }
                    } else {
                        self.player.displayView.removeFromSuperview()
                        self.player.cleanPlayer()
                    }
                } else {
                    self.player.displayView.removeFromSuperview()
                    self.player.cleanPlayer()
                }
            }
            else {
                self.player.displayView.removeFromSuperview()
                self.player.cleanPlayer()
            }
        }
    }
}
