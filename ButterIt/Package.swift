//
//  Package.swift
//  ButterIt
//
//  Created by Steven Teng on 15/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit


class Package: NSObject, NSCoding {
   
    var type_: String
    var butterAmount: Double
    var playBool: Bool
    var sender_: String
    var date_: NSDate
    var recipient_: String
    var numBounces_: Int
    var path_: NSArray
    
    init(type: String?, sender: String?, recipient: String?, butterAmount: Double?, playBool: Bool?, numBounces: Int?, path: NSArray?){
        self.type_ = type!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.recipient_ = recipient!
        self.numBounces_ = numBounces!
        self.path_ = path!
        self.butterAmount = butterAmount!
        self.playBool = playBool!
    }
    
    init(type: String?, sender: String?){
        self.type_ = type!
        self.butterAmount = 0
        self.playBool = false
        self.sender_ = sender!
        self.date_ = NSDate()
        self.recipient_ = ""
        self.numBounces_ = 0
        self.path_ = [sender!]
    }
    
    init(type: String?, sender: String?, recipient: String?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.recipient_ = recipient!
        self.numBounces_ = 0
        self.path_ = [sender!]
        self.playBool = false
    }
    
    init(type: String?, sender: String?, path: NSArray?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.recipient_ = ""
        self.numBounces_ = 0
        self.playBool = false
        self.path_ = path!
    }
    
    init(type: String?, sender: String?, playBool: Bool){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.recipient_ = ""
        self.numBounces_ = 0
        self.playBool = playBool
        self.path_ = [sender!]
    }
    
    func getType() -> String {
        return type_
    }
    
    func getButterAmount() -> Double! {
        return butterAmount;
    }
    
    func getSender() -> String! {
        return sender_;
    }
    
    func getDate() -> NSDate! {
        return date_
    }
    
    func getRecipient() -> String! {
        return recipient_;
    }
    
    func getNumBounces() -> Int! {
        return numBounces_;
    }
    
    func getPath() -> NSArray! {
        return path_;
    }
    
    func getPlayBool() -> Bool {
        return playBool;
    }
    
    
    required init(coder aDecoder: NSCoder){
        self.type_ = aDecoder.decodeObjectForKey("type") as String
        self.butterAmount = aDecoder.decodeObjectForKey("butterAmount") as Double
        self.sender_ = aDecoder.decodeObjectForKey("sender") as String
        self.date_ = aDecoder.decodeObjectForKey("date") as NSDate
        self.playBool = aDecoder.decodeObjectForKey("playBool") as Bool
        self.numBounces_ = aDecoder.decodeObjectForKey("numBounces") as Int
        self.recipient_ = aDecoder.decodeObjectForKey("recipient") as String
        self.path_ = aDecoder.decodeObjectForKey("path") as NSArray
    }
    
    func encodeWithCoder(_aCoder: NSCoder) {
        _aCoder.encodeObject(type_ as NSString, forKey: "type")
        _aCoder.encodeObject(butterAmount, forKey: "butterAmount")
        _aCoder.encodeObject(sender_ as NSString, forKey: "sender")
        _aCoder.encodeObject(date_, forKey: "date")
        _aCoder.encodeObject(recipient_ as NSString, forKey: "recipient")
        _aCoder.encodeObject(numBounces_, forKey: "numBounces")
        _aCoder.encodeObject(playBool, forKey: "playBool")
        _aCoder.encodeObject(path_ as NSArray, forKey: "path")
    }
    
}
