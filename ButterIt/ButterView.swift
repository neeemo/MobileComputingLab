//
//  ButterView.swift
//  ButterItSwift
//
//  Created by James Wellence on 11/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit

class ButterView: UIImageView {
    var playerNumber = 0 //player numbers are assigned in the ButterViewController in the didLoad functin
    var scoopAmount: Double = 0 //as a player "scoops" butter, this value goes up
    var startTime = NSDate() //used in calculating the amount of butter scooped
    let maxScoopAmount: Double = 100
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("This is player \(playerNumber)")
        startTime = NSDate()
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if scoopAmount < maxScoopAmount {
            //scoopAmount++
            let endTime = NSDate()
            let timeInterval: Double = endTime.timeIntervalSinceDate(startTime); //Difference in seconds (double)
            scoopAmount = scoopAmount + timeInterval
        }
        
        println("Butter on player \(playerNumber)'s knife = \(scoopAmount)")
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        println("Player \(playerNumber) has stopped scooping")
        //scoopAmount = 0
    }

}
