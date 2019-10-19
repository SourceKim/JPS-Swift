//
//  Node.swift
//  JPS
//
//  Created by 苏金劲 on 2019/10/19.
//  Copyright © 2019 苏金劲. All rights reserved.
//

import UIKit

class Node: NSObject {
    
    var parent: Node?
    var pos: coor
    var g: Float
    var h: Float
    
    var f: Float {
        get {
            return g + h
        }
    }
    
    var dir: coor {
        
        if let p = self.parent { // 有过有父节点
            
            // 该节点和父节点相同则方向为 0，否则为 ±1 （方向）
            return (self.pos.0 == p.pos.0 ? 0 : (self.pos.0 - p.pos.0) / abs(self.pos.0 - p.pos.0),
                    self.pos.1 == p.pos.1 ? 0 : (self.pos.1 - p.pos.1) / abs(self.pos.1 - p.pos.1))
            
        } else { // 如果没有父节点
            
            return (0, 0)
        }
    }
    
    init(parent: Node?,pos: coor, g: Float, h: Float) {
        
        self.parent = parent
        self.pos = pos
        self.g = g
        self.h = h
        
        super.init()
    }

}
