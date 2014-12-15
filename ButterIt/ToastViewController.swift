//
//  ToastViewController.swift
//  ButterItSwift
//
//  Created by James Wellence on 10/12/14.
//  Copyright (c) 2014 Team Butter. All rights reserved.
//

import UIKit

class ToastViewController: UIViewController {

    @IBOutlet var toastView: UIImageView!
    @IBOutlet var tempToastView: UIImageView!
    var lastPoint: CGPoint! //for drawing the butter lines
    var holdHereActive = false //boolean to see if the player is pressing on the Hold Here button
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //tempToastView.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        lastPoint = touches.anyObject()?.locationInView(tempToastView)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        if holdHereActive == true {
            var currentPoint = touches.anyObject()?.locationInView(tempToastView)
            
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
            
            UIGraphicsEndImageContext()
            
            lastPoint = currentPoint
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
    }
    
    @IBAction func holdHerePressed() {
        holdHereActive = true
        println("Button pressed = \(holdHereActive)")
    }
    
    @IBAction func holdHereReleased() {
        holdHereActive = false
        println("Button pressed = \(holdHereActive)")
    }



}

