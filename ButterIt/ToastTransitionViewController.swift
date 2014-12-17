//
//  ToastTransitionViewController.swift
//  ButterIt
//
//  Created by Steven Teng on 14/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ToastTransitionViewController: UIViewController, UITextFieldDelegate {

    var appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
    
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var usernameField: UITextField?
    @IBOutlet weak var readyLabel: UILabel?
    @IBOutlet weak var readySwitch: UISwitch!
    
    var hostPeerID : MCPeerID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate?.mcManager?.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate?.mcManager?.setupSession()
        statusLabel?.text = "Get ready!"
        readyLabel?.text = "Not Ready"
        readyLabel?.textColor = UIColor.redColor()
        
        usernameField?.delegate = self
        usernameField?.placeholder = UIDevice.currentDevice().name
        
        //Adding observers to this VC
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerDidChangeStateWithNotification:", name: "ButterIt_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        //appDelegate?.mcManager?.advertiseSelf(true)
    }
    
    //This method is called when our notificationCenter receives state changed notification
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if(appDelegate?.mcManager?.peerID != nil){
            appDelegate?.mcManager?.disconnect()
            
            appDelegate?.mcManager?.peerID = nil
            appDelegate?.mcManager?.session = nil
        }
    
        appDelegate?.mcManager?.setupPeerWithDisplayName(usernameField?.text)
        appDelegate?.mcManager?.setupSession()
        
        return true
    }
    
    @IBAction func switchFunc(sender: AnyObject) {
        if(readySwitch.on){
            statusLabel?.text = "Connecting..."
            readyLabel?.text = "Ready"
            readyLabel?.textColor = UIColor.greenColor()
            usernameField?.enabled = false;
            appDelegate?.mcManager?.advertiseSelf(true)
        }
        else{
            statusLabel?.text = "Get ready!"
            readyLabel?.text = "Not Ready"
            readyLabel?.textColor = UIColor.redColor()
            usernameField?.enabled = true;
            appDelegate?.mcManager?.disconnect()
        }
        
    }
    
    //This method is called when our notificationCenter receives a data nofitication
    func didReceiveDataWithNotification(notification: NSNotification){
        var peerID = notification.userInfo?["peerID"] as MCPeerID
        var displayName = peerID.displayName
        
        hostPeerID = peerID
        var receivedData = notification.userInfo?["data"] as NSData
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()
        
        //If package type equals enter,
        //Sender is from host,
        //Playbool is set to true
        //Then game has started and we segue into toastVC
        if(type == "enter"){
            if(receivedPackage.getSender() == "butterHost" && receivedPackage.getPlayBool()){
                self.performSegueWithIdentifier("toastPlaySegue", sender: self)
            }
        }
    }
    
    //Our prepareforsegue method only exist so we can send the correct hostPeerID to our toastVC
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "toastPlaySegue"){
            var toastVC = segue.destinationViewController as ToastViewController
            toastVC.hostPeerID = hostPeerID
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
