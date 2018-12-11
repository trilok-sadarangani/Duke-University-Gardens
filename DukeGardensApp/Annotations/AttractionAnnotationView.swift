//
//  AttractionAnnotationView.swift
//  DukeGardensApp
//
//  Created by Toby Nzewi on 11/26/18.
//  Copyright © 2018 Richard Vargo. All rights reserved.
//


import UIKit
import MapKit

class AttractionAnnotationView: MKAnnotationView {
    
    // Required for MKAnnotationView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        guard let attractionAnnotation = self.annotation as? AttractionAnnotation else { return }
        
        image = attractionAnnotation.type.image()
    }
}

