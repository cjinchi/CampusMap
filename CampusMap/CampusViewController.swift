//
//  CampusViewController.swift
//  CampusMap
//
//  Created by Chun on 2018/11/26.
//  Copyright © 2018 Nemoworks. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts


class CampusViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var campus = Campus(filename: "Campus")
    var selectedOptions : [MapOptionsType] = []
    
    //My work
    let locationManager = CLLocationManager()
    var btvc2 :BottomSheetViewController? = nil
    var dst:GotoButton? = nil
    var route:MKPolyline? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latDelta = campus.overlayTopLeftCoordinate.latitude - campus.overlayBottomRightCoordinate.latitude
        
        // Think of a span as a tv size, measure from one corner to another
        let span = MKCoordinateSpan.init(latitudeDelta: fabs(latDelta), longitudeDelta: 0.0)
        let region = MKCoordinateRegion.init(center: campus.midCoordinate, span: span)
        
        mapView.region = region
        
        
        //My work
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.startUpdatingLocation()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? MapOptionsViewController)?.selectedOptions = selectedOptions
    }
    
    // MARK: Helper methods
    func loadSelectedOptions() {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        for option in selectedOptions {
            switch (option) {
            case .mapBoundary:
                self.addBoundary()
            default:
                self.addPOIs(type: option)
            }
        }
    }
    
    
    @IBAction func closeOptions(_ exitSegue: UIStoryboardSegue) {
        guard let vc = exitSegue.source as? MapOptionsViewController else { return }
        selectedOptions = vc.selectedOptions
        loadSelectedOptions()
    }
    
    
    func addBoundary() {
        mapView.addOverlay(MKPolygon(coordinates: campus.boundary, count: campus.boundary.count))
    }
    
    func addPOIs(type:MapOptionsType) {
        guard let pois = Campus.plist("CampusPOI") as? [[String : String]] else { return }
        
        for poi in pois {
            let typeRawValue = Int(poi["type"] ?? "0") ?? 0
            let type2 = MapOptionsType(rawValue: typeRawValue) ?? .mapBoundary
            if type2 != type{
                continue
            }
            let coordinate = Campus.parseCoord(dict: poi, fieldName: "location")
            let title = poi["name"] ?? ""
            let subtitle = poi["subtitle"] ?? ""
            let annotation = POIAnnotation(coordinate: coordinate, title: title, subtitle: subtitle, type: type)
            mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    //My work begins here
    public func removeRoute(){
        if let route = route {
            mapView.removeOverlay(route as MKOverlay)
            self.route = nil
        }
    }
    
    public func reload(){
        if let dst = dst{
            goto(sender: dst)
            print("reload")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let btvc2 = btvc2{
            btvc2.view.isHidden = true
        }
    }
    
    @IBAction func goto(sender:GotoButton){
        removeRoute()
        
        if let myLocation = myLocation{
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: myLocation.coordinate))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: sender.coordinate))
            request.requestsAlternateRoutes = false
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            
            directions.calculate(){res,err in
                if err != nil{
                    print("get direction error")
                }else if let res = res{
                    self.btvc2?.view.isHidden = false
                    for route in res.routes{
                        self.route = route.polyline
                        self.mapView.addOverlay(route.polyline)
                        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        var navText = "全程\(route.distance)米：\n";
                        for (index,step) in route.steps.enumerated(){
                            navText += "\(index+1)、\(step.instructions)，直走\(step.distance)米。\n"
                            print(step.distance)
                            print(step.instructions)
                        }
                        if let btvc2 = self.btvc2{
                            btvc2.setNavText(text: navText)
                        }
                    }
                }else{
                    print("unknown error")
                }
                
            }
        }else{
            print("can't get src")
        }
    }
    
    
    
    var myLocation:CLLocation? = nil
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation = manager.location!
    }
    
}


// MARK: - MKMapViewDelegate
extension CampusViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = UIColor.green
            lineView.lineWidth = 6.0
            return lineView
        } else if overlay is MKPolygon {
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.blue
            polygonView.lineWidth = CGFloat(3.0)
            return polygonView
        }
        
        return MKOverlayRenderer()
    }
    
    //My work begins here
    class GotoButton:UIButton{
        var coordinate:CLLocationCoordinate2D
        init(frame: CGRect,coordinate:CLLocationCoordinate2D) {
            self.coordinate = coordinate
            super.init(frame:.zero)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = POIAnnotationView(annotation: annotation, reuseIdentifier: "POI")
        annotationView.canShowCallout = true
        let button = GotoButton(frame: CGRect(x: 0, y: 0, width: 80, height: 50), coordinate: annotationView.coordinate!)
        button.setTitle("去这里", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 80, height: 50)
        button.addTarget(self, action:#selector(CampusViewController.goto), for:.touchDown)
        annotationView.rightCalloutAccessoryView = button
        return annotationView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let btvc = BottomSheetViewController(self)
        btvc2 = btvc
        self.addChild(btvc)
        self.view.addSubview(btvc.view)
        btvc.didMove(toParent: self)
        
        btvc.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: view.frame.height, height: view.frame.width)
        
        btvc.view.isHidden = true
    }

}
