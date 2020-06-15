//
//  ViewController.swift
//  toVisitPlaces_Jyothi_C0775696
//
//  Created by user176475 on 6/15/20.
//  Copyright © 2020 user176475. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var destinationCoordinates : CLLocationCoordinate2D!
    let destCoordinate = MKDirections.Request()
    let button = UIButton()
    @IBOutlet weak var btnGo: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnZoomin: UIButton!
    var locationManager = CLLocationManager()
    @IBOutlet weak var segmentWay: UISegmentedControl!
    @IBOutlet weak var btnZoomotu: UIButton!
    
         var aLat: CLLocationDegrees??
         var aLon: CLLocationDegrees??
         var location: CLLocation?
         var places:[Places]?
           let defaults = UserDefaults.standard
           var lat : Double = 0.0
           var long : Double = 0.0
           var drag : Bool? = false
    override func viewDidLoad() {
                super.viewDidLoad()
                
                mapView.isZoomEnabled = false
                       mapView.delegate = self
                       locationManager.delegate = self
                       locationManager.desiredAccuracy = kCLLocationAccuracyBest
                       locationManager.requestWhenInUseAuthorization()
                       locationManager.startUpdatingLocation()
                       
                       let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
                              tap.numberOfTapsRequired = 2
                              mapView.addGestureRecognizer(tap)
                       
                       loadData()
                
          }
            func addDoubleTap()
            {
                let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
                       tap.numberOfTapsRequired = 2
                       mapView.addGestureRecognizer(tap)
            }
        
            
            func dragablePin(){
                    self.lat = defaults.double(forKey: "latitude")
                    self.long = defaults.double(forKey: "longitude")
                    
                    self.drag = defaults.bool(forKey: "bool")
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long )
                    print(lat, long)
                    mapView.addAnnotation(annotation)
                }
                
                
                
                func getDataFilePath() -> String {
                       let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                       let filePath = documentPath.appending("/places-data.txt")
                       return filePath
                   }
                
                func loadData() {
                    places = [Places]()
                    
                    let filePath = getDataFilePath()
                    
                    if FileManager.default.fileExists(atPath: filePath){
                        do{
                            //creating string of file path
                         let fileContent = try String(contentsOfFile: filePath)
                            
                            let contentArray = fileContent.components(separatedBy: "\n")
                            for content in contentArray{
                               
                                let placeContent = content.components(separatedBy: ",")
                                if placeContent.count == 6 {
                                    let place = Places(placeLat: Double(placeContent[0]) ?? 0.0, placeLong: Double(placeContent[1]) ?? 0.0, placeName: placeContent[2], city: placeContent[3], postalCode: placeContent[4], country: placeContent[5])
                                    places?.append(place)
                                }
                            }
            //                print(places?.count)
                        }
                        catch{
                            print(error)
                        }
                    }
                }
                
                 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                        if let placeListVC = segue.destination as? VisitPlacesTableViewController{
                            placeListVC.places = self.places
                        }
                    }
                
                 
                func saveData() {
                     let filePath = getDataFilePath()

                     var saveString = ""
                     for place in places!{
                        saveString = "\(saveString)\(place.placeLat),\(place.placeLong),\(place.placeName),\(place.city),\(place.country),\(place.postalCode)\n"
                         do{
                        try saveString.write(toFile: filePath, atomically: true, encoding: .utf8)
                         }
                         catch{
                             print(error)
                         }
                     }
                 }
                
                 @objc func handleTap(recognizer: UITapGestureRecognizer) {
                        
                       let mapAnnotations  = self.mapView.annotations
                       self.mapView.removeAnnotations(mapAnnotations)
                       let tapLocation = recognizer.location(in: mapView)
                        self.destinationCoordinates = mapView.convert(tapLocation, toCoordinateFrom: mapView)
                           
                           
                           if recognizer.state == .ended
                           {
                               
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = self.destinationCoordinates!
                                annotation.title = "Your selected Place"
                                self.mapView.addAnnotation(annotation)
                           }
                       }

                func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                           let userLocation = locations[0]
                           
                           let latitude = userLocation.coordinate.latitude
                           let longitude = userLocation.coordinate.longitude
                            
                           let latDelta: CLLocationDegrees = 0.05
                           let longDelta: CLLocationDegrees = 0.05
                            
                            // 3 - Creating the span, location coordinate and region
                           let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                           let customLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                           let region = MKCoordinateRegion(center: customLocation, span: span)
                                  
                            // 4 - assign region to map
                           mapView.setRegion(region, animated: true)
                        }
        
            @objc func doubleTapped(sender: UITapGestureRecognizer)
            {
               // Getting coordinate of double tapped point and adding annotation
                let locationInView = sender.location(in: mapView)
                let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
                addAnnotation(location: locationOnMap)
                getLocationInfo()
            }

            func addAnnotation(location: CLLocationCoordinate2D)
            {
                //Removing previous annotations and route
                self.mapView.removeOverlays(self.mapView.overlays)
                let oldAnnotations = self.mapView.annotations
                self.mapView.removeAnnotations(oldAnnotations)
                
                //Adding new annotation
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                aLat = annotation.coordinate.latitude
                aLon = annotation.coordinate.longitude
                annotation.title = "Your Selected Place"
                
                self.mapView.addAnnotation(annotation)
            }
                
                @IBAction func findMyWay(_ sender: Any) {
                //Calculating route
                routeMapping()
                }
        
        func enableLocationServicesAlert()
        {
            //Alert when location services are not enabled
            let alertController = UIAlertController(title: "Error", message:
            "Please enable location services in settings", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            self.present(alertController, animated: true, completion: nil)
        }
        func routeMapping()
        {
                self.mapView.removeOverlays(self.mapView.overlays)
                //Getting desination locations
            let request = MKDirections.Request()
            if(location?.coordinate.longitude == nil || location?.coordinate.latitude == nil)
            {
                enableLocationServicesAlert()
                return
            }
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!), addressDictionary: nil))
            //Handling case when no marker is placed
            
            if(aLat == nil || aLon == nil)
            {
                    let alertController = UIAlertController(title: "Error", message:
                    "No destination selected", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

                    self.present(alertController, animated: true, completion: nil)
            }
            else
            {
                    //Getting destination location
                    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: aLat as! CLLocationDegrees, longitude: aLon as! CLLocationDegrees), addressDictionary: nil))
                    request.requestsAlternateRoutes = false
            }

        }
    func geocode()  {
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: destinationCoordinates.latitude, longitude: destinationCoordinates.longitude)) {  placemark, error in
               if let error = error as? CLError {
                   print("CLError:", error)
                   return
                }
               else if let placemark = placemark?[0] {
                
                var placeName = ""
                var neighbourhood = ""
                var city = ""
                var state = ""
                var postalCode = ""
                var country = ""
                
                
                if let name = placemark.name {
                    placeName += name
                            }
                if let sublocality = placemark.subLocality {
                    neighbourhood += sublocality
                            }
                if let locality = placemark.subLocality {
                     city += locality
                            }
                if let area = placemark.administrativeArea {
                              state += area
                          }
                if let code = placemark.postalCode {
                              postalCode += code
                          }
                if let cntry = placemark.country {
                                        country += cntry
                                    }

                
                
                let place = Places(placeLat: self.destinationCoordinates.latitude, placeLong:self.destinationCoordinates.longitude, placeName: placeName, city: city, postalCode: postalCode, country: country)
              
                self.places?.append(place)
                self.saveData()
                self.navigationController?.popToRootViewController(animated: true)
                }

            }
        }        //Adding overlays
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            //Polyline style for automobile route
            if(segmentWay.selectedSegmentIndex == 0)
            {
                renderer.lineWidth = 3;
            }
            //Polyline style for the on foot route
            if(segmentWay.selectedSegmentIndex == 1)
            {
                renderer.lineWidth = 4.0
                renderer.lineDashPhase = 5
                renderer.lineDashPattern = [NSNumber(value: 1),NSNumber(value:6)]
            }
            return renderer
        }
        
            func getLocationInfo()
            {
                var location = CLLocation(latitude: aLat as! CLLocationDegrees, longitude: aLon as! CLLocationDegrees) //changed!!!
                print(location)

        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            guard error == nil else {
                print("Error! Reverse geocoder failed" + error!.localizedDescription)
                return
            }
            guard placemarks!.count > 0 else {
                print("Error in data received from geocoder")
                return
            }
            let pm = placemarks![0] as! CLPlacemark
            print(pm.locality!)
            print(pm.thoroughfare!)
            print(pm.postalCode!)
        })
            }
        
    }

    extension ViewController: MKMapViewDelegate {
             func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
                
                
                        if annotation is MKUserLocation {
                            return nil
                        }
                    
                            let pinAnnotation = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
                            pinAnnotation.markerTintColor = .blue
                            pinAnnotation.glyphTintColor = .white
                            pinAnnotation.canShowCallout = true
                            button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                            pinAnnotation.rightCalloutAccessoryView = button
                            return pinAnnotation
                
                    }
                

            func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
                 let alertController = UIAlertController(title: "Add to Favourites", message:
                    "Do you want to add to favourites?", preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Yes", style:  .default, handler: { (UIAlertAction) in
                    self.geocode()
                    
                }))
            
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(alertController, animated: true, completion: nil)
                            
            }
    }

