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


class ProfileViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate , UITableViewDelegate , UITableViewDataSource{
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var btnFollow: UIButton!
    
    
    var ref: DatabaseReference = Database.database().reference()
    var feedData:NSMutableArray = NSMutableArray()
    var allFeed:NSDictionary = NSDictionary()
    
    var isOtherUserProfile:Bool = false
    var userProfileData:NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.tableView.isHidden = true
        if isOtherUserProfile {
            self.checkFollow()
            if let url = userProfileData.value(forKey: ConstantKey.image) as? String {
                self.profileImageView.pin_setImage(from: URL(string: url), placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"))
            }
            self.userNameLabel.text = userProfileData.value(forKey: ConstantKey.username) as? String
            self.btnFollow.isHidden = false
        }
        else {
            if let url = firebaseUser.photoURL {
                self.profileImageView.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"))
            }
            self.userNameLabel.text = firebaseUser.displayName
            self.btnFollow.isHidden = true
            self.getFeed()
        }
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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationItem.rightBarButtonItem = nil
        self.parent?.navigationItem.leftBarButtonItem = nil
        self.parent?.navigationItem.title = "Profile"
    }
    
    
    @IBAction func btnFollowAction(_ sender: UIButton) {
        if sender.tag == 0 {
            BasicStuff.shared.followArray.add(userProfileData.value(forKey: ConstantKey.id) as! String)
        }
        else {
            BasicStuff.shared.followArray.remove(userProfileData.value(forKey: ConstantKey.id) as! String)
        }
        BasicStuff.shared.UserData.setValue(BasicStuff.shared.followArray, forKey: ConstantKey.follow)
        
        HUD.show()
        self.ref.child(ConstantKey.Users).child(firebaseUser.uid).setValue(BasicStuff.shared.UserData) { (error, ref) in
            HUD.dismiss()
            if error == nil  {
                self.checkFollow()
            }
        }
    }

    func checkFollow() {
        if BasicStuff.shared.followArray.contains(userProfileData.value(forKey: ConstantKey.id) as! String) {
            self.btnFollow.tag = 1
            self.btnFollow.setTitle("Following", for: .normal)
        }
        else {
            self.btnFollow.tag = 0
            self.btnFollow.setTitle("Follow", for: .normal)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.profileImageView.image = image
            
            HUD.show()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueFileName())
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
                                    
                                    self.ref.child(ConstantKey.Users).child(firebaseUser.uid).setValue(json, withCompletionBlock: { (error, databaseRef) in
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
    
    
    func getFeed() {
//        HUD.show()
        self.ref.child(ConstantKey.feed).queryOrdered(byChild: ConstantKey.userid).queryEqual(toValue: firebaseUser.uid).observe(.value) { (snapshot) in
//            HUD.dismiss()
            if let value = snapshot.value as? NSDictionary {
                self.allFeed = value
                    self.feedData = NSMutableArray()
                    for (k,v) in self.allFeed {
                        if let data = v as? NSDictionary {
                            let mutableData = NSMutableDictionary(dictionary: data)
                            mutableData.setValue(k, forKey: "id")
                            self.feedData.add(mutableData)
                        }
                    }
                    self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    self.tableView.isHidden = false
                })
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
        cell.likeImg.isUserInteractionEnabled = false
        return cell
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

