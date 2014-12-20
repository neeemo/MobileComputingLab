//
//  ButterViewController.swift
//  ButterItSwift
//
//  Created by James Wellence on 11/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ButterViewController: UIViewController {
    
    var appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
    @IBOutlet var butterView1: ButterView!
    @IBOutlet var butterView2: ButterView!
    @IBOutlet var butterView3: ButterView!
    @IBOutlet var butterView4: ButterView!
    
    @IBOutlet weak var player1Label: UILabel?
    @IBOutlet weak var player2Label: UILabel?
    @IBOutlet weak var player3Label: UILabel?
    @IBOutlet weak var player4Label: UILabel?
    
    @IBOutlet weak var timerLabel: UILabel?
    
    var startTime = NSTimeInterval()
    
    var gameTime: Double = 5
    
    var roundTimer: NSTimer = NSTimer()
    
    var playersArray: NSMutableArray?
    
    var hostPeerID: MCPeerID?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        timerLabel?.textColor = UIColor.greenColor()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        registerPlayerOnLabels()
        startTimer()
    }
    
    //Register players and set butterView
    //Bad code, needs proper init instead
    func registerPlayerOnLabels(){
        for(var i = 0; i < appDelegate?.mcManager?.getConnectedPeers().count; i++){
            var player: MCPeerID? = appDelegate?.mcManager?.getConnectedPeer(i)
            switch (i) {
            case (0):
                player1Label?.text = player?.displayName;
                butterView1.setPeerID(player!)
                butterView1.setName(player!.displayName)
            case (1):
                player2Label?.text = player?.displayName;
                butterView2.setPeerID(player!)
                butterView2.setName(player!.displayName)
            case (2):
                player3Label?.text = player?.displayName;
                butterView3.setPeerID(player!)
                butterView3.setName(player!.displayName)
            case (3):
                player4Label?.text = player?.displayName;
                butterView4.setPeerID(player!)
                butterView4.setName(player!.displayName)
            default:
                println("Somethings is wrong, This print can not happen!")
            }
            playersArray?.addObject(player!)
        }
        
    }
    
    func startTimer(){
        if(!roundTimer.valid) {
            let aSelector: Selector = "updateTime"
            roundTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    func stopTimer(){
        roundTimer.invalidate()
    }
    
    func updateTime(){
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        var seconds = gameTime - elapsedTime
        
        if(seconds < 5){
            timerLabel?.textColor = UIColor.redColor()
        }
        if(seconds  > 0){
            elapsedTime -= NSTimeInterval(seconds)
            timerLabel?.text = String(Int(seconds))
        }
        else{
            stopTimer()
            gameOver()
        }
    }
    
    
    
    func callSendEnter(){
        sendEnter()
    }
    
    //When ButterViewController is created, send a package to all Toasts Devices
    //That game has been started
    func sendEnter(){
        var type = "enter"
        var package = Package(type: type, sender: "butterHost", playBool: true)
        
        var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
        
        //print to see if we have peers connected (debug)
        println(appDelegate?.mcManager!.session.connectedPeers.count)
       
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: allPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
    }
    
    func gameOver(){
        var type = "gameover"
        var package = Package(type: type, sender: "butterHost", playBool: false)
        
        var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
        
        //print to see if we have peers connected (debug)
        println(appDelegate?.mcManager!.session.connectedPeers.count)
        
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: allPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
    }
    
    func didReceiveDataWithNotification(notification: NSNotification) {
        var peerID: MCPeerID = notification.userInfo?["peerID"]! as MCPeerID
        var peerDisplayName = peerID.displayName as String
        var receivedData = notification.userInfo?["data"] as NSData
        
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()
  
        if(type == "gameover"){
            println("\(peerDisplayName) score is: \(receivedPackage.getScore())")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
