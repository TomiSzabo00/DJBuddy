//
//  MapView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel = MapViewModel()
    
    var body: some View {
        Map(position: $viewModel.region) {
            ForEach(viewModel.annotationItems) { event in
                Annotation("", coordinate: event.location.coordinate) {
                    EventAnnotation(event: event)
                }
            }
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .all))
        .mapControls {
            MapCompass()
            MapPitchToggle()
            MapScaleView()
        }
        .mapControlVisibility(.visible)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            viewModel.checkLocationServices()
        }
    }
}

#Preview {
    MapView()
}
