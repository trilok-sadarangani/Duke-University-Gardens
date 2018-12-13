//
//  ViewController.swift
//  HamburgerMenuBlog
//
//  Created by Erica Millado on 7/15/17.
//  Copyright © 2017 Erica Millado. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase



class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    let locationManager = CLLocationManager()
    var currentlocation: CLLocationCoordinate2D?
    @IBOutlet weak var mapView: MKMapView!
    var garden = Garden(filename: "DukeGardens")
    
    @IBOutlet var leadingC: NSLayoutConstraint!
    @IBOutlet var trailingC: NSLayoutConstraint!
    @IBOutlet var ubeView: UIView!
    var hamburgerMenuIsVisible = false
    
    
    @IBAction func webButton(_ sender: Any) {
        if let url = URL(string: "https://ads-web-01.oit.duke.edu/GVT/Register_new.aspx") {
            UIApplication.shared.open(url, options: [:])
        }
    }
  
    
    
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
        addNavBarImage()
        
        
    }
    
    
    
    func addNavBarImage() {
        
        let navController = navigationController!
        let image = #imageLiteral(resourceName: "logo")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navController.navigationBar.frame.size.width
        let bannerHeight = navController.navigationBar.frame.size.height
        
        let bannerX = bannerWidth/2 - image.size.width / 2
        let bannerY = bannerHeight/2 - image.size.height / 2 * 0.9
        
        imageView.frame = CGRect(x : bannerX, y : bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        
    }
    
    @IBAction func hamburgerBtnTapped(_ sender: Any) {
        //if the hamburger menu is NOT visible, then move the ubeView back to where it used to be
        if !hamburgerMenuIsVisible {
            leadingC.constant = 150
            //this constant is NEGATIVE because we are moving it 150 points OUTWARD and that means -150
            trailingC.constant = -150
            
            //1
            hamburgerMenuIsVisible = true
        } else {
            //if the hamburger menu IS visible, then move the ubeView back to its original position
            leadingC.constant = 0
            trailingC.constant = 0
            
            //2
            hamburgerMenuIsVisible = false
        }
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
        
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
    
    
    public struct Annotation : Decodable {
        let id : String
        let information: String
        let latitude: Double
        let longitude: Double
        let name: String
        let type: String
    }
    func addAttractionPins() {
        
        let urlString = "https://compsci-316-215619.firebaseio.com/annotations.json"
        guard let url = URL(string: urlString) else {return}
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            
            guard let data = data else {return}
            
            do {
                let decoder = JSONDecoder()
                let attractions = try decoder.decode([Annotation].self, from: data)
                
                for attraction in attractions {
                    let coordinate =  CLLocationCoordinate2DMake(attraction.latitude, attraction.longitude)
                    let title = attraction.name
                    let type = AttractionType(rawValue: attraction.type) ?? .restroom
                    let annotation = AttractionAnnotation(coordinate: coordinate, title: title, type: type)
                    self.mapView.addAnnotation(annotation)
                }
                
            } catch let jsonErr {
                print("Error Serializing Annotation JSON: ", jsonErr)
            }
            
            }.resume()
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

extension ViewController: CLLocationManagerDelegate {
    
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
extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MapOverlay {
            return MapOverlayView(overlay: overlay, overlayImage: #imageLiteral(resourceName: "overlay_park"))
        } else if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magenta
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

