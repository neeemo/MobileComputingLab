//
//  ButterView.swift
//  ButterItSwift
//
//  Created by James Wellence on 11/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ButterView: UIImageView {
    
    var appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
    
    var hostPeerID_: MCPeerID?
    var displayName_: String = ""
    var peerID_: MCPeerID?
    var scoopAmount: Double = 0 //as a player "scoops" butter, this value goes up
    var startTime = NSDate() //used in calculating the amount of butter scooped
    let maxScoopAmount: Double = 1000
    var roundStarted: Bool?
    
    var score_: Int? = 0
    
    var starBoolean: Bool? = false
    
    let scoopMultiplier = 50.0 // this is a game balancing constant that affects the rate at which butter is scooped
    
    //drawing variables
    var lastPoint: CGPoint! //for drawing the butter lines

    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        roundStarted = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    func setRoundStarted(roundBool: Bool){
        roundStarted = roundBool
    }
    
    func setScore(score: Int){
        score_ = score
    }
    
    func getScore() -> Int{
        return score_!
    }
    
    func setStarBoolean(bool: Bool){
        starBoolean = bool
    }
    
    func getStarBoolean() -> Bool{
        return starBoolean!
    }
    
    func setPeerID(peerID: MCPeerID){
        peerID_ = peerID
    }
    
    func setName(displayName: String){
        displayName_ = displayName
    }
    
    //function to let the host get the peerID to identify each client
    func getPeerID() -> MCPeerID {
        return peerID_!
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(roundStarted == true){
            startTime = NSDate()
            //lastPoint = touches.anyObject()?.locationInView(self)
            //sendTouch()
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if(roundStarted == true){
            if scoopAmount < maxScoopAmount {
                //scoopAmount++
                let endTime = NSDate()
                let timeInterval: Double = endTime.timeIntervalSinceDate(startTime); //Difference in seconds (double)
                scoopAmount = scoopAmount + (timeInterval*scoopMultiplier)
                //drawLine(touches)
            }
            
            //println("Butter on player \(displayName_)'s knife = \(scoopAmount)")
        }
        
    }
    /*
    func drawLine (touches: NSSet) {
        var currentPoint: CGPoint! = touches.anyObject()?.locationInView(self)
        
        //drawing code, draws a line that follows the player's touches
        UIGraphicsBeginImageContext(self.frame.size)
        self.image?.drawInRect(CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x, currentPoint!.y)
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)   //draws a rounded off line
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(45))
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 0, 1.0) //arguments are RGB value, in this case, yellow
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal)
        CGContextStrokePath(UIGraphicsGetCurrentContext())
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        self.alpha = 0.5 //opacity level, set lower so that repeated strokes may overlap
        
        //code to remove butter from the butterKnife - function of butter width times distance
        var distance = Double(hypot(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y))
        
        UIGraphicsEndImageContext()

        
        lastPoint = currentPoint

    }
    */
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if(roundStarted == true){
            //println("\(displayName_) has stopped scooping")
            //scoopAmount = 0
            
            //Calling sendData method that sends a package with the butteramount - scoopamount
            if(peerID_ != nil){
                //println("sending \(scoopAmount) to \(peerID_!)")
                sendData(peerID_!, butterAmount_: scoopAmount)
            }
            //sendTouch()
        }
        //self.image = nil
    }
    
    //Send data method to corresponding peerID, set to reliable datatransfer
    func sendData(peerID: MCPeerID, butterAmount_: Double){
        if(peerID_ != nil){
            var type = "butterAmount"
            var package = Package(type: type, butterAmount: butterAmount_)
            
            var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
            var toPeer: NSArray = [peerID_!]
            
            var error: NSError?
            appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: toPeer, withMode: MCSessionSendDataMode.Reliable, error: &error)
            if(error != nil){
                println(error?.localizedDescription)
            }
        }
    }
    
    /*
    func sendTouch(){
        if(peerID_ != nil){
            var type = "touch"
            var package = Package(type: type)
            var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
            var toPeer: NSArray = [hostPeerID_!]
            
            var error: NSError?
            appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: toPeer, withMode: MCSessionSendDataMode.Reliable, error: &error)
            if(error != nil){
                println(error?.localizedDescription)
            }
        }
    }
    */
    
    //This method is called when data is received
    func didReceiveDataWithNotification(notification: NSNotification) {
        var peerID: MCPeerID = notification.userInfo?["peerID"]! as MCPeerID
        var peerDisplayName = peerID.displayName as String
        var receivedData = notification.userInfo?["data"] as NSData
        
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()
        
        //If package type equals butterAmount
        //Then we update scoopAmount with the butterAmount from our package
        if(type == "butterAmount"){
            scoopAmount = receivedPackage.getButterAmount()
        }
        
    }
    
    
    
    
    
    
}