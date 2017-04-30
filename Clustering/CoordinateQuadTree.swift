//
//  CoordinateQuadTree.swift
//  SwiftyMaugry
//
//  Created by Вероника Гайнетдинова on 30.03.17.
//  Copyright © 2017 msl. All rights reserved.
//

import UIKit
import MapKit

class CoordinateQuadTree {
    var root: QuadTree.Node?
    var mapView: MKMapView?
    
    func buildTree(with points: [QuadTree.NodePoint]) {
        let worldBounds = QuadTree.BoundingBox(x0: -180, x: 180, y0: -90, y: 90)
//        let worldBounds = QuadTree.BoundingBox(x0: -90, x: 90, y0: -180, y: 180)
        root = QuadTree.build(with: points, boundingBox: worldBounds, capacity: 4)
    }
    
    func clusteredAnnotations(within mapRect: MKMapRect, zoomScale: MKZoomScale) -> [ClusterAnnotation]? {
        
        guard let rootNode = root else {
            return nil
        }
        
        let cellSize: CGFloat = makeCellSize(from: zoomScale)
        let scaleFactor = Double(zoomScale / cellSize)
        
        let minX = Int(floor(MKMapRectGetMinX(mapRect) * scaleFactor))
        let maxX = Int(floor(MKMapRectGetMaxX(mapRect) * scaleFactor))
        let minY = Int(floor(MKMapRectGetMinY(mapRect) * scaleFactor))
        let maxY = Int(floor(MKMapRectGetMaxY(mapRect) * scaleFactor))
        
        var clusteredAnnotations = [ClusterAnnotation]()
        for x in minX...maxX {
            for y in minY...maxY {
                let newRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor)
                var totalX = 0.0
                var totalY = 0.0
                var count = 0
                var pointId: String = ""
                var pointData: Any?
            
                QuadTree.gatherPoints(node: rootNode, in: boundingBox(for: newRect), closure: { point in
                    totalX += point.x
                    totalY += point.y
                    count += 1
                    if count == 1 {
                        pointId = point.id
                        pointData = point.data
                    }
                })
                
                if count == 1 {
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(totalX), longitude: CLLocationDegrees(totalY))
                    let annotation = SinglePinAnnotation(coordinate: coordinate, id: pointId, data: pointData)
                    clusteredAnnotations.append(annotation)
                } else if count > 1 {
                    let coordinate = CLLocationCoordinate2D(latitude: totalX / count, longitude: totalY / count)
                    let annotation = ClusterAnnotation(coordinate: coordinate, count: count)
                    clusteredAnnotations.append(annotation)
                }
            }
        }
        return clusteredAnnotations
    }
    
    private func boundingBox(for mapRect: MKMapRect) -> QuadTree.BoundingBox {
        let topLeft = MKCoordinateForMapPoint(mapRect.origin)
        let bottomRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
        
        let minLatitude = bottomRight.latitude
        let maxLatitude = topLeft.latitude
        
        let minLongitude = topLeft.longitude
        let maxLongitude = bottomRight.longitude
        
        return QuadTree.BoundingBox(x0: minLatitude, x: maxLatitude, y0: minLongitude, y: maxLongitude)
    }
    
    private func mapRect(for boundingBox: QuadTree.BoundingBox) -> MKMapRect {
        let topLeft = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: boundingBox.x0, longitude: boundingBox.y0))
        let bottomRight = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: boundingBox.x, longitude: boundingBox.y))
        
        return MKMapRectMake(topLeft.x, bottomRight.y, abs(bottomRight.x - topLeft.x), abs(bottomRight.y - topLeft.y))
    }
    
    private func makeCellSize(from zoomScale: MKZoomScale) -> CGFloat {
        var size: CGFloat = 0
        switch zoomLevel(from: zoomScale) {
        case 13, 14, 15:
            size = 64
        case 16, 17, 18:
            size = 32
        case 19:
            size = 16
        default:
            size = 88
        }
        return size
    }
    
    private func zoomLevel(from zoomScale: MKZoomScale) -> Int {
        let totalTilesAtmaxZoom = MKMapSizeWorld.width / 256.0
        let zoomLevelAtMaxZoom = Float(log2(totalTilesAtmaxZoom))
        
        return max(0, Int(zoomLevelAtMaxZoom + floor(log2f(Float(zoomScale)) + Float(0.5))))
    }
}
