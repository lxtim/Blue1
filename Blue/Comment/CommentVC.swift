//
//  CommentVC.swift
//  Blue
//
//  Created by DK on 9/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase

class CommentTableViewCell:UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    
    var comment:[String:Any] = [String:Any]() {
        didSet {
            
            if let timeStamp = comment[ConstantKey.date] as? Double {
                let date = Date(timeIntervalSince1970: timeStamp)
                
                self.dateLabel.text = Date().offset(from: date) + " ago"
                
            }
            self.commentLabel.text = comment[ConstantKey.comment] as? String
            guard let userid = comment[ConstantKey.userid] as? String else {return}
            
            self.userRef.child(userid).observeSingleEvent(of: .value) { (snapshot) in
                guard let value = snapshot.value as? [String:Any] else {return}
                self.userNameLabel.text = value[ConstantKey.username] as? String
                if let url = value[ConstantKey.image] as? String {
                    self.profileImageView.sd_setImage(with: URL(string: url)!, placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
                }
            }
        }
    }
}
class CommentVC: UIViewController , UITableViewDelegate , UITableViewDataSource , UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textFieldComment: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var userRef = Database.database().reference().child(ConstantKey.Users)
    var feedRef = Database.database().reference().child(ConstantKey.feed)
    var commentRef = Database.database().reference().child(ConstantKey.comment)
    var post:[String:Any] = [String:Any]()
    var user:[String:Any] = [String:Any]()
    var comments:[[String:Any]] = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
       // JDB.log("Post data ==>%@ \n User data ==>%@", post,user)
        
        guard let postID = post[ConstantKey.id] as? String else {return}
        self.commentRef.child(postID).observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String:Any] else {return}
            for (_,v) in value.reversed() {
                if let cmnt = v as? [String:Any] {
                    self.comments.append(cmnt)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    @objc func keyBoardWillShow(_ notification:Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        guard let endKeyBoardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = endKeyBoardFrame.height
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
        if let commentText = self.textFieldComment.text , commentText != "" {
            comment[ConstantKey.comment] = commentText
            comment[ConstantKey.date] = Date().timeStamp
            comment[ConstantKey.userid] = firebaseUser.uid
            
            self.commentRef.child(postID).childByAutoId().setValue(comment) { (error, ref) in
                if error == nil {
                    ref.observe(DataEventType.value, with: { (snapshot) in
                        guard let commentSnapValue = snapshot.value as? [String:Any] else {return}
                        guard let userID = self.post[ConstantKey.userid] as? String else {return}
                        
                        var commnetID:[String] = [String]()
                        if let commentIDs = self.post[ConstantKey.comment] as? [String] {
                            commnetID = commentIDs
                        }
                        commnetID.append(snapshot.key)
                        
                        self.comments.append(commentSnapValue)
                        self.tableView.reloadData()
                        
                        self.feedRef.child(userID).child(postID).updateChildValues([ConstantKey.comment:commnetID], withCompletionBlock: { (error, ref) in
                            if error == nil {
                                self.showAlert("post successfully")
                            }
                        })
                    }, withCancel: nil)
                }
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
