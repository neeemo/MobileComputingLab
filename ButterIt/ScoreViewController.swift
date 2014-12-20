//
//  ScoreViewController.swift
//  ButterIt
//
//  Created by Steven Teng on 19/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ScoreViewController: UIViewController, UITextViewDelegate {
    
    var appDelegate: AppDelegate? = UIApplication.sharedApplication().delegate as? AppDelegate
    @IBOutlet weak var scoreView: UITextView?
    
    var playerScores_ = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scoreView?.delegate = self

    }
    
    override func viewDidAppear(animated: Bool) {
        scoreView?.text = playerScores_
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func enterScoreView(playerScores: String){
        playerScores_ = playerScores
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
