//
//  AddressResult.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import Foundation
import MapKit

struct AddressResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(title: String, subtitle: String, latitude: Double = 0, longitude: Double = 0) {
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
    }

    init(address: AddressResult, latitude: Double, longitude: Double) {
        self.title = address.title
        self.subtitle = address.subtitle
        self.latitude = latitude
        self.longitude = longitude
    }

    static var PreviewData: AddressResult {
        AddressResult(title: "Place name", subtitle: "Road name 123, Hungary")
    }

    static var MapPreviewData: AddressResult {
        AddressResult(title: "Stifler Bar", subtitle: "Budapest, Erzsébet krt. 19, 1073", latitude: 47.500031, longitude: 19.069441)
    }

    static var MapPreviewData2: AddressResult {
        AddressResult(title: "Akvarium Klub", subtitle: "Budapest, Erzsébet tér 12, 1051", latitude: 47.498058, longitude: 19.054211)
    }
}
