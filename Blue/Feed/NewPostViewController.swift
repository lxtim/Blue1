//
//  NewPostViewController.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase
import VGPlayer
import MobileCoreServices
import AVFoundation

class NewPostViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate , UITextViewDelegate , StorySelctionDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    var player: VGPlayer!
    
    @IBOutlet weak var playerContentView: UIView!
    var isVideo = false
    
    var storyType:String = StoryType.regular
    
    var imagePicker = UIImagePickerController()
    var ref: DatabaseReference = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.playerContentView.isHidden = true
        let playerView = VGEmbedPlayerView()
        self.player = VGPlayer(playerView: playerView)
        
        self.playerContentView.addSubview(self.player.displayView)
        self.player.displayView.snp.makeConstraints {
            $0.edges.equalTo(self.playerContentView)
        }
    }
    
    @IBAction func btnAddImageAction(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Camera", style: .default) { (cameraAction) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                self.imagePicker.mediaTypes = ["public.image"]
//                self.imagePicker.mediaTypes = ["public.image", "public.movie"]
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        let GalleryAction = UIAlertAction(title: "Photo Library", style: .default) { (gallery) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .photoLibrary;
                self.imagePicker.mediaTypes = ["public.image"]
                //                self.imagePicker.sourceType = .photoLibrary;
                //                self.imagePicker.mediaTypes = ["public.image", "public.movie"]
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
    @IBAction func btnShareAction(_ sender: UIBarButtonItem) {
        var caption = ""
        if let cap = self.descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ,cap != "" {
            caption = cap
        }
        
        if self.isVideo {
            HUD.show()
            if let curentItem = self.player.player?.currentItem {
                guard let assetURL = curentItem.asset as? AVURLAsset else {return}
                
                let url = assetURL.url
                VideoCompressor.compressVideoWithQuality(inputURL: url) { (outputURL) in
                    
                    self.uploadVideoTofirebase(outputURL, completion: { (firebaseVideoUrl) -> (Void) in
                        guard let videoURL = firebaseVideoUrl else {
                            HUD.dismiss()
                            self.showAlert("Error!!!")
                            return
                        }
                        
                        let image = self.imageView.image?.resizeWithWidthOrHeight(200)
                        //let image = self.imageView.image
                        if let img = image {
                            self.uploadThumbImage(img, completion: { (thumbURL:URL?) -> (Void) in
                                guard let thumb = thumbURL else {
                                    HUD.dismiss()
                                    self.showAlert("Error!!!")
                                    return
                                }
                                DispatchQueue.main.async {
                                    let postRef = self.ref.child(ConstantKey.feed).child(firebaseUser.uid).childByAutoId()
                                    var json = [String:Any]()
                                    json[ConstantKey.userid] = firebaseUser.uid
                                    json[ConstantKey.image] = videoURL.absoluteString
                                    json[ConstantKey.thumb_image] = thumb.absoluteString
                                    json[ConstantKey.contentType] = ConstantKey.video
                                    json[ConstantKey.caption] = caption
                                    json[ConstantKey.likes] = []
                                    json[ConstantKey.date] = Date().timeStamp
                                    json[ConstantKey.duration] = CMTimeGetSeconds(curentItem.duration)
                                    json[ConstantKey.id] = postRef.key
                                    
                                    postRef.setValue(json, withCompletionBlock: { (error, databaseRef) in
                                        HUD.dismiss()
                                        self.navigationController?.popViewController(animated: true)
                                        
                                        //                                        let okaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                        //                                            self.navigationController?.popViewController(animated: true)
                                        //                                        })
                                        //                                        self.showAlert(title: "Post shared successfully ", message: nil, actions: okaction)
                                        //                                        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                        //                                            databaseRef.updateChildValues([ConstantKey.id:snapshot.key])
                                        //                                        })
                                    })
                                }
                            })
                        }
                        else {
                            HUD.dismiss()
                            self.showAlert("Error!!!")
                        }
                    })
                }
            }
        }
        else {
            //let image = self.imageView.image?.resizeWithWidthOrHeight(700)
            let image = self.imageView.image
            
            if image == nil && caption == "" {
                self.showAlert("Please set image or enter caption")
                return
            }
            
            HUD.show()
            
            if let img = image {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                
                let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueImageFileName())
                let storageMetaData = StorageMetadata()
                storageMetaData.contentType = "image/png"
                imageRef.putData(UIImageJPEGRepresentation(img, 0.5)!, metadata: storageMetaData) { (metadata, error) in
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
                                let postRef = self.ref.child(ConstantKey.feed).child(firebaseUser.uid).childByAutoId()
                                var json = [String:Any]()
                                json[ConstantKey.userid] = firebaseUser.uid
                                json[ConstantKey.image] = downloadURL.absoluteString
                                json[ConstantKey.contentType] = ConstantKey.image
                                json[ConstantKey.caption] = caption
                                json[ConstantKey.likes] = []
                                json[ConstantKey.date] = Date().timeStamp
                                json[ConstantKey.id] = postRef.key
                                json[ConstantKey.storyType] = self.storyType
                                postRef.setValue(json, withCompletionBlock: { (error, databaseRef) in
                                    HUD.dismiss()
                                    self.navigationController?.popViewController(animated: true)
                                    //                                    let okaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                    //                                        self.navigationController?.popViewController(animated: true)
                                    //                                    })
                                    //                                    self.showAlert(title: "Post shared successfully ", message: nil, actions: okaction)
                                    
                                    //                                    databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                                    //                                        databaseRef.updateChildValues([ConstantKey.id:snapshot.key])
                                    //
                                    //                                    })
                                })
                            }
                        })
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    let postRef = self.ref.child(ConstantKey.feed).child(firebaseUser.uid).childByAutoId()
                    
                    var json = [String:Any]()
                    json[ConstantKey.userid] = firebaseUser.uid
                    json[ConstantKey.caption] = caption
                    json[ConstantKey.likes] = []
                    json[ConstantKey.date] = Date().timeStamp
                    json[ConstantKey.id] = postRef.key
                    json[ConstantKey.storyType] = self.storyType
                    postRef.setValue(json, withCompletionBlock: { (error, databaseRef) in
                        HUD.dismiss()
                        self.navigationController?.popViewController(animated: true)
                        //                        let okaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                        //                            self.navigationController?.popViewController(animated: true)
                        //                        })
                        //                        self.showAlert(title: "Post shared successfully ", message: nil, actions: okaction)
                        //                        databaseRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        //                            databaseRef.updateChildValues([ConstantKey.id:snapshot.key])
                        //
                        //                        })
                    })
                }
            }
        }
    }
    
    
    func uploadVideoTofirebase(_ url:URL , completion:@escaping ((_ firebaseUrl:URL?)->(Void))) {
        do {
            let data = try Data(contentsOf: url)
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueVideoFileName())
            let storageMetaData = StorageMetadata()
            storageMetaData.contentType = "video/mp4"
            
            imageRef.putData(data, metadata: storageMetaData, completion: { (fileMetadata, error) in
                if fileMetadata == nil {
                    completion(nil)
                    return
                }
                imageRef.downloadURL(completion: { (url, error) in
                    guard let downloadURL = url else {
                        completion(nil)
                        return
                    }
                    completion(downloadURL)
                })
            })
            
        }
        catch {
            completion(nil)
        }
    }
    
    func uploadThumbImage(_ image:UIImage, completion:@escaping((_ thumbURL:URL?)->(Void))) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueImageFileName())
        let storageMetaData = StorageMetadata()
        storageMetaData.contentType = "image/png"
        imageRef.putData(UIImageJPEGRepresentation(image, 0.5)!, metadata: storageMetaData) { (metadata, error) in
            if metadata == nil {
                completion(nil)
                return
            }
            imageRef.downloadURL(completion: { (url, error) in
                guard let downloadURL = url else {
                    completion(nil)
                    return
                }
                completion(downloadURL)
            })
        }
    }
    
    //MARK:- StorySelectionDelegate
    func storyTypeDidSelect(_ type: String) {
        self.storyType = type
    }
    
    //MARK:- UIImagePicker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
            JDB.log("Image selected")
            self.isVideo = false
        }
        else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            JDB.log("video detected -==>%@",videoURL)
            if let image = getThumbnailImage(forUrl: videoURL) {
                self.imageView.image = image
            }
            self.player.replaceVideo(videoURL)
            self.playerContentView.isHidden = false
            self.isVideo = true
        }
        
        self.dismiss(animated: true, completion: { () -> Void in
        })
    }
    //MARK:- UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        if numberOfChars > 5000 { return false }
        else { return true }
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
