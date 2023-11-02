//
//  MapView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 23/10/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject var viewModel: MapViewModel
    
    @Binding var isLoading: Bool
    @State var annotationItems: [EventData]
    let fetchEvents: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            Map(position: $viewModel.region) {
                ForEach(annotationItems) { event in
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

            Button {
                fetchEvents()
            } label: {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                .padding(12)
                .background(.thickMaterial)
                .clipShape(.rect(cornerRadius: 12))
            }
            .padding(8)
            .padding(.top, 40)
            .disabled(isLoading)
        }
    }
}

#Preview {
    MapView(viewModel: MapViewModel(), isLoading: .constant(false), annotationItems: []) {}
}
