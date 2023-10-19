//
//  PlacesViewControllerBridge.swift
//  DJBuddy
//
//  Created by Szabó Tamás on 19/10/2023.
//

import SwiftUI
import GooglePlaces

struct PlacesViewControllerBridge: UIViewControllerRepresentable {

    var onPlaceSelected: (GMSPlace) -> ()
    //var selectedPlaceByFilter: GMSPlace

    func makeUIViewController(context: UIViewControllerRepresentableContext<PlacesViewControllerBridge>) -> GMSAutocompleteViewController {
     let uiViewControllerPlaces = GMSAutocompleteViewController()
        uiViewControllerPlaces.delegate = context.coordinator
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) |
                                                                   UInt(GMSPlaceField.placeID.rawValue) |
                                                                   UInt(GMSPlaceField.addressComponents.rawValue) |
                                                                   UInt(GMSPlaceField.formattedAddress.rawValue)))
        uiViewControllerPlaces.placeFields = fields
        return uiViewControllerPlaces
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }

    func makeCoordinator() -> PlacesViewAutoCompleteCoordinator {
        return PlacesViewAutoCompleteCoordinator(placesViewControllerBridge: self)
    }

    final class PlacesViewAutoCompleteCoordinator: NSObject, GMSAutocompleteViewControllerDelegate {
        var placesViewControllerBridge: PlacesViewControllerBridge

        init(placesViewControllerBridge: PlacesViewControllerBridge) {
            self.placesViewControllerBridge = placesViewControllerBridge
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace)
        {
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.name.rawValue) |
                                                                       UInt(GMSPlaceField.placeID.rawValue) |
                                                                       UInt(GMSPlaceField.addressComponents.rawValue) |
                                                                       UInt(GMSPlaceField.formattedAddress.rawValue)))
            viewController.placeFields = fields
            print("Place name: \(place.name ?? "Default Place")")
            print("Place ID: \(place.placeID ?? "Default PlaceID")")
            print("Place attributions: \(place.coordinate)")
            viewController.dismiss(animated: true)
            self.placesViewControllerBridge.onPlaceSelected(place)
        }

        func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error)
        {
            print("Error: ", error.localizedDescription)
        }

        func wasCancelled(_ viewController: GMSAutocompleteViewController) {
            print("Place prediction window cancelled")
            viewController.dismiss(animated: true)
        }
    }
}
