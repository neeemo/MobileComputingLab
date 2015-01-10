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
    
    var startTime = NSTimeInterval()
    
    var countDownBool: Bool = true
    
    var gameTime: Double = 0
    
    var roundTimer: NSTimer = NSTimer()
    
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
        
        //erase all labels in the player scores
        for playerScoreLabel in playerScoreLabelArray {
            playerScoreLabel.text = ""
        }
        
        //adding a peerID/displayname to each butterview
        for(var i = 0; i < appDelegate?.mcManager?.getConnectedPeers().count; i++){
            var player: MCPeerID? = appDelegate?.mcManager?.getConnectedPeer(i)
            playerLabelArray[i].text = player?.displayName
            butterViewArray[i].setPeerID(player!)
            butterViewArray[i].setName(player!.displayName)
        }
        
    }
    
    //activating all butterviews
    func activateButterViews(){
        for(var i = 0; i < appDelegate?.mcManager?.getConnectedPeers().count; i++){
            butterViewArray[i].setRoundStarted(true)
        }

    }
    
    //sets the countdown to 5 secs (2 sec delay) and starts the timer
    func startCountDown(){
        gameTime = 7
        startTimer()
    }

    //starts a timer that uses the updateTime method
    func startTimer(){
        timerLabel?.textColor = UIColor.greenColor()
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
            //for debugging, changed gameTime to 5 from 52
            gameTime = 5
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
        println(appDelegate?.mcManager!.session.connectedPeers.count)
            
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
        println(appDelegate?.mcManager!.session.connectedPeers.count)
            
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
    
    func markWinners (winnerArray: [MCPeerID], numberOfPlayers: Int) {
        //creates an array of the star view controllers, makes programming cleaner later
        var starArray: [UIImageView] = []
        starArray += [starImage1]
        starArray += [starImage2]
        starArray += [starImage3]
        starArray += [starImage4]
        
        //iterates through every entry in the winnerArray and marks their score with a star
        for winner in winnerArray {
            for (var i = 0; i < numberOfPlayers; i++) {
                println("Star for player \(i+1) is \(starArray[i].hidden)")
                if (winner == butterViewArray[i].peerID_) {
                    starArray[i].hidden = false
                }
                else {
                    starArray[i].hidden = true
                }
                //debugging line
                println("Star for player \(i+1) is \(starArray[i].hidden)")
            }
        }
    }
    
    //hides the images of butter to make scores more readable
    func removeButterGraphics() {
        butterImage1.hidden = true
        butterImage2.hidden = true
        butterImage3.hidden = true
        butterImage4.hidden = true
    }
    
    //this methods handles the receiving data from all peers, currently only receiving game over package
    func didReceiveDataWithNotification(notification: NSNotification) {
        var peerID: MCPeerID = notification.userInfo?["peerID"]! as MCPeerID
        var peerDisplayName = peerID.displayName as String
        var receivedData = notification.userInfo?["data"] as NSData
            
        var allPeers = appDelegate?.mcManager!.session.connectedPeers
            
        var receivedPackage: Package = NSKeyedUnarchiver.unarchiveObjectWithData(receivedData) as Package
        var type = receivedPackage.getType()
        
        var winnerArray: [MCPeerID] = []
        var numberOfPlayers = allPeers!.count
            
        //if receives a gameover packet, requests the score from the toast client
        if(type == "gameover"){
            removeButterGraphics()
            winnerArray = tallyScores(peerID, playerScore: receivedPackage.getScore(), numberOfPlayers: numberOfPlayers)
            markWinners(winnerArray, numberOfPlayers: numberOfPlayers)
            
                
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