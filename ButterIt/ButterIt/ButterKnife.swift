//
//  Butter.swift
//  Toast
//
//  Created by James Wellence on 04/12/14.
//  Copyright (c) 2014 James Wellence. All rights reserved.
//

import UIKit

class ButterKnife {

    var butterAmount: Int = 0
    
    let maxButterAmount = 1000
    let minButterAmount = 0
    
    /*init(start _start: CGPoint, end _end: CGPoint) {
        start = _start
        end = _end
        butterAmount = 0
    }*/
    
    //when scooping butter, adds the amount to the knife - returns maxButterAmount when knife can't hold more butter
    func addButter(addButterAmount: Int) -> Int {
        butterAmount = butterAmount + addButterAmount
        
        if butterAmount > maxButterAmount {
            butterAmount = maxButterAmount
        }
        
        return butterAmount
    }
    
    //when spreading butter, removes the amount from the knife / returns minButterAmount (ie 0) when butter used up
    func removeButter(removeButterAmount: Int) -> Int {
        butterAmount = butterAmount - removeButterAmount
        
        if butterAmount < minButterAmount {
            butterAmount = minButterAmount
        }
        
        return butterAmount
    }
}

