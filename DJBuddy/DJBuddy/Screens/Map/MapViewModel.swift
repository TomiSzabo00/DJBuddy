//
//  MapViewModel.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import Foundation
import MapKit
import SwiftUI

final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: MapCameraPosition = .automatic
    @Published var currentLocation: CLLocationCoordinate2D? = nil

    var locationManager: CLLocationManager?

    func checkLocationServices() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }

    private func checkLocationAuthorization() {
        guard let locationManager else { return }

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            guard let location = locationManager.location else { break }
            region = regionFrom(coordinates: locationManager.location!.coordinate)
        default:
            break
        }
    }

    func regionFrom(coordinates: CLLocationCoordinate2D) -> MapCameraPosition {
        MapCameraPosition.region(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func getLocation() {
        if [.authorizedWhenInUse, .authorizedAlways].contains(locationManager?.authorizationStatus) {
            locationManager?.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
