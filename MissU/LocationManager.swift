//
//  LocationManager.swift
//  MissU
//
//  Created by Robert Zhao on 2025-12-22.
//

import Foundation
import CoreLocation
import Combine

/* location manager used to retrieve current location. Can be reused in the future */
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let manager = CLLocationManager()

    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    // successfully retrieve the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    // error occured
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败:", error)
    }
}
