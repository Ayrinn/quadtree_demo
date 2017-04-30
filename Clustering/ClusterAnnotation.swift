//
//  ClusterAnnotation.swift
//  SwiftyMaugry
//
//  Created by Вероника Гайнетдинова on 31.03.17.
//  Copyright © 2017 msl. All rights reserved.
//

import MapKit

class ClusterAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    private(set) var count: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, count: Int = 0, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title ?? (count > 1 ? "\(count) \(LanguageManager.stringFor(key: "objects_in_area"))" : nil)
        self.subtitle = subtitle
        
        self.count = count
        
        super.init()
    }
    
    override var description: String {
        return "ClusterAnnotation: coordinate: {\(coordinate.latitude), \(coordinate.longitude)}, count: \(count)"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let comparedObject = object as? ClusterAnnotation else {
            return false
        }
        
        return coordinate.latitude == comparedObject.coordinate.latitude
            && coordinate.longitude == comparedObject.coordinate.longitude
            && title == comparedObject.title
            && subtitle == comparedObject.subtitle
            && count == comparedObject.count
    }
    
    override var hashValue: Int {
        get {
            return count.hashValue << 15 &+ coordinate.latitude.hashValue &+ coordinate.longitude.hashValue
        }
    }
}

class SinglePinAnnotation: ClusterAnnotation {
    let id: String
    var data: Any?
    
    init(coordinate: CLLocationCoordinate2D, id: String, title: String? = nil, subtitle: String? = nil, data: Any? = nil) {
        self.id = id
        self.data = data
        super.init(coordinate: coordinate, count: 1, title: title, subtitle: subtitle)
    }
    
    override var description: String {
        return "SinglePinAnnotation: coordinate: {\(coordinate.latitude), \(coordinate.longitude)}, id: \(id)"
    }
}
