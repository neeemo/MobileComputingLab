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
    
    init(type: String?, sender: String?, recipient: String?, butterAmount: Double?, playBool: Bool?, numBounces: Int?, path: NSArray?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = butterAmount!
        self.sender_ = sender!
        self.playBool = playBool!
    }
    
    init(type: String?, sender: String?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = false
    }
    
    init(type: String?, sender: String?, recipient: String?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = false
    }
    
    init(type: String?, sender: String?, path: NSArray?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = false
    }
    
    init(type: String?, sender: String?, playBool: Bool){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = playBool
    }
    
    init(type: String?, sender: String?, butterAmount: Double){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = butterAmount
        self.sender_ = sender!
        self.playBool = false
    }
    
    init(type: String?, butterAmount: Double){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = butterAmount
        self.sender_ = ""
        self.playBool = false
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
    
    func getPlayBool() -> Bool {
        return playBool;
    }
    
    
    required init(coder aDecoder: NSCoder){
        self.type_ = aDecoder.decodeObjectForKey("type") as String
        self.date_ = aDecoder.decodeObjectForKey("date") as NSDate
        self.butterAmount = aDecoder.decodeObjectForKey("butterAmount") as Double
        self.sender_ = aDecoder.decodeObjectForKey("sender") as String
        self.playBool = aDecoder.decodeObjectForKey("playBool") as Bool
    }
    
    func encodeWithCoder(_aCoder: NSCoder) {
        _aCoder.encodeObject(type_ as NSString, forKey: "type")
        _aCoder.encodeObject(butterAmount, forKey: "butterAmount")
        _aCoder.encodeObject(sender_ as NSString, forKey: "sender")
        _aCoder.encodeObject(date_, forKey: "date")
        _aCoder.encodeObject(playBool, forKey: "playBool")
    }
    
}
