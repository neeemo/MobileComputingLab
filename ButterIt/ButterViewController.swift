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
    
    
    @IBOutlet weak var timerLabel: UILabel?
    
    @IBOutlet weak var playButton: UIButton?
    
    var startTime = NSTimeInterval()
    
    var countDownBool: Bool = true
    
    var gameTime: Double = 0
    
    var roundTimer: NSTimer = NSTimer()
    
    var playersArray: NSMutableArray?
    
    //array that stores which ButterView belongs to which Peer, which playernumber belongs to each peer, 0=Player1, 1=Player2, etc
    var butterViewArray: [ButterView] = []
    var playerLabelArray: [UILabel] = []
    var playerScoreLabelArray: [UILabel] = []
    
    var hostPeerID: MCPeerID?
    
    var playerScores = String()
    
    var receivedGameOver: Int?
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        timerLabel?.textColor = UIColor.greenColor()
        
        receivedGameOver = 0
        
        playButton?.hidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveDataWithNotification:", name: "ButterIt_DidReceiveDataNotification", object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerLabel?.textColor = UIColor.redColor()
        timerLabel?.text = "Press play to start!"
    }
    
    override func viewDidAppear(animated: Bool) {
        registerPlayerOnLabels()
        //startTimer()
        //startCountDown()
    }
    
    @IBAction func playButtonFunc(sender: UIButton){
        startCountDown()
        playButton?.hidden = true
    }
    
    //Register players and set butterView
    func registerPlayerOnLabels(){
        //fill the butterViewArray with the four butterViews
        butterViewArray += [butterView1]
        butterViewArray += [butterView2]
        butterViewArray += [butterView3]
        butterViewArray += [butterView4]
        
        //fill the playerLabel array with the player positions
        playerLabelArray += [player1Label!]
        playerLabelArray += [player2Label!]
        playerLabelArray += [player3Label!]
        playerLabelArray += [player4Label!]
        
        //fill the playerScoreLabel array with player scores
        playerScoreLabelArray += [player1ScoreLabel!]
        playerScoreLabelArray += [player2ScoreLabel!]
        playerScoreLabelArray += [player3ScoreLabel!]
        playerScoreLabelArray += [player4ScoreLabel!]
        
        for(var i = 0; i < appDelegate?.mcManager?.getConnectedPeers().count; i++){
            var player: MCPeerID? = appDelegate?.mcManager?.getConnectedPeer(i)
            playerLabelArray[i].text = player?.displayName
            butterViewArray[i].setPeerID(player!)
            butterViewArray[i].setName(player!.displayName)
            
            //commented out below to test the score above
            /*switch (i) {
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
            println("Something is wrong, This print can not happen!")
            }*/
            playersArray?.addObject(player!)
        }
        
    }
    
    func activateButterViews(){
        for(var i = 0; i < appDelegate?.mcManager?.getConnectedPeers().count; i++){
            butterViewArray[i].setRoundStarted(true)

        }

    }
    
    func startCountDown(){
        gameTime = 7
        startTimer()
    }

    func startTimer(){
        timerLabel?.textColor = UIColor.greenColor()
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

        if(seconds < 5 && !countDownBool){
            timerLabel?.textColor = UIColor.redColor()
        }
        if(seconds  > 0){
            elapsedTime -= NSTimeInterval(seconds)
            timerLabel?.text = String(Int(seconds))
        }
        else if(countDownBool){
            stopTimer()
            gameTime = 52
            timerLabel?.textColor = UIColor.greenColor()
            timerLabel?.text = "GO!"
            startTimer()
            activateButterViews()
            sendStartRound()
            countDownBool = false
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
        
    func sendStartRound(){
        var type = "roundBegin"
        var package = Package(type: type, sender: "butterHost", roundBegin: true)
            
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
        
    //displays the gathered scores from each player at the end of the game
    func tallyScores(playerID: MCPeerID, playerScore: Int, numberOfPlayers: Int) -> [MCPeerID] {
        //array that stores the players who have the highest score, so it is possible to have a draw
        var winnerArray: [MCPeerID] = []
        var highScore = 0
            
        //compares the incoming playerID with all playerIDs
        for (var i = 0; i < numberOfPlayers; i++) {
            if (playerID == butterViewArray[i].peerID_) {
                //once player identified, displays score on screen...
                playerScoreLabelArray[i].text = String(playerScore)
                    
                //...then checks to see if it is a high score
                if (playerScore > highScore) {
                    //if highest score, erases winnerArray and puts this player's score in the array
                    winnerArray = []
                    winnerArray += [playerID]
                }
                //if not a new high score, then checks to see if it tied the existing high score
                else if (playerScore == highScore) {
                    //appends this player ID to the winnerArray, resulting in a tie
                    winnerArray += [playerID]
                }
            }
        }
        return winnerArray
    }
        
    func didReceiveDataWithNotification(notification: NSNotification) {
        var peerID: MCPeerID = notification.userInfo?["peerID"]! as MCPeerID
        var peerDisplayName = peerID.displayName as String
        var receivedData = notification.userInfo?["data"] as NSData
            
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
            
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()
            
        //if receives a gameover packet, requests the score from the toast client
        if(type == "gameover"){
            tallyScores(peerID, playerScore: receivedPackage.getScore(), numberOfPlayers:allPeers!.count)
                
            //var tempString = ("\(peerDisplayName) score is: \(receivedPackage.getScore())")
            //playerScores = playerScores + tempString + "\n"
                
            //tallies the number of players that have returned a gameover message
            receivedGameOver = receivedGameOver! + 1
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}