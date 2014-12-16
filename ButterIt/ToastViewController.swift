//
//  ToastViewController.swift
//  ButterItSwift
//
//  Created by James Wellence on 10/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ToastViewController: UIViewController {

    var appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
    
    @IBOutlet var toastView: UIImageView!
    @IBOutlet var tempToastView: UIImageView!
    @IBOutlet var debugAmountLabel: UILabel!
    
    var lastPoint: CGPoint! //for drawing the butter lines
    var holdHereActive = true //boolean to see if the player is pressing on the Hold Here button
    
    var myPeerID: MCPeerID?
    var hostPeerID: MCPeerID?
    
    var butterKnife = ButterKnife()

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //tempToastView.backgroundColor = UIColor.blackColor()
        
        myPeerID = appDelegate?.mcManager?.session.myPeerID
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        debugAmountLabel.text = String(format:"%.1f", butterKnife.butterAmount_)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Update the butterAmount on knife from the Host
    func didReceiveDataWithNotification(notification: NSNotification) {
        var peerID: MCPeerID = notification.userInfo?["peerID"]! as MCPeerID
        var peerDisplayName = peerID.displayName as String
        var receivedData = notification.userInfo?["data"] as NSData
        
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()
  
        if(type == "butterAmount"){
            println("Inside butterAmount if-statement!")
            butterKnife.setButter(receivedPackage.getButterAmount())
        }
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        lastPoint = touches.anyObject()?.locationInView(tempToastView)
        //temporary line to add butter to knife
        //butterKnife.addButter(100)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if holdHereActive == true && butterKnife.butterAmount_ > 0 {
            var currentPoint: CGPoint! = touches.anyObject()?.locationInView(tempToastView)
            
            //drawing code, draws a line that follows the player's touches
            UIGraphicsBeginImageContext(tempToastView.frame.size)
            tempToastView.image?.drawInRect(CGRectMake(0, 0, tempToastView.frame.size.width, tempToastView.frame.size.height))
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x, currentPoint!.y)
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)   //draws a rounded off line
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 50)
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 0, 1.0) //arguments are RGB value, in this case, yellow
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal)
            CGContextStrokePath(UIGraphicsGetCurrentContext())
            tempToastView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempToastView.alpha = 0.5 //opacity level, set lower so that repeated strokes may overlap
            
            //code to remove butter from the butterKnife
            
            var distance = Double(hypot(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y))
            
            UIGraphicsEndImageContext()
            
            butterKnife.removeButter(distance/3)
            //println("Butter amount is \(butterKnife.butterAmount_)")
            
            lastPoint = currentPoint
            
            debugAmountLabel.text = String(format:"%.1f", butterKnife.butterAmount_)
        }
    }
    
    //merges the tempToastView and toastView image views - this is done to preserve opacity levels
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {

        UIGraphicsBeginImageContext(toastView.frame.size)
        toastView.image?.drawInRect(CGRectMake(0, 0, toastView.frame.size.width, toastView.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        tempToastView.image?.drawInRect(CGRectMake(0, 0, tempToastView.frame.size.width, tempToastView.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 0.5)
        
        toastView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempToastView.image = nil;
        UIGraphicsEndImageContext();
        
        //When touch has ended, update host butterAmount
        sendData(myPeerID!, butterAmount_: butterKnife.butterAmount_)
    }
    
    //Whenever called sends data to Host that the butterAmount needs to be updated
    func sendData(peerID: MCPeerID, butterAmount_: Double){
        var type = "butterAmount"
        var package = Package(type: type, butterAmount: butterAmount_)
        
        var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
        var toPeer: NSArray = [hostPeerID!]
        
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: toPeer, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
        
        
    }
    
    @IBAction func holdHerePressed() {
        //holdHereActive = true
        println("Button pressed = \(holdHereActive)")
    }
    
    @IBAction func holdHereReleased() {
        //holdHereActive = false
        println("Button pressed = \(holdHereActive)")
    }



}

