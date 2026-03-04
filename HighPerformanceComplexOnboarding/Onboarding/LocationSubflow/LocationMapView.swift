//
//  LocationMapView.swift
//  HighPerformanceComplexOnboarding
//

import SwiftUI
import MapKit
import CoreLocation

struct LocationMapView: View {
    @Bindable var coordinator: LocationSubflowCoordinator
    let onConfirm: () -> Void
    let onBack: () -> Void

    @State private var position: MapCameraPosition = .automatic
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var placeName: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Map(position: $position, interactionModes: .all) {
                UserAnnotation()
                if let coord = selectedCoordinate ?? coordinator.selectedCoordinate {
                    Annotation(placeName.isEmpty ? "Picked" : placeName, coordinate: coord) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }
            }
            .mapStyle(.standard)
            .mapControls {
                MapUserLocationButton()
            }
            .overlay(alignment: .bottom) {
                Text("Use the button below to pin your current location, or pan and zoom to choose a place.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }

            VStack(spacing: 16) {
                Button {
                    if let coord = coordinator.currentLocation {
                        selectedCoordinate = coord
                        coordinator.selectedCoordinate = coord
                        position = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
                    }
                } label: {
                    Label("Use my location", systemImage: "location.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.bordered)
                .disabled(coordinator.currentLocation == nil)

                Button(action: onConfirm) {
                    Text("Confirm Location")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .disabled((selectedCoordinate ?? coordinator.selectedCoordinate) == nil)

                Button(action: onBack) {
                    Text("Back")
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .onAppear {
            if let coord = coordinator.selectedCoordinate {
                selectedCoordinate = coord
                position = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
            } else {
                position = .automatic
            }
        }
    }
}
