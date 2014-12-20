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
    
    var gameOn: Bool?
    
    var lastPoint: CGPoint! //for drawing the butter lines
    var holdHereActive = true //boolean to see if the player is pressing on the Hold Here button
    
    var myPeerID: MCPeerID?
    var hostPeerID: MCPeerID?
    
    var score_: Int?
    
    var butterKnife = ButterKnife()
    
    let minButterPercentage = 85 //the minimum amount of butter that must be spread on the toast for a successful buttering
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //tempToastView.backgroundColor = UIColor.blackColor()
        
        myPeerID = appDelegate?.mcManager?.session.myPeerID
        
        gameOn = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        debugAmountLabel.text = "Get Ready!"
        gameOn = true
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
        
        if(type == "roundBegin") {
            debugAmountLabel.text = "Start!"
        }
        if(type == "butterAmount" && gameOn == true){
            butterKnife.setButter(receivedPackage.getButterAmount())
            debugAmountLabel.text = String(format:"%.1f", butterKnife.butterAmount_)
        }
        else if(type == "gameover"){
            gameOn = receivedPackage.getPlayBool()
            debugAmountLabel.text = "Game Over"
            //sends score 5, this should be changed when score logic has been implemented
            sendScore(myPeerID!, score_: 5)
        }
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(gameOn == true){
            lastPoint = touches.anyObject()?.locationInView(tempToastView)
            //temporary line to add butter to knife
            //butterKnife.addButter(100)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if(gameOn == true){
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
    }
    
    //merges the tempToastView and toastView image views - this is done to preserve opacity levels
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if(gameOn == true){
            UIGraphicsBeginImageContext(toastView.frame.size)
            toastView.image?.drawInRect(CGRectMake(0, 0, toastView.frame.size.width, toastView.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
            
            tempToastView.image?.drawInRect(CGRectMake(0, 0, tempToastView.frame.size.width, tempToastView.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 0.5)
            
            toastView.image = UIGraphicsGetImageFromCurrentImageContext()
            tempToastView.image = nil;
            UIGraphicsEndImageContext();
            
            //When touch has ended, update host butterAmount
            sendData(myPeerID!, butterAmount_: butterKnife.butterAmount_)
        }
        
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
    
    func sendScore(peerID: MCPeerID, score_: Int){
        var type = "gameover"
        var package = Package(type: type, score_: score_)
        
        var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
        var toPeer: NSArray = [hostPeerID!]
        
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: toPeer, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
    }
    
    func isItButtered() -> Bool {
        let toastViewWidth = Int(toastView.frame.size.width)
        let toastViewHeight = Int(toastView.frame.size.height)
        let minButterPercentage: Double = 0.85
        var totalPoints: Double = 0
        var butteredPoints: Double = 0
        var toastIsButtered = false
        
        for var i = 0; i < toastViewWidth; i = i + 10 {
            for var j = 0; j < toastViewHeight; j = j + 10 {
                var currentPoint = CGPoint(x: i, y: j)
                var greenValue = getGreenValue(currentPoint)
                //tests the currentPoint's Green Channel value, if > 0, then point is buttered
                if greenValue > 0 {
                    butteredPoints++
                }
                totalPoints++
            }
        }
        println("Number of buttered points \(butteredPoints)")
        println("Number of ponts \(totalPoints)")
        var butterPercentage = butteredPoints/totalPoints
        println("Percentage covered \(butterPercentage)")
        if butterPercentage > minButterPercentage {
            toastIsButtered = true
        } else {
            toastIsButtered = false
        }
        return toastIsButtered
    }
    
    func getGreenValue(pos: CGPoint) -> CGFloat {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(toastView.image?.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(toastView.image!.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        //var r = CGFloat(data[pixelInfo])
        var g = CGFloat(data[pixelInfo+1])
        //var b = CGFloat(data[pixelInfo+2])
        //var a = CGFloat(data[pixelInfo+3])
        
        return g
    }

    
    @IBAction func holdHerePressed() {
        //holdHereActive = true
        println("Button pressed = \(holdHereActive)")
    }
    
    @IBAction func holdHereReleased() {
        //holdHereActive = false
        println("Button pressed = \(holdHereActive)")
        var testBool = isItButtered()
        println("Is it buttered? \(testBool)")
    }
    
    
    
}
