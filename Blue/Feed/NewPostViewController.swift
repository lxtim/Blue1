//
//  NewPostViewController.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class NewPostViewController: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate , UITextViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var imagePicker = UIImagePickerController()
    
    var ref: DatabaseReference = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func btnAddImageAction(_ sender: UIButton) {
        
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
    @IBAction func btnShareAction(_ sender: UIBarButtonItem) {
        let image = self.imageView.image?.resizeWithWidthOrHeight(700)
        var caption = ""
        
        if let cap = self.descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ,cap != "" {
            caption = cap
        }
        
        if image == nil && caption == "" {
            self.showAlert("Please set image or enter caption")
            return
        }

        HUD.show()
        
        if let img = image {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let imageRef = storageRef.child(ConstantKey.image).child(BasicStuff.uniqueFileName())
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
                            var json = [String:Any]()
                            json[ConstantKey.userid] = firebaseUser.uid
                            json[ConstantKey.user] =  [ConstantKey.username:firebaseUser.displayName ?? "",
                                                       ConstantKey.image:firebaseUser.photoURL?.absoluteString ?? ""]
                            json[ConstantKey.image] = downloadURL.absoluteString
                            json[ConstantKey.caption] = caption
                            json[ConstantKey.likes] = []
                            json[ConstantKey.date] = Date().string
                            
                            self.ref.child(ConstantKey.feed).child(firebaseUser.uid).childByAutoId().setValue(json, withCompletionBlock: { (error, databaseRef) in
                                HUD.dismiss()
                                guard let error = error else {
                                    let okaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                        self.navigationController?.popViewController(animated: true)
                                    })
                                    self.showAlert(title: "Post shared successfully ", message: nil, actions: okaction)
                                    return
                                }
                                JDB.error("Data base error ==>%@", error.localizedDescription)
                            })
                        }
                    })
                }
            }
        }
        else {
            DispatchQueue.main.async {
                var json = [String:Any]()
                json[ConstantKey.userid] = firebaseUser.uid
                json[ConstantKey.user] =  [ConstantKey.username:firebaseUser.displayName ?? "",
                                           ConstantKey.image:firebaseUser.photoURL?.absoluteString ?? ""]
                json[ConstantKey.caption] = caption
                json[ConstantKey.likes] = []
                json[ConstantKey.date] = Date().string
                
                self.ref.child(ConstantKey.feed).child(firebaseUser.uid).childByAutoId().setValue(json, withCompletionBlock: { (error, databaseRef) in
                    HUD.dismiss()
                    guard let error = error else {
                        let okaction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        self.showAlert(title: "Post shared successfully ", message: nil, actions: okaction)
                        return
                    }
                    JDB.error("Data base error ==>%@", error.localizedDescription)
                })
            }
        }
    }
    
    //MARK:- UIImagePicker Controller Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imageView.image = image
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
