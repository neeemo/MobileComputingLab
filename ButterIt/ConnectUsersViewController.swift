//
//  ConnectUsersViewController.swift
//  ButterItSwiftTest
//
//  Created by Steven Teng on 11/12/14.
//  Copyright (c) 2014 Steven Teng. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol ConnectUserViewControllerDelegate {
    func callSendEnter()
}

class ConnectUsersViewController: UIViewController, MCBrowserViewControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var playButton: UIButton?
    @IBOutlet weak var addPlayersButton: UIButton?
    @IBOutlet weak var textField: UITextView?
    
    var appDelegate: AppDelegate?
    var arrConnectedDevices: NSMutableArray = NSMutableArray(object: UIDevice.currentDevice().name)
    var delegate: ConnectUserViewControllerDelegate?
    
    var nearbyServiceBrowser: MCBrowserViewController?
    var nearbyPeers: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField?.delegate = self
        
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.mcManager?.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate?.mcManager?.setupSession()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerDidChangeStateWithNotification:", name: "ButterIt_DidChangeStateNotification", object: nil)
        arrConnectedDevices = NSMutableArray()
        
        //for testing purposes this is set to true
        playButton?.enabled = true
        
        //Set up AUTOMATICALLY
        /*var peerID = MCPeerID(displayName: "advertise")
        self.nearbyServiceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "ads-p2p")
        self.nearbyServiceBrowser.delegate = self
        self.nearbyServiceBrowser.startBrowsingForPeers()*/
    }
    
    override func viewDidAppear(animated: Bool) {
        //have a button to browse for devices here later instead of viewdidappear
        //browserForDevices()
        
        
    }
    
    @IBAction func playFunc(sender: UIButton){
        //Call delegate method
        var butterVC = ButterViewController()
        butterVC.callSendEnter()
        //self.delegate?.callSendEnter()
        
        self.performSegueWithIdentifier("goPlaySegue", sender: self)
    }
    
    @IBAction func addPlayersFunc(sender: UIButton){
        println("add players")
        browserForDevices()
    }
    
    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!){
        if(segue.identifier == "goPlaySegue"){
            
        }
    }
    */
    
    
    func browserForDevices() {
        appDelegate?.mcManager?.requireDeviceConnected(self)
        appDelegate?.mcManager?.browser?.delegate = self
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate?.mcManager?.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate?.mcManager?.browser?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    func peerDidChangeStateWithNotification (notification: NSNotification) {
        var peerID = notification.userInfo?["peerID"] as MCPeerID
        var displayName = peerID.displayName
        var state = notification.userInfo?["state"] as Int
        
        if state != MCSessionState.Connecting.rawValue {
            if state == MCSessionState.Connected.rawValue {
                println("connected")
                arrConnectedDevices.addObject(displayName)
            }
            else if state == MCSessionState.NotConnected.rawValue && arrConnectedDevices.count > 0{
                println("not connected")
                var indexOfPeer = arrConnectedDevices.indexOfObject(displayName)
                arrConnectedDevices.removeObjectAtIndex(indexOfPeer)
            }
            var allPlayers = String()
            for(var i = 0; i < arrConnectedDevices.count; i++){
                var playerName: AnyObject = arrConnectedDevices.objectAtIndex(i)
                allPlayers = allPlayers + String(playerName as NSString) + "\n"
            }
            textField?.text = allPlayers
            
            if(arrConnectedDevices.count > 0){
                playButton?.enabled = true
            }
            var peersExist = appDelegate?.mcManager?.session.connectedPeers.count == 0
        }
        
    }
    
    func disconnect() {
        appDelegate?.mcManager?.session.disconnect()
        arrConnectedDevices.removeAllObjects()
    } // Dispose of any resources that can be recreated.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
