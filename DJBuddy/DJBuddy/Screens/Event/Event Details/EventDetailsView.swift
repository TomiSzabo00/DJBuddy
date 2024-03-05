//
//  EventDetailsView.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 03/03/2024.
//

import SwiftUI
import MapKit

struct EventDetailsView: View {
    @EnvironmentObject private var navigator: Navigator
    @EnvironmentObject private var user: UserData

    @StateObject private var viewModel = EventDetailsViewModel()

    let event: EventData
    let isJoined: Bool
    @State private var isShareShowing = false

    private let dateFormatter = DateComponentsFormatter()

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(event.name)
                        .font(.largeTitle)
                    Spacer()
                    Label("\(viewModel.numberOfJoined)", systemImage: "person.3.fill")
                }
                Text("by")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                DJRow(dj: event.dj, isLiked: user.isDj ? .constant(nil) : $viewModel.isDJLiked) {
                    viewModel.toggleLike(on: event.dj, by: user)
                }
            }

            AddressRow(address: event.location)

            Map(position: .constant(MapCameraPosition.region(region))) {
                Marker(coordinate: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude)) {
                    Label(event.name, systemImage: "headphones")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            .clipShape(.rect(cornerRadius: 12))
            .disabled(true)

            if let timeUntil = dateFormatter.string(from: event.date.timeIntervalSinceNow) {
                if timeUntil.starts(with: "-") {
                    Text(timeUntil.dropFirst() + " ago.")
                } else {
                    Text(timeUntil + " until event.")
                }
            }

            Spacer()

            buttonContent()
        }
        .foregroundStyle(.white)
        .padding(20)
        .backgroundColor(.background)
        .navBarWithTitle(title: "Event details", navigator: navigator, leadingButton: .back, trailingButton: .share($isShareShowing))
        .sheet(isPresented: $isShareShowing) {
            NavigationView {
                ShareEventView(code: event.code, isShowing: $isShareShowing)
            }
        }
        .loadingOverlay(isLoading: $viewModel.isLoading)
        .errorAlert(error: $viewModel.error)
        .onAppear {
            viewModel.isJoined = isJoined
            viewModel.getNumberOfJoined(to: event)
            viewModel.getLikeStatus(on: event.dj, by: user)

            dateFormatter.allowedUnits = [.day]
            dateFormatter.unitsStyle = .full
        }
        .animation(.default, value: viewModel.isJoined)
    }

    @ViewBuilder private func buttonContent() -> some View {
        VStack(spacing: 20) {
            if user.isDj {
                Button("Manage songs") {
                    navigator.navigate(to: .eventControl(event))
                }
                .buttonStyle(.largeProminent)

                Button("Delete event") {
                    // TODO: delete event
                }
                .buttonStyle(.largeSecondary)
            } else {
                if viewModel.isJoined {
                    Button("Request songs") {
                        navigator.navigate(to: .requestSong(event))
                    }
                    .buttonStyle(.largeProminent)

                    Button("Leave event") {
                        viewModel.leave(event: event, user: user)
                    }
                    .buttonStyle(.largeSecondary)
                } else {
                    Button("Join event") {
                        viewModel.join(event: event, user: user)
                    }
                    .buttonStyle(.largeProminent)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        EventDetailsView(event: EventData.PreviewData, isJoined: true)
            .environmentObject(Navigator())
            .environmentObject(UserData.PreviewUser)
    }
}
