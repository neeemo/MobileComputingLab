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
    let maxScoopAmount: Double = 100
    var roundStarted: Bool?
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        roundStarted = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    func setRoundStarted(roundBool: Bool){
        roundStarted = roundBool
    }
    
    func setPeerID(peerID: MCPeerID){
        peerID_ = peerID
    }
    
    func setName(displayName: String){
        displayName_ = displayName
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(roundStarted == true){
            println("touch began in butterview")
            startTime = NSDate()
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if(roundStarted == true){
            if scoopAmount < maxScoopAmount {
                //scoopAmount++
                let endTime = NSDate()
                let timeInterval: Double = endTime.timeIntervalSinceDate(startTime); //Difference in seconds (double)
                scoopAmount = scoopAmount + timeInterval
            }
            
            //println("Butter on player \(displayName_)'s knife = \(scoopAmount)")
        }

    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if(roundStarted == true){
            //println("\(displayName_) has stopped scooping")
            //scoopAmount = 0
            
            //Calling sendData method that sends a package with the butteramount - scoopamount
            if(peerID_ != nil){
                //println("sending \(scoopAmount) to \(peerID_!)")
                sendData(peerID_!, butterAmount_: scoopAmount)
            }

        }

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
