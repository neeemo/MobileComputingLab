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
    //@IBOutlet var debugAmountLabel: UILabel! used for debugging, not part of the game
    @IBOutlet var toastContainer: UIView!
    @IBOutlet var playerMessageLabel: UILabel! //label that displays messages like "start" or "not enough butter"
    
    var gameOn: Bool?
    
    var startTime = NSTimeInterval()

    
    var myPeerID: MCPeerID?
    var hostPeerID: MCPeerID?
    
    var score_: Int? = 0 //without network code in place, value for score_ must be declared
    
    //drawing variables and connstants
    var lastPoint: CGPoint! //for drawing the butter lines
    let currentButterWidth = 45.0 //the width of the butter strokes, this changes based on the amount of butter
    var minButterWidth = 15.0 // the smallest the butter stroke can get
    
    //gameplay variables
    var butterKnife = ButterKnife()
    var holdHereActive = true //boolean to see if the player is pressing on the Hold Here button
    let minButterPercentage = 85 //the minimum amount of butter that must be spread on the toast for a successful buttering
    var canSpreadButter = true
    var timer: NSTimer = NSTimer()
    let penaltyTime: Double = 3 //the time a player must wait when submitting unbuttered toast

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //tempToastView.backgroundColor = UIColor.blackColor()
        
        myPeerID = appDelegate?.mcManager?.session.myPeerID
        
        gameOn = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    //hides the toast
    override func viewDidLoad() {
        super.viewDidLoad()
        toastContainer.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        //debugAmountLabel.text = "Get Ready!"
        playerMessageLabel.text = "Waiting for game to start." //
        gameOn = true // toastController loaded, so player is now ready to play
        
        //debug code below
        toastContainer.hidden = false
        replaceToast()
        score_ = 0 //resets player's score
        playerMessageLabel.text = "" //erases text in the playerText
        //debug code above
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
        println("Toast received package! \(receivedPackage.getType())")
        if(type == "roundBegin") {
            //debugAmountLabel.text = "Start!"
            toastContainer.hidden = false
            replaceToast()
            score_ = 0 //resets player's score
            playerMessageLabel.text = "" //erases text in the playerText
        }
        if(type == "butterAmount" && gameOn == true){
            butterKnife.setButter(receivedPackage.getButterAmount())
        }
        else if(type == "gameover"){
            println("Are we here?")
            //THIS BUG TOOK LIKE 2 DAYS TO FIX, WHY DOES IT NOT WORK ANYMORE?
            //gameOn = receivedPackage.getPlayBool()
            gameOn = false
            playerMessageLabel.text = "Time up!"
            sendScore(myPeerID!, score_: score_!)
        }
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(gameOn == true){
            lastPoint = touches.anyObject()?.locationInView(tempToastView)
            //gameplay testing line to add butter to knife
            butterKnife.addButter(1000)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if(gameOn == true){
            if holdHereActive == true && butterKnife.butterAmount_ > 0 && canSpreadButter == true {
                var currentPoint: CGPoint! = touches.anyObject()?.locationInView(tempToastView)
                
                //drawing code, draws a line that follows the player's touches
                UIGraphicsBeginImageContext(tempToastView.frame.size)
                tempToastView.image?.drawInRect(CGRectMake(0, 0, tempToastView.frame.size.width, tempToastView.frame.size.height))
                CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y)
                CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint!.x, currentPoint!.y)
                CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound)   //draws a rounded off line
                CGContextSetLineWidth(UIGraphicsGetCurrentContext(), CGFloat(currentButterWidth))
                CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1, 1, 0, 1.0) //arguments are RGB value, in this case, yellow
                CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal)
                CGContextStrokePath(UIGraphicsGetCurrentContext())
                tempToastView.image = UIGraphicsGetImageFromCurrentImageContext()
                tempToastView.alpha = 0.5 //opacity level, set lower so that repeated strokes may overlap
                
                //code to remove butter from the butterKnife - function of butter width times distance
                var distance = Double(hypot(currentPoint.x - lastPoint.x, currentPoint.y - lastPoint.y))
                
                UIGraphicsEndImageContext()
                
                butterKnife.removeButter(distance)
                //println("Butter amount is \(butterKnife.butterAmount_)")
                
                lastPoint = currentPoint
                
                //debugAmountLabel.text = String(format:"%.1f", butterKnife.butterAmount_)
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
            //commented out for testing
            //sendData(myPeerID!, butterAmount_: butterKnife.butterAmount_)
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
 
    //function that determines how much of the piece of toast is covered in butter by checking if the GREEN CHANNEL value is > 0
    //checks every 10th pixel on a horizontal line, once whole line checked, goes vertically down 10 pixels and repeats
    //in short, checks 1 out of 100 pixels to see if it has any green (a component of the yellow butter)
    func isItButtered() -> Bool {
        let toastViewWidth = Int(toastView.frame.size.width)
        let toastViewHeight = Int(toastView.frame.size.height)
        let minButterPercentage: Double = 0.85
        var totalPoints: Double = 0
        var butteredPoints: Double = 0
        var toastIsButtered = false
        
        //make sure toastView isn't empty - if not, does the pixel check for butter
        if (toastView.image != nil) {
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
            //println("Number of buttered points \(butteredPoints)")
            //println("Number of ponts \(totalPoints)")
            var butterPercentage = butteredPoints/totalPoints
            //println("Percentage covered \(butterPercentage)")
            if butterPercentage > minButterPercentage {
                toastIsButtered = true
            } else {
                toastIsButtered = false
            }
        }
        
        return toastIsButtered
    }
    
    func getGreenValue(pos: CGPoint) -> CGFloat {
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(toastView.image?.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(toastView.image!.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        //var r = CGFloat(data[pixelInfo])
        var green = CGFloat(data[pixelInfo+1])
        //var b = CGFloat(data[pixelInfo+2])
        //var a = CGFloat(data[pixelInfo+3])
        
        return green
    }

    
    @IBAction func holdHerePressed() {
        //holdHereActive = true
    }
    
    @IBAction func holdHereReleased() {
        //holdHereActive = false
        //println("Button pressed = \(holdHereActive)")
        var toastIsButtered = isItButtered()
        //println("Is it buttered? \(toastIsButtered)")
        
        //tests if toast is sufficiently buttered; if so, adds a point and gives a new piece of toast, if not, makes player wait
        if toastIsButtered {
            replaceToast() //move the buttered toast offscreen, erase it, then move it back to its original location
            increaseScore() //score point(s) for player

        }
        else {
            playerMessageLabel.text = "Not enough butter!" //lets the player know to add more butter
            makePlayerWait() //penalizes player for submitting insufficiently buttered toast
        }
    }
    
    func replaceToast() {
        let originalToastPosition: CGPoint = toastContainer.center

        //animates the piece of toast so that it moves out of the screen
        UIView.animateWithDuration(1.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                self.toastContainer.center = CGPoint(x: originalToastPosition.x, y: -200)
            },
            completion: { finished in
                //removes all butter from the toast, effectively creating a "new" piece of toast
                self.toastView.image = nil
                //moves toast back to the original positin
                self.moveToastToOrigin(originalToastPosition)
        })
    }
    
    func moveToastToOrigin(originalToastPosition: CGPoint) {
        //animates the piece of toast so that it returns to it original position
        UIView.animateWithDuration(1.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 1,
            options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                self.toastContainer.center = CGPoint(x: originalToastPosition.x, y: originalToastPosition.y)
            },
            completion: nil)
    }
    
    func increaseScore() {
        //adds one to player's score
        score_ = score_! + 1
        println("score is \(score_)")
    }
    
    func startTimer(){
        if(!timer.valid){
            let aSelector: Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    func stopTimer(){   
        timer.invalidate()
    }
    
    func updateTime(){
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        var seconds = penaltyTime - elapsedTime
        
        if(seconds > 0){
            elapsedTime -= NSTimeInterval(seconds)
        }
        else{
            stopTimer()
            playerMessageLabel.text = "" //erases the player message label
            gameOn = true
        }
    }
    
    func makePlayerWait() {
        gameOn = false
        startTimer()
    }
    
}
