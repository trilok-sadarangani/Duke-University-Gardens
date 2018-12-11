//
//  MapOverlay.swift
//  DukeGardensApp
//
//  Created by Toby Nzewi on 11/26/18.
//  Copyright © 2018 Richard Vargo. All rights reserved.
//

import UIKit
import MapKit

class MapOverlay: NSObject, MKOverlay {
    
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(garden: Garden) {
        boundingMapRect = garden.overlayBoundingMapRect
        coordinate = garden.midCoordinate
    }
}
