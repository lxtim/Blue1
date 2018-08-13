//
//  BasicStuff.swift
//  Blue
//
//  Created by DK on 8/10/18.
//  Copyright © 2018 Tim. All rights reserved.
//

import Foundation
import UIKit
import MRProgress
import Firebase


struct ConstantKey {
    static let feed:String = "Feed"
    static let Users:String = "Users"
    static let username:String = "username"
    static let userid:String = "userid"
    static let id:String = "id"
    static let image:String = "image"
    static let user:String = "user"
    static let caption:String = "caption"
    static let likes:String = "likes"
    static let email:String = "email"
    static let follow:String = "follow"
    static let date:String = "date"
    
}

class BasicStuff : NSObject {
    
    static let shared:BasicStuff = BasicStuff()
    
    var UserData:NSMutableDictionary = NSMutableDictionary()
    var followArray = NSMutableArray()
    
    override init() {
        super.init()
    }
    
    static func uniqueFileName() -> String {
        return BasicStuff.getUniqueString().appending(".png")
    }
    static func getUniqueString() -> String {
        let randomString = BasicStuff.shared.randomString(length: 5)
        let timeStamp = BasicStuff.shared.timeStampString()
        return randomString + timeStamp
    }
    
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    func timeStampString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMYYYYHHmmss"
        return dateFormatter.string(from: date)
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}

extension DateFormatter {
    static var formate:DateFormatter {
        let dateformater = DateFormatter()
        if let timezone = TimeZone(abbreviation: "UTC") {
            dateformater.timeZone = timezone
        }
        dateformater.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return dateformater
    }
}
extension String {
    var date:Date {
        if let sdate = DateFormatter.formate.date(from: self) {
            return sdate
        }
        else {
            return Date()
        }
    }
}

extension Date {
    var string: String {
        return DateFormatter.formate.string(from: self)
    }
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}

var firebaseUser:User = Auth.auth().currentUser!

// For Sign In BTN
@IBDesignable extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
struct JDB {
    static func log(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("LOG :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
    static func error(_ logMessage: String,_ args:Any... , functionName: String = #function ,file:String = #file,line:Int = #line) {
        
        let newArgs = args.map({arg -> CVarArg in String(describing: arg)})
        let messageFormat = String(format: logMessage, arguments: newArgs)
        
        print("ERROR :- \(((file as NSString).lastPathComponent as NSString).deletingPathExtension)--> \(functionName) ,Line:\(line) :", messageFormat)
    }
}

class HUD {
    class var view: MRProgressOverlayView? {
        return AppDelegate.shared.window?.viewWithTag(1020) as? MRProgressOverlayView
    }
    class func show(_ msg:String? = nil) {
        var progressView = MRProgressOverlayView()
        progressView.mode = .indeterminateSmall
        progressView.tag = 1020
        if let progress = AppDelegate.shared.window?.viewWithTag(1020) as? MRProgressOverlayView {
            progressView = progress
        }
        else {
            AppDelegate.shared.window?.addSubview(progressView)
        }
        progressView.show(true)
        if msg != nil {
            progressView.titleLabelText = msg
        }
    }
    
    class func dismiss() {
        DispatchQueue.main.async(execute: {
            if let progressView = AppDelegate.shared.window?.viewWithTag(1020) as? MRProgressOverlayView {
                progressView.dismiss(true)
            }
        })
    }
}

let  Default:UserDefaults = UserDefaults.standard

struct Storyboard {
    static let main = UIStoryboard(name: "Main", bundle: Bundle.main)
}

func Object(_ string:String) -> UIViewController {
    return Storyboard.main.instantiateViewController(withIdentifier: string)
}

func Object<T>(_ :T.Type) -> T {
    let name = NSStringFromClass(T.self as! AnyClass).components(separatedBy: ".").last!
    return Storyboard.main.instantiateViewController(withIdentifier: name) as! T
}

extension UIViewController {
    func showAlert(_ message:String)  {
        let alertController = UIAlertController(title: "Blue", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    func showAlert(title:String? = "Blue",message:String?,actions:UIAlertAction...)  {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for action in actions {
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
}

extension String {
    var isValidEmail:Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        //let emailRegEx = "^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    var trim:String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

