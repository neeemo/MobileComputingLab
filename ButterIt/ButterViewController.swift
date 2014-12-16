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
    
    var playersArray: NSMutableArray?
    
    var hostPeerID: MCPeerID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        registerPlayerOnLabels()
    }
    
    //Register players and set butterView
    //Bad code, needs proper init instead
    //PlayerNumber is not needed and are just for debugging atm
    func registerPlayerOnLabels(){
        for(var i = 0; i < appDelegate?.mcManager?.getConnectedPeers().count; i++){
            var player: MCPeerID? = appDelegate?.mcManager?.getConnectedPeer(i)
            switch (i) {
            case (0):
                player1Label?.text = player?.displayName;
                butterView1.playerNumber = i;
                butterView1.setPeerID(player!)
            case (1):
                player2Label?.text = player?.displayName;
                butterView2.playerNumber = i;
                butterView2.setPeerID(player!)
            case (2):
                player3Label?.text = player?.displayName;
                butterView3.playerNumber = i;
                butterView3.setPeerID(player!)
            case (3):
                player4Label?.text = player?.displayName;
                butterView4.playerNumber = i;
                butterView4.setPeerID(player!)
            default:
                println("No connected peers (should not be able to happen)")
            }
            playersArray?.addObject(player!)
        }
        
    }
    
    func callSendEnter(){
        println("delegate method sendEnter called")
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
