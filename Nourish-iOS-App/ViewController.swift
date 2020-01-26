//
//  ViewController.swift
//  Nourish
//
//  Created by user on 1/26/20.
//  Copyright © 2020 Abdel Rahman Ellithy. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
struct place {
    var name : String
    var timeOpen : String
    var phoneNumber : String
    var latitude : Double
    var longitude : Double
    
    var location: CLLocation {
        return CLLocation(latitude: self.latitude, longitude: self.longitude)
    }

    func distance(to location: CLLocation) -> CLLocationDistance {
        return location.distance(from: self.location)
    }
}

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults : [place] = []
    let searchController = UISearchController(searchResultsController: nil)
    var searchBarIsEmpty = true
    var selectedPlace = place(name: "", timeOpen: "", phoneNumber: "", latitude: 0, longitude: 0)
    var foodPlaces : [place] = []

    var phoneNumbers = [String : String]()
    var distancesToUser = [String : Double]()
    var locationManager = CLLocationManager()
    let regionRadius: CLLocationDistance = 2000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GetPlaces()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true

        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar

        // Don't hide the navigation bar because the search bar is in it.
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone
        userLocation()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        tableView.register(UINib(nibName: "PlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "placeCell")
        tableView.rowHeight = 60
    }

    func userLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.showsUserLocation = true
            if let userLocation = locationManager.location {
                centerMapOnLocation(location: userLocation)
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
        }

    }
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: -MapView Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Place"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if (annotation.isKind(of: MKUserLocation.self)){
            return nil
        }
        if annotationView == nil {
            
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            let btn = UIButton(type: .detailDisclosure)
            btn.tintColor = UIColor(named: "BlueColor")
            annotationView!.rightCalloutAccessoryView = btn
        } else {
            annotationView!.annotation = annotation
        }
        let subtitleView = UILabel()
        subtitleView.font = subtitleView.font.withSize(13)
        subtitleView.numberOfLines = 0
        subtitleView.text = annotation.subtitle!
        
        annotationView?.detailCalloutAccessoryView = subtitleView
        annotationView?.displayPriority = .required
        return annotationView
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let title : String = ((view.annotation?.title)!)!
        let message : String = ((view.annotation?.subtitle)!)!
        
        let phoneNumber = phoneNumbers[title]!
        
        let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)

        let callAction = UIAlertAction(title: "Call", style: .default) { (action: UIAlertAction) in
            let url: NSURL = URL(string: "TEL://\(phoneNumber)")! as NSURL
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
        
        let getDirections = UIAlertAction(title: "Get Directions", style: .default) { (action: UIAlertAction) in
            let latitude = Double((view.annotation?.coordinate.latitude)!)
            let longitude = Double((view.annotation?.coordinate.longitude)!)
            
            let googleMapsInstalled = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
            if googleMapsInstalled {
                UIApplication.shared.open(URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=walking&zoom=17")!)
            } else {
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.openInMaps(launchOptions: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        deleteAlert.addAction(callAction)
        deleteAlert.addAction(getDirections)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    // MARK: -TableView Methods
    
    func getSortedLocations(userLocation: CLLocation) -> [place] {
        return foodPlaces.sorted { (l1, l2) -> Bool in
            distancesToUser[l1.name] = l1.distance(to: userLocation)
            distancesToUser[l2.name] = l2.distance(to: userLocation)
            return l1.distance(to: userLocation) < l2.distance(to: userLocation)
        }
    }
}

extension ViewController {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5) {
            self.tableView.alpha = 1.0
            self.mapView.alpha = 0.0
        }
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.5) {
            self.tableView.alpha = 0.0
            self.mapView.alpha = 1.0
        }
    }
    
    
    func filterContent(for searchText: String) {
        // Update the searchResults array with matches
        // in our entries based on the title value.
        searchResults = foodPlaces.filter({ place -> Bool in
            let match = place.name.range(of: searchText, options: .caseInsensitive)
            // Return the tuple if the range contains a match.
            return match != nil
        })
    }

    // MARK: - UISearchResultsUpdating method
    
    func updateSearchResults(for searchController: UISearchController) {
        // If the search bar contains text, filter our data with the string
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            
            searchBarIsEmpty = searchText.isEmpty ? true : false
            
            tableView.reloadData()
        }
    }
    
}

extension ViewController {
    func GetPlaces() {
        Firestore.firestore().collection("places").getDocuments { (snapshot, error) in
            if let error = error {
                print("ERROR getting documents: \(error)")
            } else {
                for document in snapshot!.documents {
                    let data = document.data()
                    
                    if ((data["name"] != nil) &&
                        (data["longitude"] != nil) &&
                        (data["latitude"] != nil) &&
                        (data["phoneNumber"] != nil) &&
                        (data["hours"] != nil)) {
                        let name = data["name"] as! String
                        let longitude = data["longitude"] as! Double
                        let latitude = data["latitude"] as! Double
                        let phoneNumber = data["phoneNumber"] as! String
                        let hours = data["hours"] as! String
                        
                        let foodPlace = place(name: name, timeOpen: hours, phoneNumber: phoneNumber, latitude: latitude, longitude: longitude)
                        
                        self.foodPlaces.append(foodPlace)
                    }
                    
                }
            }
//            self.foodPlaces.sort(by: { $0.distance(to: self.locationManager.location!) < $1.distance(to: self.locationManager.location!) })
            self.foodPlaces = self.getSortedLocations(userLocation: self.locationManager.location!)
            
            self.tableView.reloadData()

            for place in self.foodPlaces {
                let annotation = MKPointAnnotation()
                annotation.title = place.name
                annotation.subtitle = place.timeOpen
                
                self.phoneNumbers[place.name] = place.phoneNumber
                annotation.coordinate = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
                
                self.mapView.addAnnotation(annotation)
            }
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (!searchBarIsEmpty && searchController.isActive) ? searchResults.count : foodPlaces.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place = (!searchBarIsEmpty && searchController.isActive) ?
                    searchResults[indexPath.row] : foodPlaces[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeCell", for: indexPath) as! PlaceTableViewCell
        cell.closest.text = "\(round(10.0 * (distancesToUser[place.name]! / 10000)))"
        cell.title.text = place.name
        cell.hours.text = place.timeOpen
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = (!searchBarIsEmpty && searchController.isActive) ?
        searchResults[indexPath.row] : foodPlaces[indexPath.row]

        let title : String = selectedPlace.name
        let message : String = selectedPlace.timeOpen
        
        let phoneNumber = phoneNumbers[title]!
        
        let deleteAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.actionSheet)

        let callAction = UIAlertAction(title: "Call", style: .default) { (action: UIAlertAction) in
            let url: NSURL = URL(string: "TEL://\(phoneNumber)")! as NSURL
            self.searchController.dismiss(animated: true, completion: nil)
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            
        }
        
        let getDirections = UIAlertAction(title: "Get Directions", style: .default) { (action: UIAlertAction) in
            let latitude = self.selectedPlace.latitude
            let longitude = self.selectedPlace.longitude
            
            let googleMapsInstalled = UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
            if googleMapsInstalled {
                UIApplication.shared.open(URL(string: "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=walking&zoom=17")!)
            } else {
                let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.openInMaps(launchOptions: nil)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        deleteAlert.addAction(callAction)
        deleteAlert.addAction(getDirections)
        deleteAlert.addAction(cancelAction)
        self.present(deleteAlert, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        
    }

}
