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
    static let contentType:String = "contentType"
    static let user:String = "user"
    static let caption:String = "caption"
    static let likes:String = "likes"
    static let email:String = "email"
    static let follow:String = "follow"
    static let date:String = "date"
    static let video:String = "video"
    static let comment:String = "Comment"
    static let notification:String = "Notification"
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
extension UIColor {
    convenience init(_ hexString:String) {
        let hexString:String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString as String)
        
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:1)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        
        return NSString(format:"#%06x", rgb) as String
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
        dateformater.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidthOrHeight(_ widthOrHeight: CGFloat) -> UIImage? {
        var swidth = size.width
        var sheight = size.height
        
        if size.width > size.height {
            swidth = widthOrHeight
            sheight = CGFloat(ceil(widthOrHeight/size.width * size.height))
        }
        else {
            swidth = CGFloat(ceil(widthOrHeight/size.height * size.width))
            sheight = widthOrHeight
        }
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: swidth, height: sheight)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
extension UITextView{
    
    func numberOfLines() -> Int{
        if let fontUnwrapped = self.font{
            return Int(self.contentSize.height / fontUnwrapped.lineHeight)
        }
        return 0
    }
    
}
extension Date {
    var string: String {
        return DateFormatter.formate.string(from: self)
    }
    var timeStamp: Double {
        let timedate = DateFormatter.formate.string(from: self)
        if let date = DateFormatter.formate.date(from: timedate) {
            return date.timeIntervalSince1970
        }
        else {
            return Date().timeIntervalSince1970
        }
        
    }
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 1
    }
    /// Returns the amount of nanoseconds from another date
//    func nanoseconds(from date: Date) -> Int {
//        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
//    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) years"   }
        if months(from: date)  > 0 { return "\(months(from: date)) months"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) weeks"   }
        if days(from: date)    > 0 {
            let day = days(from: date)
            if day == 1 {
                return "\(day) day"
            }
            else {
                return "\(day) days"
            }
        }
        if hours(from: date)   > 0 { return "\(hours(from: date)) hr"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) min" }
        if seconds(from: date) > 0 { return "\(seconds(from: date)) sec" }
//        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return "1s"
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
extension FileManager {
    var document: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    var library: String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
    }
    var temp:String {
        return NSTemporaryDirectory()
    }
    var tempFilePath:String {
        return self.temp.stringByAppendingPathComponent(path: "Files").stringByAppendingPathComponent(path: "movFile.mp4")
    }
}
extension String {
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    var stringByDeletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    var stringByDeletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    func stringByAppendingPathComponent(path: String) -> String {
        let nsSt = self as NSString
        return nsSt.appendingPathComponent(path)
    }
    func stringByAppendingPathExtension(ext: String) -> String? {
        let nsSt = self as NSString
        return nsSt.appendingPathExtension(ext)
    }
}
