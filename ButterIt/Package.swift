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
    var score_: Int
    var roundBegin: Bool
    
    init(type: String?, sender: String?, butterAmount: Double?, playBool: Bool?, score: Int?, roundBegin: Bool?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = butterAmount!
        self.sender_ = sender!
        self.playBool = playBool!
        self.score_ = score!
        self.roundBegin = roundBegin!
    }
    
    init(type: String?, sender: String?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = false
        self.score_ = 0
        self.roundBegin = false
    }
    
    init(type: String?){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = ""
        self.playBool = false
        self.score_ = 0
        self.roundBegin = false
    }
    
    init(type: String?, sender: String?, playBool: Bool){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = playBool
        self.score_ = 0
        self.roundBegin = false
    }
    
    init(type: String?, sender: String?, butterAmount: Double){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = butterAmount
        self.sender_ = sender!
        self.playBool = false
        self.score_ = 0
        self.roundBegin = false
    }
    
    init(type: String?, butterAmount: Double){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = butterAmount
        self.sender_ = ""
        self.playBool = false
        self.score_ = 0
        self.roundBegin = false
    }
    
    init(type: String?, score_: Int){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = ""
        self.playBool = false
        self.score_ = score_
        self.roundBegin = false
    }
    
    init(type: String?, sender: String?, roundBegin: Bool){
        self.type_ = type!
        self.date_ = NSDate()
        self.butterAmount = 0
        self.sender_ = sender!
        self.playBool = false
        self.score_ = 0
        self.roundBegin = roundBegin
    }
    
    func getType() -> String {
        return type_;
    }
    
    func getButterAmount() -> Double! {
        return butterAmount
    }
    
    func getSender() -> String! {
        return sender_
    }
    
    func getDate() -> NSDate! {
        return date_
    }
    
    func getPlayBool() -> Bool {
        return playBool
    }
    
    func getScore() -> Int {
        return score_
    }
    
    func getRoundBegin() -> Bool {
        return roundBegin
    }
    
    
    required init(coder aDecoder: NSCoder){
        self.type_ = aDecoder.decodeObjectForKey("type") as String
        self.date_ = aDecoder.decodeObjectForKey("date") as NSDate
        self.butterAmount = aDecoder.decodeObjectForKey("butterAmount") as Double
        self.sender_ = aDecoder.decodeObjectForKey("sender") as String
        self.playBool = aDecoder.decodeObjectForKey("playBool") as Bool
        self.score_ = aDecoder.decodeObjectForKey("score") as Int
        self.roundBegin = aDecoder.decodeObjectForKey("roundBegin") as Bool
    }
    
    func encodeWithCoder(_aCoder: NSCoder) {
        _aCoder.encodeObject(type_ as NSString, forKey: "type")
        _aCoder.encodeObject(butterAmount, forKey: "butterAmount")
        _aCoder.encodeObject(sender_ as NSString, forKey: "sender")
        _aCoder.encodeObject(date_, forKey: "date")
        _aCoder.encodeObject(playBool, forKey: "playBool")
        _aCoder.encodeObject(score_, forKey: "score")
        _aCoder.encodeObject(roundBegin, forKey: "roundBegin")
    }
    
}