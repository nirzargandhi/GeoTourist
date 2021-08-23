//
//  GeoFencingManager.swift
//  UmpHire
//
//  Created by dharmesh on 23/08/18.
//  Copyright © 2018 Zaptech. All rights reserved.
//

protocol GeoFenceManagerDelegate {
    func updateMap()
}

class GeoFenceManager : NSObject {
    
    //MARK: - Variable Declaration
    static let sharedInstance : GeoFenceManager = {
        let instance = GeoFenceManager()
        return instance
    }()
    var delegate : GeoFenceManagerDelegate?
    let objLocationManager = CLLocationManager()
    
    private override init() {
        super.init()
    }
    
    //MARK: - Check Location Permision Method
    func checkLocationPermision() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
            
            case .notDetermined:
                getUserLocation()
                
            case .authorizedWhenInUse:
                showLocationPermissionAlert(isNotAuthorizedAlways: true)
                
            case.authorizedAlways:
                objLocationManager.delegate = self
                objLocationManager.startUpdatingLocation()
                
            case .denied, .restricted:
                showLocationPermissionAlert()
                
            @unknown default:
                break
            }
        } else {
            getUserLocation()
        }
    }
    
    //MARK: - Get User Location Method
    func getUserLocation() {
        
        objLocationManager.delegate = self
        objLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        objLocationManager.distanceFilter = kCLDistanceFilterNone
        objLocationManager.activityType = .other
        
        objLocationManager.requestAlwaysAuthorization()
        objLocationManager.requestWhenInUseAuthorization()
        
        objLocationManager.allowsBackgroundLocationUpdates = true
        objLocationManager.showsBackgroundLocationIndicator = true
        objLocationManager.pausesLocationUpdatesAutomatically = false
        
        objLocationManager.startUpdatingLocation()
        objLocationManager.startMonitoringSignificantLocationChanges()
    }
    
    //MARK: - Show Location Permission Alert Method
    func showLocationPermissionAlert(isNotAuthorizedAlways : Bool = false) {
        let alertController = UIAlertController(title: isNotAuthorizedAlways ? "Always Authorize Location" : "Location Permission Required", message: isNotAuthorizedAlways ? "We require \"Always\" permission for fetching location in background mode" : "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "Open Settings", style: .default, handler: {(cAlertAction) in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        
        alertController.addAction(okAction)
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - Stop Location Method
    func stopLoaction() {
        objLocationManager.stopUpdatingLocation()
    }
}

//MARK: - CLLocationManagerDelegate Extension
extension GeoFenceManager : CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch CLLocationManager.authorizationStatus() {
            
            case .notDetermined:
                getUserLocation()
                
            case .authorizedWhenInUse:
                showLocationPermissionAlert(isNotAuthorizedAlways: true)
                
            case.authorizedAlways:
                objLocationManager.delegate = self
                objLocationManager.startUpdatingLocation()
                
            case .denied, .restricted:
                showLocationPermissionAlert()
                
            @unknown default:
                break
            }
        } else {
            getUserLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        objCurrentLocation = locValue
        
        delegate?.updateMap()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}