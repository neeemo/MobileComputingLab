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
    
    var lastPoint: CGPoint!
    
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
        var currentPoint = touches.anyObject()?.locationInView(tempToastView)
        
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
        tempToastView.alpha = 0.5

        //CGContextSetAlpha(UIGraphicsGetCurrentContext(), 0.5);
        //[self.tempDrawImage setAlpha:opacity];
        //toastView.alpha = 0.5
        UIGraphicsEndImageContext()
        
        lastPoint = currentPoint
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        UIGraphicsBeginImageContext(toastView.frame.size)
        toastView.image?.drawInRect(CGRectMake(0, 0, toastView.frame.size.width, toastView.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        
        tempToastView.image?.drawInRect(CGRectMake(0, 0, tempToastView.frame.size.width, tempToastView.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 0.5)
        
        toastView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempToastView.image = nil;
        UIGraphicsEndImageContext();
    }



}

