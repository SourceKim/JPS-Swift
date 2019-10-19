//
//  JPS.swift
//  JPS
//
//  Created by 苏金劲 on 2019/10/19.
//  Copyright © 2019 苏金劲. All rights reserved.
//

import UIKit

class JPS: NSObject {
    
    var map: Map2D
    
    var open = [Node]()
    var close = [Node]()
    
    var width: Int {
        return map[0].count
    }
    
    var height: Int {
        return map.count
    }
    
    var endPos: coor!
    
    let dirs = [(1, 0), (0, 1), (0, -1), (-1, 0), (1, 1), (1, -1), (-1, 1), (-1, -1)]
    
    init(mapData: Map2D) {
        
        self.map = mapData
        
        super.init()
    }
    
    func find(startPos: coor, endPos: coor) -> [coor]? {
        
        self.endPos = endPos
        
        // 1. 构建 Node
        let node = Node(parent: nil, pos: startPos, g: 0, h: Float(abs(startPos.0 - endPos.0) + abs(startPos.1 - endPos.1)))
        self.open.append(node)
        
        // 2. 寻路
        while true {
            
            // open 为空，则不存在
            if self.open.isEmpty {
                return nil
            }
            
            // 找到最小的 f
            let (idx, minFNode) = self.getMinF()
            
            // 是否到达了终点
            if self.isReached(curPos: minFNode.pos) {
                
                return self.createPath(for: minFNode)
            }
            
            // 拓展
            self.extend(for: minFNode)
            
            // 加入 close
            self.close.append(minFNode)
            
            // 删除掉 (此时 open 的元素可能在拓展中有变化)
            self.open.remove(at: idx)
        }
    }
    
    private func getMinF() -> (Int, Node) {
        
        var minFNode = self.open[0]
        var idx = 0
        
        for i in 1..<self.open.count {
            let n = self.open[i]
            if n.f < minFNode.f {
                minFNode = n
                idx = i
            }
        }
        
        return (idx, minFNode)
    }
    
    private func isReached(curPos: coor) -> Bool {
        return curPos.0 == self.endPos.0 && curPos.1 == self.endPos.1
    }
    
    private func canPass(x: Int, y: Int) -> Bool {
        
        return (
                x >= 0 &&
                x < self.width &&
                y >= 0 &&
                y < self.height &&
                (self.map[x][y] != 1 || self.isReached(curPos: (x, y)))
        )
    }
    
    private func posIndexOfOpen(pos: coor) -> Int {
        
        var idx = -1
        
        for c in self.open {
            
            if c.pos.0 == pos.0 && c.pos.1 == pos.1 {
                return idx
            }
            
            idx += 1
        }
        return idx
        
    }
    
    private func isPosInClose(pos: coor) -> Bool {
        
        for c in self.close {
            
            if c.pos.0 == pos.0 && c.pos.1 == pos.1 {
                return true
            }
        }
        return false
    }
    
    // 计算 g 值；直走 = 1；斜走 = 1.4
    private func calG(pos0: coor, pos1: coor) -> Float {
        
        if pos0.0 == pos1.0 {
            return abs(Float(pos0.1) - Float(pos1.1))
        } else if pos0.1 == pos1.1 {
            return abs(Float(pos0.0) - Float(pos1.0))
        } else {
            return abs(Float(pos0.1) - Float(pos1.1)) * 1.4
        }
    }
    
    // 计算 h
    private func calH(pos0: coor, pos1: coor) -> Float {
        
        return Float(abs(pos0.0 - pos1.0) + abs(pos0.1 - pos1.1))
    }
    
    private func createPath(for node: Node) -> [coor] {
        
        var rtnCoor = [coor]()
        // 从结束点回溯到开始点，开始点的parent == None
        var n: Node? = node
        while n != nil {
            
            if let parent = n!.parent {
                
                let dir = n!.dir
                var pos = n!.pos
                
//                print("\(dir) == \(pos) == \(parent.pos)")
                
                while pos.0 != parent.pos.0 || pos.1 != parent.pos.1 {
                    rtnCoor.append(pos)
                    pos = (pos.0 - dir.0, pos.1 - dir.1)
                }
            } else {
                rtnCoor.append(n!.pos)
            }
            
            n = n?.parent
        }
        
        rtnCoor = rtnCoor.reversed()
        
        return rtnCoor
    }
    
    private func extend(for node: Node) {
        
        let nbs = self.getPruneNeighbours(of: node)
        
//        print("Prune Neighbours: \(nbs)")
        
        for nb in nbs {
            
            if let jumpPos = self.jump(curPos: nb, prePos: node.pos) {
                
                if self.isPosInClose(pos: jumpPos) {
                    continue
                }
                
                let g = self.calG(pos0: jumpPos, pos1: node.pos)
                let h = self.calH(pos0: jumpPos, pos1: self.endPos)
                let newNode = Node(parent: node, pos: jumpPos, g: node.g + g, h: h)
                
                self.open.append(newNode)
                
                
            }
        }
        
    }
    
