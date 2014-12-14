//
//  ToastTransitionViewController.swift
//  ButterIt
//
//  Created by Steven Teng on 14/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ToastTransitionViewController: UIViewController {

    var appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
    
    @IBOutlet weak var statusLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate?.mcManager?.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate?.mcManager?.setupSession()
        statusLabel?.text = "Waiting for host to connect you..."
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerDidChangeStateWithNotification:", name: "ButterIt_DidChangeStateNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        appDelegate?.mcManager?.advertiseSelf(true)
    }
    
    func peerDidChangeStateWithNotification (notification: NSNotification) {
        var peerID = notification.userInfo?["peerID"] as MCPeerID
        var displayName = peerID.displayName
        var state = notification.userInfo?["state"] as Int
        
        if state != MCSessionState.Connecting.rawValue {
            if state == MCSessionState.Connected.rawValue {
                statusLabel?.text = "Waiting for host to start game!"
            }
            
            var peersExist = appDelegate?.mcManager?.session.connectedPeers.count == 0
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
