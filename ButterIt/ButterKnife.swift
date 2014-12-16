//
//  Butter.swift
//  Toast
//
//  Created by James Wellence on 04/12/14.
//  Copyright (c) 2014 James Wellence. All rights reserved.
//

import UIKit

class ButterKnife {

    var butterAmount_: Double = 0
    
    let maxButterAmount: Double = 100
    let minButterAmount: Double = 0
    
    /*init(start _start: CGPoint, end _end: CGPoint) {
        start = _start
        end = _end
        butterAmount = 0
    }*/
    
    //when scooping butter, adds the amount to the knife - returns maxButterAmount when knife can't hold more butter
    
    func setButter(butterAmount: Double){
        butterAmount_ = butterAmount
    }
    
    func addButter(addButterAmount: Double) -> Double {
        butterAmount_ = butterAmount_ + addButterAmount
        
        if butterAmount_ > maxButterAmount {
            butterAmount_ = maxButterAmount
        }
        
        return butterAmount_
    }
    
    //when spreading butter, removes the amount from the knife / returns minButterAmount (ie 0) when butter used up
    func removeButter(removeButterAmount: Double) -> Double {
        butterAmount_ = butterAmount_ - removeButterAmount
        
        if butterAmount_ < minButterAmount {
            butterAmount_ = minButterAmount
        }
        
        return butterAmount_
    }
}

