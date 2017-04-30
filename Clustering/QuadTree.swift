//
//  QuadTree.swift
//  SwiftyMaugry
//
//  Created by Вероника Гайнетдинова on 30.03.17.
//  Copyright © 2017 msl. All rights reserved.
//

import Foundation

/* 
 A quad tree is a data structure comprising nodes which store a bucket of points and bounding box.
 Any point which is contained within the node's bounding box is added to its bucket.
 Once the bucket gets filled up, the node splits itself into 4 nodes, each with a bounding box
 corresponding to a quadrant of its parents bounding box.
 All points which would have gone into the parent's bucket now go into one of its children's buckets.
 */

class QuadTree {
    struct NodePoint {
        var x: Double //latitude
        var y: Double //longitude
        let id: String
        
        var data: Any? //extra point's data (name, phone number, ect.)
        
        init(x: Double, y: Double, id: String? = nil, data: Any? = nil) {
            self.x = x
            self.y = y
            self.id = id ?? UUID().uuidString
            self.data = data
        }
    }
    
    struct BoundingBox {
        var x0, x: Double
        var y0, y: Double
        
        func contains(point: NodePoint) -> Bool {
            return x0 <= point.x && point.x <= x
                && y0 <= point.y && point.y <= y
        }
        
        func intersects(boundingBox: BoundingBox) -> Bool {
            return x >= boundingBox.x0 && x0 <= boundingBox.x
                && y >= boundingBox.y0 && y0 <= boundingBox.y
        }
    }
    
    /*
        North
     West + East
        South
     */
    class Node {
        var northWest: Node?
        var northEast: Node?
        var southWest: Node?
        var southEast: Node?
        
        var boundingBox: BoundingBox!
        
        var bucketCapacity: Int = 0
        var points: [NodePoint]!
        
        convenience init(boundary: BoundingBox, bucketCapacity: Int) {
            self.init()
            boundingBox = boundary
            self.bucketCapacity = bucketCapacity
            points = [NodePoint]()
        }
    }
    
    class func insert(point: NodePoint, to node: Node) -> Bool {
        if !node.boundingBox.contains(point: point) {
            return false
        }
        
        if node.points.count < node.bucketCapacity {
            node.points.append(point)
            return true
        }
        
        if node.northWest == nil {
            subdivide(node: node)
        }
        var result = false
        if insert(point: point, to: node.northWest!) { result = true }
        else if insert(point: point, to: node.northEast!) { result = true }
        else if insert(point: point, to: node.southWest!) { result = true }
        else if insert(point: point, to: node.southEast!) { result = true }
        
        return result
    }
    
    class func subdivide(node: Node) {
        let xMid = (node.boundingBox.x + node.boundingBox.x0) / 2
        let yMid = (node.boundingBox.y + node.boundingBox.y0) / 2
        
        let northWestBox = BoundingBox(x0: node.boundingBox.x0, x: xMid, y0: node.boundingBox.y0, y: yMid)
        let northEastBox = BoundingBox(x0: xMid, x: node.boundingBox.x, y0: node.boundingBox.y0, y: yMid)
        let southWestBox = BoundingBox(x0: node.boundingBox.x0, x: xMid, y0: yMid, y: node.boundingBox.y)
        let southEastBox = BoundingBox(x0: xMid, x: node.boundingBox.x, y0: yMid, y: node.boundingBox.y)
        
        node.northWest = Node(boundary: northWestBox, bucketCapacity: node.bucketCapacity)
        node.northEast = Node(boundary: northEastBox, bucketCapacity: node.bucketCapacity)
        node.southWest = Node(boundary: southWestBox, bucketCapacity: node.bucketCapacity)
        node.southEast = Node(boundary: southEastBox, bucketCapacity: node.bucketCapacity)
    }
    
    class func gatherPoints(node: Node, in range: BoundingBox, closure: ((NodePoint) -> ())? = nil) {
        
        if node.boundingBox.intersects(boundingBox: range) {
            for point in node.points {
                if range.contains(point: point) {
                    closure?(point)
                }
            }
            
            if node.northWest != nil{
                gatherPoints(node: node.northWest!, in: range, closure: closure)
                gatherPoints(node: node.northEast!, in: range, closure: closure)
                gatherPoints(node: node.southWest!, in: range, closure: closure)
                gatherPoints(node: node.southEast!, in: range, closure: closure)
            }
        }
    }
    
    class func build(with points: [NodePoint], boundingBox: BoundingBox, capacity: Int) -> Node {
        let rootNode = Node(boundary: boundingBox, bucketCapacity: capacity)
        for point in points {
            _ = insert(point: point, to: rootNode)
        }
        return rootNode
    }
}

