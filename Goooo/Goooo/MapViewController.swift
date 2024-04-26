//
//  MapViewController.swift
//  Goooo
//
//  Created by Anisim on 24.04.2024.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаем экземпляр карты и устанавливаем его на весь экран
        let mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        
        // Устанавливаем начальную точку отображения карты (например, центр Москвы)
        let initialLocation = CLLocation(latitude: 55.7558, longitude: 37.6173)
        let regionRadius: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
