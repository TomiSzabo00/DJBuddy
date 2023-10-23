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
            region = MapCameraPosition.region(MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
