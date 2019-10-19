//
//  ViewController.swift
//  JPS
//
//  Created by 苏金劲 on 2019/10/19.
//  Copyright © 2019 苏金劲. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let map = Map(fileName: "map")
    
    var jps: JPS!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Map.printMap(self.map.mapArr)
        
        self.jps = JPS(mapData: self.map.mapArr)
        let paths = self.jps.find(startPos: (6, 0), endPos: (0, 6))
        
        if let ps = paths {
            let newMap = Map.createMap(originMap: self.map.mapArr, with: ps)
            Map.printMap(newMap)
        } else {
            print("Can't find path")
        }
        
        
    }


}

