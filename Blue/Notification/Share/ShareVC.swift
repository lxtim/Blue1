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
    
    var tableViewContext:UnsafeMutableRawPointer = UnsafeMutableRawPointer(bitPattern: 0)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shareTableView.register(UINib(nibName: "ShareTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareTableViewCell")
        self.shareTableView.register(UINib(nibName: "ShareImageTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareImageTableViewCell")
        self.shareTableView.register(UINib(nibName: "ShareVideoTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareVideoTableViewCell")
        
        self.addTableViewObservers()
    }
    
    deinit {
        player.cleanPlayer()
        self.removeTableViewObservers()
    }
    
    func configurePlayer() {
        playerView = VGEmbedPlayerView()
        player = VGPlayer(playerView: playerView)
        player.backgroundMode = .suspend
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.follow = BasicStuff.shared.followArray.map({$0 as! String})
        self.shareTableData = [[String:Any]]()
        self.getShareData(count: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.cleanPlayer()
    }
    
    
    func addTableViewObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        self.shareTableView.addObserver(self, forKeyPath: #keyPath(UITableView.contentOffset), options: options, context: &tableViewContext)
    }
    
    func removeTableViewObservers() {
        self.shareTableView.removeObserver(self, forKeyPath: #keyPath(UITableView.contentOffset))
    }
    
    
    //func get All FollowData
    func getShareData(count:Int) {
        if count >= self.follow.count {
            self.shareTableData = self.shareTableData.sorted(by: {($0[ConstantKey.date] as! Double) > ($1[ConstantKey.date] as! Double)})
            self.shareTableView.reloadData()
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
        cell.indexPath = indexPath
        cell.object = object
        cell.delegate = self
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
        if (context == &tableViewContext) {
            if keyPath == #keyPath(UITableView.contentOffset) {
                
                if let playIndexPath = currentPlayIndexPath {
                    if let cell = shareTableView.cellForRow(at: playIndexPath) as? ShareTableViewCell {
                        if player.displayView.isFullScreen { return }
                        let visibleCells = shareTableView.visibleCells
                        if visibleCells.contains(cell) {
                            if cell.postType == .video {
                                if let playing = self.player.player?.isPlaying , playing == true {
                                    
                                }
                                else {
                                    if let contentView = cell.playerContentView {
                                        self.playerViewSize = contentView.bounds.size
                                        self.addPlayer(cell)
                                        self.currentPlayIndexPath = cell.indexPath
                                        if let url = cell.videoURL {
                                            self.player.replaceVideo(url)
                                            if cell.autoPlay {
                                                self.player.play()
                                            }
                                        }
                                    }
                                }
                            }
//                            smallScreenView.removeFromSuperview()
                            cell.contentView.addSubview(player.displayView)
                            player.displayView.snp.remakeConstraints {
                                $0.edges.equalTo(cell.playerContentView)
                            }
//                            playerView.isSmallMode = false
                        } else {
                            
                            //addSmallScreenView()
                            JDB.log("Window gone")
                        }
                    } else {
                        if isViewLoaded && (view.window != nil) {
//                            if smallScreenView.superview != UIApplication.shared.keyWindow {
//                                addSmallScreenView()
//                            }
                        }
                    }
                }
            }
        }
    }
}
