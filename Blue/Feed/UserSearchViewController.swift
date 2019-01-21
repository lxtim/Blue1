//
//  UserSearchViewController.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol UserSearchDelegate {
    func userDidSelect(_ data:[String:Any])
}

class UserSearchCell : UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var title:String = "" {
        didSet(newValue) {
                self.titleLabel?.text = title
        }
    }
    var imageURLString:String = "" {
        didSet(newValue) {
            self.profileImageView.image = #imageLiteral(resourceName: "profile_placeHolder")
//            if imageURLString != "" {
                self.profileImageView?.sd_setImage(with: URL(string: imageURLString), placeholderImage: #imageLiteral(resourceName: "profile_placeHolder"), options: .continueInBackground, completed: nil)
//            }
        }
    }
}

class UserSearchViewController: UITableViewController ,UISearchBarDelegate{
    
    var searchBar:UISearchBar = UISearchBar()
    var filterData:[[String:Any]] = [[String:Any]]()
    var compareData:[[String:Any]] = [[String:Any]]()
    var delegate:UserSearchDelegate? = nil
    
    var ref: DatabaseReference = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = self.searchBar
//        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: #imageLiteral(resourceName: "Rectangle 8"))
        
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = true
        self.searchBar.tintColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
        
        for view in self.searchBar.subviews {
            for subview in view.subviews {
                if let searchTextField = subview as? UITextField {
                    searchTextField.tintColor = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
                    searchTextField.becomeFirstResponder()
                }
            }
        }
        
        if #available(iOS 11.0, *) {
            searchBar.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        }
        
        self.ref.child(ConstantKey.Users).queryOrdered(byChild: ConstantKey.username).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value else {return}
            if var dict = value as? [String:Any] {
                dict.removeValue(forKey: firebaseUser.uid)
                
                self.filterData = dict.values.map({$0 as! [String:Any]})
            }
            else {
                self.filterData = [[String:Any]]()
            }
            self.compareData = [[String:Any]]()
            
            self.tableView.reloadData()
        }) { (error) in
            JDB.log("cancle error ==>>%@", error.localizedDescription)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    @objc func keyBoardWillShow(_ notification:Notification) {
        guard let userInfo = (notification as NSNotification).userInfo else {return}
        guard let endKeyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        self.tableView.tableFooterView = UIView(frame: endKeyBoardFrame)
    }
    
    //MARK:- UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            self.compareData = []//self.filterData
        }
        else {
            self.compareData = self.filterData.filter({ (user) -> Bool in
                if let username  = user[ConstantKey.username] as? String {
                    if username.lowercased().contains(searchText.lowercased())  {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else {
                    return false
                }
            })
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.compareData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserSearchCell", for: indexPath) as! UserSearchCell
        let data = self.compareData[indexPath.row] as? NSDictionary
        cell.title = data?.value(forKey: ConstantKey.username) as? String ?? ""
        cell.imageURLString = data?.value(forKey: ConstantKey.image) as? String ?? ""
        return cell
    }
    

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: self.tableView.bounds.width, height: 1)))
        view.backgroundColor = self.tableView.separatorColor
        return view
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row  = self.compareData[indexPath.row]
        if let delegate = self.delegate {
            delegate.userDidSelect(row)
        }
        self.dismiss(animated: true, completion: nil)
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
