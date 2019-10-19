//
//  Map.swift
//  JPS
//
//  Created by 苏金劲 on 2019/10/19.
//  Copyright © 2019 苏金劲. All rights reserved.
//

typealias Map2D = [[Int]]
typealias coor = (Int, Int)

import UIKit

class Map: NSObject {
    
    var mapArr = Map2D()
    
    init(fileName: String) {
        
        let path = Bundle.main.path(forResource: fileName, ofType: nil)
        let str = try! String(contentsOfFile: path!)
        
        let lines = str.components(separatedBy: "\n")
        
        for line in lines {
            
            if line == "" {
                continue
            }
            
            self.mapArr.append(line.components(separatedBy: " ").map({ (str) -> Int in
                return Int(str)!
            }))
        }
        
    }
    
    static func createMap(originMap: Map2D, with Paths: [coor]) -> Map2D {
        
        var newMap = originMap
        
        for path in Paths {
            newMap[path.0][path.1] = 9
        }
        
        return newMap
        
    }
    
    static func printMap(_ map: Map2D) {
        
        print("=========")
        
        for arr in map {
            
            var str = ""
            for val in arr {
                str += "\(val) "
            }
            print(str)
            
        }
        
        print("=========")
    }

}
