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
    @Published private(set) var annotationItems: [EventData] = []
    @Published var isLoading = false
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
            region = MapCameraPosition.region(MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)))
        default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }

    func getEvents() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.annotationItems = [EventData.MapPreviewData, EventData.MapPreviewData2]
            self?.isLoading = false
        }
    }

    func getLocation() {
        locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.first?.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
