//
//  ViewExtension.swift
//  HealthKitDemo
//
//  Created by ZhangWei-SpaceHome on 2017/2/9.
//  Copyright © 2017年 zhangwei. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func width() -> (CGFloat) {
        return self.frame.size.width
    }
    
    func height() -> (CGFloat) {
        return self.frame.size.height
    }
    
    func left() -> (CGFloat) {
        return self.frame.origin.x 
    }
    
    func right() -> (CGFloat) {
        return (self.frame.origin.x + self.frame.size.width)
    }
    
    func top() -> (CGFloat) {
        return (self.frame.origin.y)
    }
    
    func bottom() -> (CGFloat) {
        return (self.frame.origin.y + self.frame.size.height)
    }
    
    func centerX() -> (CGFloat) {
        return (self.frame.origin.x + self.frame.size.width/2)
    }
    
    func centerY() -> (CGFloat) {
        return (self.frame.origin.y + self.frame.size.height/2)
    }
}