    private func getPruneNeighbours(of node: Node) -> [coor] {
        
        var nbs = [coor]()
        
        if node.parent == nil { // 起始点
            
            for dir in self.dirs {
                
                let x = node.pos.0 + dir.0
                let y = node.pos.1 + dir.1
                
                if self.canPass(x: x, y: y) {
                    nbs.append((x, y))
                }
            }
            
        } else { // 非起始点
            
            let dir = node.dir // 进入的方向
            
            var x: Int
            var y: Int
            
            x = node.pos.0 + dir.0
            y = node.pos.1 + dir.1
            if self.canPass(x: x, y: y) {
                nbs.append((x, y))
            }
            
            if dir.0 != 0 && dir.1 != 0 { // 对角线方向
                
                // 1. 下
                x = node.pos.0
                y = node.pos.1 + dir.1
                if self.canPass(x: x, y: y) {
                    nbs.append((x, y))
                    
                    // 下 可以走，但是 左 不可以走
                    if !self.canPass(x: node.pos.0 - dir.0, y: node.pos.1) {
                        // 左下
                        nbs.append((node.pos.0 - dir.0, node.pos.1 + dir.1))
                    }
                }
                
                // 2. 右
                x = node.pos.0 + dir.0
                y = node.pos.1
                if self.canPass(x: x, y: y) {
                    nbs.append((x, y))
                    
                    // 右 可以走，但是 上 不可以走
                    if !self.canPass(x: node.pos.0, y: node.pos.1 - dir.1) {
                        // 右上
                        nbs.append((node.pos.0 + dir.0, node.pos.1 - dir.1))
                    }
                }
                
            } else { // 直线方向
                
                if dir.0 == 0 { // 垂直方向
                    
                    if !self.canPass(x: node.pos.0 + 1, y: node.pos.1) { // 右不能走
                        // 右下
                        nbs.append((node.pos.0 + 1, node.pos.1 + dir.1))
                    }
                    
                    if !self.canPass(x: node.pos.0 - 1, y: node.pos.1) { // 左不能走
                        // 左下
                        nbs.append((node.pos.0 - 1, node.pos.1 + dir.1))
                    }
                    
                } else { // 水平方向，向右走为例

                    if !self.canPass(x: node.pos.0, y: node.pos.1 + 1) { // 下不能走
                        // 右下
                        nbs.append((node.pos.0 + dir.0, node.pos.1 + 1))
                    }
                    
                    if !self.canPass(x: node.pos.0, y: node.pos.1 - 1) { // 上不能走
                        // 左下
                        nbs.append((node.pos.0 + dir.0, node.pos.1 - 1))
                    }
                    
                }
                
            }
            
        }
        
        return nbs
    }
    
    private func jump(curPos: coor, prePos: coor) -> coor? {
        
        if self.isReached(curPos: curPos) {
            return curPos
        }
        
        let dir = (curPos.0 == prePos.0 ? 0 : (curPos.0 - prePos.0) / abs(curPos.0 - prePos.0),
                   curPos.1 == prePos.1 ? 0 : (curPos.1 - prePos.1) / abs(curPos.1 - prePos.1))
        
//        print("cur: \(curPos) == pre: \(prePos) == dir: \(dir)")
        
        if !self.canPass(x: curPos.0, y: curPos.1) {
            return nil
        }
        
        if dir.0 != 0 && dir.1 != 0 { // 对角线
            
            // 左下能走且左不能走，或右上能走且上不能走
            if (self.canPass(x: curPos.0 - dir.0, y: curPos.1 + dir.1) && !self.canPass(x: curPos.0 - dir.0, y: curPos.1))
                ||
                (self.canPass(x: curPos.0 + dir.0, y: curPos.1 - dir.1) && !self.canPass(x: curPos.0, y: curPos.1 - dir.1)) {
                
                return curPos
            }
            
        } else { // 直走
            
            if dir.0 != 0 { // 水平方向
                
//                print("Horizon: \(self.canPass(x: curPos.0 + dir.0, y: curPos.1 + 1)) \(self.canPass(x: curPos.0, y: curPos.1 + 1)) \(self.canPass(x: curPos.0 + dir.0, y: curPos.1 - 1)) \(self.canPass(x: curPos.0, y: curPos.1 - 1))")
                
                // 右下能走且下不能走， 或右上能走且上不能走
                if (self.canPass(x: curPos.0 + dir.0, y: curPos.1 + 1) && !self.canPass(x: curPos.0, y: curPos.1 + 1))
                ||
                    (self.canPass(x: curPos.0 + dir.0, y: curPos.1 - 1) && !self.canPass(x: curPos.0, y: curPos.1 - 1)) {
                    
                    return curPos
                }
                
            } else { // 垂直方向
                
//                print("Vertical: \(self.canPass(x: curPos.0 + 1, y: curPos.1 + dir.1)) \(self.canPass(x: curPos.0 + 1, y: curPos.1 + dir.1)) \(self.canPass(x: curPos.0 - 1, y: curPos.1 + dir.1)) \(self.canPass(x: curPos.0 - 1, y: curPos.1 + dir.1))")
                
                // 右下能走且右不能走，或左下能走且左不能走
                if (self.canPass(x: curPos.0 + 1, y: curPos.1 + dir.1) && !self.canPass(x: curPos.0 + 1, y: curPos.1))
                ||
                    (self.canPass(x: curPos.0 - 1, y: curPos.1 + dir.1) && !self.canPass(x: curPos.0 - 1, y: curPos.1)) {
                    
                    return curPos
                }
            }
            
        }
        
        if dir.0 != 0 && dir.1 != 0 {
            
            let n0 = self.jump(curPos: (curPos.0 + dir.0, curPos.1), prePos: curPos)
            let n1 = self.jump(curPos: (curPos.0, curPos.1 + dir.1), prePos: curPos)
            
            if n0 != nil || n1 != nil {
                return curPos
            }
        }
        
        if self.canPass(x: curPos.0 + dir.0, y: curPos.1) || self.canPass(x: curPos.0, y: curPos.1 + dir.1) {
            
            if let n = self.jump(curPos: (curPos.0 + dir.0, curPos.1 + dir.1), prePos: curPos) {
                return n
            }
        }
        
        return nil
        
    }

}
