//
//  UserContentViewController.swift
//  Blue
//
//  Created by DK on 1/21/19.
//  Copyright © 2019 Tim. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
import SJSegmentedScrollView

class UserContentViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , SJSegmentedViewControllerViewSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userID:String = firebaseUser.uid
    
    var ref = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    
    var feedData:[[String:Any]] = [[String:Any]]()
    var allFeed:NSDictionary = NSDictionary()
    
    var currentUser:[String:Any] = [String:Any]()
    
    var layoutType:FeedLayout = FeedLayout.list {
        didSet(newValue) {
            if self.layoutType == .list {
                self.collectionView.isHidden = true
                self.tableView.isHidden = false
            }
            else {
                self.collectionView.isHidden = false
                self.tableView.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "PostCell", bundle: Bundle.main), forCellReuseIdentifier: "PostCell")
        self.tableView.register(UINib(nibName: "PostWithOutImageCell", bundle: Bundle.main), forCellReuseIdentifier: "PostWithOutImageCell")
        
        self.collectionView.register(UINib(nibName: "ProfileTextCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProfileTextCollectionViewCell")
        self.collectionView.register(UINib(nibName: "ProfileImageCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "ProfileImageCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        JDB.log("View will apear")
        self.feedData = [[String:Any]]()
        self.userRef.child(firebaseUser.uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let userData = snapshot.value as? [String:Any] else {return}
            if let layout = userData[ConstantKey.layout] as? Int {
                self.layoutType = FeedLayout(rawValue: layout)!
            }
            else {
                self.layoutType = .list
            }
        }
        
        self.getCurrentUserData()
        super.viewWillAppear(animated)
    }
    
    func getCurrentUserData() {
        JDB.log("Current User")
        self.userRef.child(self.userID).observeSingleEvent(of: .value) { (snap) in
            if let value = snap.value as? [String:Any] {
                self.currentUser = value
                self.getUserFeed()
            }
        }
    }
    
    func getUserFeed() {
        JDB.log("Get Feed")
        self.feedData = [[String:Any]]()
        self.feedRef.child(self.userID).observeSingleEvent(of: .value) { (snap) in
            if let value = snap.value as? [String:Any] {
                for (_,v) in value {
                    if var data = v as? [String:Any] {
                        data[ConstantKey.user] = self.currentUser
                        self.feedData.append(data)
                    }
                }
                
                let sortedArray = self.feedData.sorted(by: {($0[ConstantKey.date] as! Double) > $1[ConstantKey.date] as! Double})
                self.feedData = sortedArray
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
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
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            cell.type = .image
            cell.object = feed
            //cell.delegate = self
            cell.btnDelete.isHidden = true
            cell.likeImg.isUserInteractionEnabled = false
            return cell
            
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PostWithOutImageCell") as! PostCell
            cell.type = .caption
            cell.object = feed
            //cell.delegate = self
            cell.btnDelete.isHidden = true
            cell.likeImg.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feed = self.feedData[indexPath.row]
        let object = Object(PostViewController.self)
        object.object = feed
        self.navigationController?.pushViewController(object, animated: true)
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
                    strongSelf.collectionView(strongSelf.collectionView, didSelectItemAt: index)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feed = self.feedData[indexPath.row]
        let object = Object(PostViewController.self)
        object.object = feed
        self.navigationController?.pushViewController(object, animated: true)
    }
    
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        if self.layoutType == .list {
            return self.tableView
        }
        else {
            return self.collectionView
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
