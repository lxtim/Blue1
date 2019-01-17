//
//  CommentVC.swift
//  Blue
//
//  Created by DK on 9/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class CommentVC: UIViewController , UITableViewDelegate , UITableViewDataSource , UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textFieldComment: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var ref = Database.database().reference()
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    var commentRef = Database.database().reference().child(ConstantKey.comment)
    
    var post:[String:Any] = [String:Any]()
    var user:[String:Any] = [String:Any]()
    var comments:[[String:Any]] = [[String:Any]]()
    private var commentIDs:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       // JDB.log("Post data ==>%@ \n User data ==>%@", post,user)
        
        if let comment =  self.post[ConstantKey.comment] as? [String] {
            self.commentIDs = comment
        }
        
        guard let postID = post[ConstantKey.id] as? String else {return}
        self.commentRef.child(postID).queryOrdered(byChild: ConstantKey.date).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String:Any] else {return}
            for (_,v) in value {
                if let cmnt = v as? [String:Any] {
                    self.comments.append(cmnt)
                }
            }
            self.comments = self.comments.sorted(by: {($0[ConstantKey.date] as! Double) > ($1[ConstantKey.date] as! Double) })
            self.tableView.reloadData()
            self.setTableViewLastPathIndexPath()
        }
    }
    
    func setTableViewLastPathIndexPath() {
        DispatchQueue.main.async {
            if self.comments.count > 0 {
                let indexPath = IndexPath(row: (self.comments.count - 1), section: 0)
                self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @objc func keyBoardWillShow(_ notification:Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        guard let endKeyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = endKeyBoardFrame.height
            self.setTableViewLastPathIndexPath()
        }
    }
    @objc func keyBoardWillHide(_ notification:Notification) {
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 0
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.numberOfLines() > 4 {
            textView.isScrollEnabled = true
        }
        else {
            textView.isScrollEnabled = false
        }
        return true
    }
    @IBAction func btnPostAction(_ sender: UIButton) {
        guard let postID = post[ConstantKey.id] as? String else {return}
        var comment:[String:Any] = [String:Any]()
        if let commentText = self.textFieldComment.text , commentText.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            comment[ConstantKey.comment] = commentText
            comment[ConstantKey.date] = Date().timeStamp
            comment[ConstantKey.userid] = firebaseUser.uid
            HUD.show("Posting...")
            self.commentRef.child(postID).childByAutoId().setValue(comment) { (error, ref) in
                if error == nil {
                    ref.observe(DataEventType.value, with: { (snapshot) in
                        guard let commentSnapValue = snapshot.value as? [String:Any] else {return}
                        guard let userID = self.post[ConstantKey.userid] as? String else {return}
                        
                        self.commentIDs.append(snapshot.key)
                        
                        self.comments.append(commentSnapValue)
                        self.tableView.reloadData()
                        
                        self.feedRef.child(userID).child(postID).updateChildValues([ConstantKey.comment:self.commentIDs], withCompletionBlock: { (error, ref) in
                            HUD.dismiss()
                            if error == nil {
                                self.textFieldComment.text = ""
                                self.setTableViewLastPathIndexPath()
                                self.sendCommentNotification()
                            }
                        })
                    }, withCancel: nil)
                }
            }
        }
    }
    
    func sendCommentNotification() {
        let adminUserID = post[ConstantKey.userid] as! String
        let commentUserID = firebaseUser.uid
        if adminUserID != commentUserID {
            var json = [String:Any]()
            if post[ConstantKey.image] != nil {
                if let type = post[ConstantKey.contentType] as? String , type == ConstantKey.video {
                }
                else {
                    json[ConstantKey.image] = post[ConstantKey.image]
                }
            }
            else {
                json[ConstantKey.caption] = post[ConstantKey.caption]
            }
            json[ConstantKey.id] = commentUserID
            json[ConstantKey.date] = Date().timeStamp
            json[ConstantKey.contentType] = NotificationType.comment.rawValue
            self.ref.child(ConstantKey.notification).child(adminUserID).childByAutoId().setValue(json) { (error, ref) in
                if error == nil {
                    
                }
            }
            self.ref.child(ConstantKey.Users).child(adminUserID).observeSingleEvent(of: .value) { (snapshot) in
                guard let user = snapshot.value as? [String:Any] else {return}
                var notificationCount = 0
                if let count = user[ConstantKey.unreadCount] as? Int {
                    notificationCount = count
                }
                notificationCount = notificationCount + 1
                self.ref.child(ConstantKey.Users).child(adminUserID).updateChildValues([ConstantKey.unreadCount:notificationCount])
            }
        }
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    //MARK:- UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.tableView.bounds.width, height: 1)))
        view.backgroundColor = self.tableView.separatorColor
        return view
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    //MARK:- UItableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
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
