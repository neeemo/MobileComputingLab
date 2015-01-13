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
    
    //butter tubs that players scoop
    @IBOutlet var butterView1: ButterView!
    @IBOutlet var butterView2: ButterView!
    @IBOutlet var butterView3: ButterView!
    @IBOutlet var butterView4: ButterView!
    
    //player names that indicate who gets which piece of butter
    @IBOutlet weak var player1Label: UILabel?
    @IBOutlet weak var player2Label: UILabel?
    @IBOutlet weak var player3Label: UILabel?
    @IBOutlet weak var player4Label: UILabel?
    
    //score labels used at the end of the game
    @IBOutlet var player1ScoreLabel: UILabel?
    @IBOutlet var player2ScoreLabel: UILabel?
    @IBOutlet var player3ScoreLabel: UILabel?
    @IBOutlet var player4ScoreLabel: UILabel?
    
    //butter images, need a reference here in order to make them disappear at the end of the game
    @IBOutlet var butterImage1: UIImageView!
    @IBOutlet var butterImage2: UIImageView!
    @IBOutlet var butterImage3: UIImageView!
    @IBOutlet var butterImage4: UIImageView!
    
    //star images, used to mark who the winner is at the end of the game
    @IBOutlet var starImage1: UIImageView!
    @IBOutlet var starImage2: UIImageView!
    @IBOutlet var starImage3: UIImageView!
    @IBOutlet var starImage4: UIImageView!
    
    @IBOutlet weak var timerLabel: UILabel?
    
    @IBOutlet weak var playButton: UIButton?
    
    var player1touch: Bool = false
    var player2touch: Bool = false
    var player3touch: Bool = false
    var player4touch: Bool = false
    
    var startTime = NSTimeInterval()
    
    var countDownBool: Bool = true
    
    var gameTime: Double = 0
    
    var roundTimer: NSTimer = NSTimer()
    
    //array that stores which ButterView belongs to which Peer, which playernumber belongs to each peer, 0=Player1, 1=Player2, etc
    //var butterViewArray: [ButterView] = Array()
    //var playerLabelArray: [UILabel] = Array()
    //var playerScoreLabelArray: [UILabel] = Array()
    
    var hostPeerID: MCPeerID?
    
    var playerScores = String()
    
    var receivedGameOver: Int?
    
    var connectedPeers: Int!
    
    var winnerArray: [ButterView] = Array()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        timerLabel?.textColor = UIColor.greenColor()
        
        receivedGameOver = 0
        
        playButton?.hidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        butterImage1.hidden = true
        butterImage2.hidden = true
        butterImage3.hidden = true
        butterImage4.hidden = true
        player1Label?.hidden = true
        player2Label?.hidden = true
        player3Label?.hidden = true
        player4Label?.hidden = true
        
        player1ScoreLabel?.text = ""
        player1ScoreLabel?.hidden = true
        player2ScoreLabel?.text = ""
        player2ScoreLabel?.hidden = true
        player3ScoreLabel?.text = ""
        player3ScoreLabel?.hidden = true
        player4ScoreLabel?.text = ""
        player4ScoreLabel?.hidden = true
        registerPlayerOnLabels()
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func playButtonFunc(sender: UIButton){
        startCountDown()
        playButton?.hidden = true
    }
    
    //Register players and set butterView
    func registerPlayerOnLabels(){
        
        //erase timer label
        timerLabel?.text = ""
        
        connectedPeers = appDelegate?.mcManager?.getConnectedPeers().count
        
        hostPeerID = appDelegate?.mcManager?.peerID
        
        //adding a peerID/displayname to each butterview
        for(var i = 0; i < connectedPeers; i++){
            var player: MCPeerID? = appDelegate?.mcManager?.getConnectedPeer(i)
            switch i{
            case 0:
                player1Label?.text = player?.displayName
                butterView1.setPeerID(player!)
                butterView1.setName(player!.displayName)
                butterView1.hostPeerID_ = hostPeerID
                player1Label?.hidden = false
            case 1:
                player2Label?.text = player?.displayName
                butterView2.setPeerID(player!)
                butterView2.setName(player!.displayName)
                butterView2.hostPeerID_ = hostPeerID
                player2Label?.hidden = false
            case 2:
                player3Label?.text = player?.displayName
                butterView3.setPeerID(player!)
                butterView3.setName(player!.displayName)
                butterView3.hostPeerID_ = hostPeerID
                player3Label?.hidden = false
            case 3:
                player4Label?.text = player?.displayName
                butterView4.setPeerID(player!)
                butterView4.setName(player!.displayName)
                butterView4.hostPeerID_ = hostPeerID
                player4Label?.hidden = false
            default:
                println("must have an excecutable line")
            }
        }
    }
    
    //activating all butterviews
    func activateButterViews(){
        butterView1.setRoundStarted(true)
        butterView2.setRoundStarted(true)
        butterView3.setRoundStarted(true)
        butterView4.setRoundStarted(true)
    }
    
    //sets the countdown to 3 secs (2 sec delay) and starts the timer
    func startCountDown(){
        gameTime = 5
        startTimer()
    }

    //starts a timer that uses the updateTime method
    func startTimer(){
        timerLabel?.textColor = UIColor.blackColor()
        if(!roundTimer.valid) {
            let aSelector: Selector = "updateTime"
            roundTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    //stops our timer
    func stopTimer(){
        roundTimer.invalidate()
    }
    
    //update time method
    func updateTime(){
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var elapsedTime: NSTimeInterval = currentTime - startTime
        var seconds = gameTime - elapsedTime

        //if time is under 5 secounds change textcolor to red
        if(seconds < 5 && !countDownBool){
            timerLabel?.textColor = UIColor.redColor()
        }
        //when time is more than 0, update elapsedtime and add current time to timerlabel
        if(seconds  > 0){
            elapsedTime -= NSTimeInterval(seconds)
            timerLabel?.text = String(Int(seconds))
        }
        //if true then we start the game, set all variables for our new timer
        else if(countDownBool){
            stopTimer()
            //for debugging, changed gameTime from 52
            gameTime = 52

            timerLabel?.textColor = UIColor.greenColor()
            timerLabel?.text = "GO!"
            startTimer()
            activateButterViews()
            hideButterGraphics(false)
            sendStartRound()
            countDownBool = false
        }
        else{
            stopTimer()
            hideButterGraphics(true)
            gameOver()
        }
    }
        
    //help method that is called from ConnectUsersViewController
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
        println("SendEnter: \(allPeers?.count)")
            
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: allPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
    }
    
    //when this method is called we create a gameover package and sends it to all peers
    func gameOver(){
        var type = "gameover"
        var package = Package(type: type, sender: "butterHost", playBool: false)
        
        var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
        
        //print to see if we have peers connected (debug)
        println("gameover: \(connectedPeers)")
        
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: allPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
    }

    
    //when this method is called we create a roundbegin package and sends it to all peers
    func sendStartRound(){
        var type = "roundBegin"
        var package = Package(type: type, sender: "butterHost", roundBegin: true)
            
        var dataToSend: NSData = NSKeyedArchiver.archivedDataWithRootObject(package)
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
            
        //print to see if we have peers connected (debug)
        println("startRound: \(connectedPeers)")
            
        var error: NSError?
        appDelegate?.mcManager!.session.sendData(dataToSend, toPeers: allPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        if(error != nil){
            println(error?.localizedDescription)
        }
    }
    
    func checkPeerID(peerID: MCPeerID) -> ButterView{
        var bv: ButterView = butterView1
        var index: Int = 0
        while(index < connectedPeers){
            switch index{
            case 0:
                if(peerID == butterView1.peerID_){
                    bv = butterView1
                }
            case 1:
                if(peerID == butterView2.peerID_){
                    bv = butterView2
                }
            case 2:
                if(peerID == butterView3.peerID_){
                    bv = butterView3
                }
            case 3:
                if(peerID == butterView4.peerID_){
                    bv = butterView4
                }
            default:
                println("this cant happen")
        }
            index++
        }
        return bv
    }
        
    //displays the gathered scores from each player at the end of the game
    func tallyScores(playerID: MCPeerID, playerScore: Int){
        checkPeerID(playerID).setScore(playerScore)
        
        if(winnerArray.count > 0){
            if(winnerArray[0].getScore() < playerScore){
                winnerArray.removeAll()
                winnerArray += [checkPeerID(playerID)]
            }
            else if(winnerArray[0].getScore() == playerScore){
                winnerArray += [checkPeerID(playerID)]
            }
        }
        else{
           winnerArray += [checkPeerID(playerID)]
        }
        for(var i = 0; i < winnerArray.count; i++){
            println("In array: \(winnerArray[i].peerID_)")
        }
    }

    //hides the images of butter to make scores more readable
    func hideButterGraphics(value: Bool) {
        if(butterView1.peerID_ != nil){
            butterImage1.hidden = value
        }
        if(butterView2.peerID_ != nil){
            butterImage2.hidden = value
        }
        if(butterView3.peerID_ != nil){
            butterImage3.hidden = value
        }
        if(butterView4.peerID_ != nil){
            butterImage4.hidden = value
        }
    }
    
    //this methods handles the receiving data from all peers, currently only receiving game over package
    func didReceiveDataWithNotification(notification: NSNotification) {
        var peerID: MCPeerID = notification.userInfo?["peerID"]! as MCPeerID
        var peerDisplayName = peerID.displayName as String
        var receivedData = notification.userInfo?["data"] as NSData
            
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
            
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()

        //this code is not fully implemented yet.
        /*
        if(type == "touch"){
            println("in touch")
            if(butterView1 != nil){
                if(peerID == butterView1.peerID_){
                    if(player1touch == true){
                        player1Label?.textColor = UIColor.blackColor()
                        
                        player1touch = false
                    }
                    else{
                        player1Label?.textColor = UIColor.greenColor()
                        
                        player1touch = true
                    }
                }
                else if(peerID == butterView2.peerID_){
                    if(player2touch == true){
                        player2Label?.textColor = UIColor.blackColor()
                        
                        player2touch = false
                    }
                    else{
                        player2Label?.textColor = UIColor.greenColor()
                        
                        player2touch = true
                    }
                }
                else if(peerID == butterView3.peerID_){
                    if(player3touch == true){
                        player3Label?.textColor = UIColor.blackColor()
                        
                        player3touch = false
                    }
                    else{
                        player3Label?.textColor = UIColor.greenColor()
                        
                        player3touch = true
                    }
                }
                else if(peerID == butterView4.peerID_){
                    if(player4touch == true){
                        player4Label?.textColor = UIColor.blackColor()
                        
                        player4touch = false
                    }
                    else{
                        player4Label?.textColor = UIColor.greenColor()
                        
                        player4touch = true
                    }
                }
            }

        }
         */
        
        //if receives a gameover packet, requests the score from the toast client
        if(type == "gameover"){
            if(butterView1 != nil){
                tallyScores(peerID, playerScore: receivedPackage.getScore())
                receivedGameOver = receivedGameOver! + 1
            }
            else{
                println("Debug seems like this is a random nil package")
            }
            
            if(receivedGameOver == connectedPeers){
               displayScores()
            }
        }
        
    }
    
    func displayScores(){
        println("Our winner is: \(winnerArray[0].displayName_)")
        for(var i = 0; i < winnerArray.count; i++){
            winnerArray[i].setStarBoolean(true)
        }
        for(var a = 0; a < connectedPeers; a++){
            switch a{
            case 0:
                if(butterView1.getStarBoolean()){
                    starImage1.hidden = false;
                }
                player1ScoreLabel?.text = String(butterView1.getScore())
                player1ScoreLabel?.hidden = false
            case 1:
                if(butterView2.getStarBoolean()){
                    starImage2.hidden = false;
                }
                player2ScoreLabel?.text = String(butterView2.getScore())
                player2ScoreLabel?.hidden = false
            case 2:
                if(butterView3.getStarBoolean()){
                    starImage3.hidden = false;
                }
                player3ScoreLabel?.text = String(butterView3.getScore())
                player3ScoreLabel?.hidden = false
            case 3:
                if(butterView4.getStarBoolean()){
                    starImage4.hidden = false;
                }
                player4ScoreLabel?.text = String(butterView4.getScore())
                player4ScoreLabel?.hidden = false
            default:
                println("default")
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}