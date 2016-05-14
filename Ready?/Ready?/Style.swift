//
//  Style.swift
//  Ready?
//
//  Created by Hidekazu Shidara on 2/6/16.
//  Copyright © 2016 Hidekazu Shidara. All rights reserved.
//
//  Singleton, baby!!

import UIKit

class Style {
    
    let font = String("Arial")
    
    private static var style: Style?
    
    static func getStyle()->Style{
        if let st = style{
            return st
        }
        return Style()
    }
}
//  Style.getStyle().font