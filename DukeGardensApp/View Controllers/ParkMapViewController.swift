//
//  ParkMapViewController.swift
//  DukeGardensApp
//
//  Created by Toby Nzewi on 11/26/18.
//  Copyright © 2018 Richard Vargo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ParkMapViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var currentlocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var mapView: MKMapView!
    
    var garden = Garden(filename: "MagicMountain")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices()
        self.addOverlay()
        self.addAttractionPins()
        
        
        let latDelta = garden.overlayTopLeftCoordinate.latitude - garden.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpan(latitudeDelta: fabs(latDelta), longitudeDelta: 0.0)
        let region = MKCoordinateRegion(center: garden.midCoordinate, span: span)
        
        mapView.region = region
    }
    
    func configureLocationServices() {
        locationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        
        if status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if status == .authorizedAlways || status == .authorizedWhenInUse{
            beginLocationUpdates(locationManager: locationManager)
        }
        
    }
    
    func beginLocationUpdates(locationManager: CLLocationManager){
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        
        let zoomRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    // MARK: - Add methods
    func addOverlay() {
        let overlay = MapOverlay(garden: garden)
        mapView.addOverlay(overlay)
    }
    
    func addAttractionPins() {
        guard let attractions = Garden.plist("GardensAttractions") as? [[String : String]] else { return }
        
        for attraction in attractions {
            let coordinate = Garden.parseCoord(dict: attraction, fieldName: "location")
            let title = attraction["name"] ?? ""
            let typeRawValue = Int(attraction["type"] ?? "0") ?? 0
            let type = AttractionType(rawValue: typeRawValue) ?? .restroom
            let annotation = AttractionAnnotation(coordinate: coordinate,title: title, type: type)
            mapView.addAnnotation(annotation)
        }
    }
    
    func addRoute() {
        guard let points = Garden.plist("EntranceToGoliathRoute") as? [String] else { return }
        
        let cgPoints = points.map { NSCoder.cgPoint(for: $0) }
        let coords = cgPoints.map { CLLocationCoordinate2DMake(CLLocationDegrees($0.x), CLLocationDegrees($0.y)) }
        let myPolyline = MKPolyline(coordinates: coords, count: coords.count)
        
        mapView.addOverlay(myPolyline)
    }
    
    func addBoundary() {
        mapView.addOverlay(MKPolygon(coordinates: garden.boundary, count: garden.boundary.count))
    }
    
    func addCharacterLocation() {
     self.mapView.showsUserLocation = true
    }
    

    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
}

extension ParkMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestlocation = locations.first else { return }
        
        if currentlocation == nil {
            zoomToLatestLocation(with: latestlocation.coordinate)
        }
        
        currentlocation = latestlocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse{
            beginLocationUpdates(locationManager: manager)
        }
    }
    
}

// MARK: - MKMapViewDelegate
extension ParkMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MapOverlay {
            return MapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_park"))
        } else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.blue
            return polygonView
        } else if let character = overlay as? Character {
            let circleView = MKCircleRenderer(overlay: character)
            circleView.strokeColor = character.color
            return circleView
        }
        
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let annotationView = AttractionAnnotationView(annotation: annotation, reuseIdentifier: "Attraction")
        annotationView.canShowCallout = true
        return annotationView
    }
}
