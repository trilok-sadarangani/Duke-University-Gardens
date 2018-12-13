//
//  AttractionAnnotation.swift
//  DukeGardensApp
//
//  Created by Toby Nzewi on 11/26/18.
//  Copyright © 2018 Richard Vargo. All rights reserved.
//

import UIKit
import MapKit

enum AttractionType: String {
    case restroom
    case water
    case help
    case atm
    
    func image() -> UIImage {
        switch self {
        case .restroom:
            return #imageLiteral(resourceName: "restroom")
        case .water:
            return #imageLiteral(resourceName: "water")
        case .help:
            return #imageLiteral(resourceName: "help")
        case .atm:
            return #imageLiteral(resourceName: "atm")
        }
    }
}

class AttractionAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var type: AttractionType
    
    init(coordinate: CLLocationCoordinate2D, title: String, type: AttractionType) {
        self.coordinate = coordinate
        self.title = title
        self.type = type
    }
}
