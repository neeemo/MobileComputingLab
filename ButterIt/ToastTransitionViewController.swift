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
    
    //these are defined for animation of controls
    @IBOutlet var switchContainer: UIView!
    @IBOutlet var toastContainer: UIView!
    @IBOutlet var switchConstraint: NSLayoutConstraint!
    @IBOutlet var toastConstraint: NSLayoutConstraint!
    let animationDistance: CGFloat = 50
    
    var playerIsReady = false
    
    var hostPeerID : MCPeerID?
    
    @IBAction func switchPressed () {
        //check if username field is empty, if not, toggles player readiness
        if (playerIsReady == false) {
            animateDown()
        }
            //if the player hits the button after indicating readiness, can change his name and won't show up in the network list
        else {
            animateUp()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate?.mcManager?.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        appDelegate?.mcManager?.setupSession()
        readyLabel?.text = "Hit the lever to start"
        
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()
        
        if(appDelegate?.mcManager?.peerID != nil){
            appDelegate?.mcManager?.disconnect()
            
            appDelegate?.mcManager?.peerID = nil
            appDelegate?.mcManager?.session = nil
        }
        
        appDelegate?.mcManager?.setupPeerWithDisplayName(usernameField?.text)
        appDelegate?.mcManager?.setupSession()
        
    }
    
    //toggles playerIsReady bool, advertises to the host that the player is ready, and changes the screen messages
    func toggleReady () {
        if(playerIsReady == false){
            playerIsReady = true
            readyLabel?.text = "Please wait"
            usernameField?.enabled = false;
            appDelegate?.mcManager?.advertiseSelf(true)
        }
        else{
            playerIsReady = false
            readyLabel?.text = "Hit the lever to start"
            usernameField?.enabled = true;
            appDelegate?.mcManager?.disconnect()
        }
    }
    
    //used to animate the toast and the switch to the down position, 50 pixels lower
    func animateDown() {
        /* let originalSwitchPosition = switchContainer.center
        let originalToastPosition = toastContainer.center
        
        UIView.animateWithDuration(1,
        animations: {
        self.switchContainer.center = CGPoint(x: originalSwitchPosition.x, y: (originalSwitchPosition.y + self.animationDistance))
        self.toastContainer.center = CGPoint(x: originalToastPosition.x, y: (originalToastPosition.y + self.animationDistance))
        },
        completion: { finished in
        self.toggleReady()
        self.toastContainer.updateConstraints()
        })*/
        
        switchConstraint.constant -= animationDistance
        toastConstraint.constant -= animationDistance
        
        UIView.animateWithDuration(1,
            animations: {
                self.switchContainer.layoutIfNeeded()
                self.toastContainer.layoutIfNeeded()
            },
            completion: { finished in
                self.toggleReady()
        })
    }
    
    //used to animate the toast and switch to the up position, 50 pixels higher
    func animateUp() {
        /*       UIView.animateWithDuration(1,
        animations: {
        self.switchContainer.center = CGPoint(x: originalSwitchPosition.x, y: (originalSwitchPosition.y - self.animationDistance))
        self.toastContainer.center = CGPoint(x: originalToastPosition.x, y: (originalToastPosition.y - self.animationDistance))
        },
        completion: { finished in
        self.toggleReady()
        })*/
        
        switchConstraint.constant += animationDistance
        toastConstraint.constant += animationDistance
        
        UIView.animateWithDuration(1,
            animations: {
                self.switchContainer.layoutIfNeeded()
                self.toastContainer.layoutIfNeeded()
            },
            completion: { finished in
                self.toggleReady()
        })
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
