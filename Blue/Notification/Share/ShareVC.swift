//
//  ShareVC.swift
//  
//
//  Created by DK on 9/12/18.
//

import UIKit

class ShareVC: UIViewController , UITableViewDataSource , UITableViewDelegate {

    
    @IBOutlet weak var shareTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.shareTableView.register(UINib(nibName: "ShareTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareTableViewCell")
        self.shareTableView.register(UINib(nibName: "ShareImageTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareImageTableViewCell")
        self.shareTableView.register(UINib(nibName: "ShareVideoTableViewCell", bundle: .main), forCellReuseIdentifier: "ShareVideoTableViewCell")
    }
    
    //MARK:- UItableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShareTableViewCell", for: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
