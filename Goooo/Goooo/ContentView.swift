import SwiftUI
import MapKit

struct Museum: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
}

struct ProfileView: View {
    @State private var username: String = ""
    @State private var bio: String = ""
    @Binding var selectedImage: Image?
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            }
            // Additional code to display other user data
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

struct MapView: UIViewRepresentable {
    let selectedMuseum: Museum
    let museums: [Museum]
    
    let mapView = MKMapView()
    var touchLocation: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        let museumAnnotation = MKPointAnnotation()
        museumAnnotation.coordinate = selectedMuseum.coordinate
        museumAnnotation.title = selectedMuseum.name
        uiView.addAnnotation(museumAnnotation)
        
        let region = MKCoordinateRegion(
            center: selectedMuseum.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        uiView.setRegion(region, animated: true)
        
        if let touchLocation = touchLocation {
            self.getDirections(from: touchLocation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let location = gestureRecognizer.location(in: parent.mapView)
            let coordinate = parent.mapView.convert(location, toCoordinateFrom: parent.mapView)
            parent.touchLocation = coordinate
            parent.getDirections(from: coordinate)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }
    
    private func getDirections(from location: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: location))
        let destinationPlacemark = MKPlacemark(coordinate: selectedMuseum.coordinate)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first, error == nil else {
                // Handle error
                return
            }
            self.mapView.addOverlay(route.polyline)
        }
    }
}

struct MuseumListView: View {
    let museums: [Museum]

    var body: some View {
        NavigationView {
            List(museums) { museum in
                NavigationLink(destination: Text("DetailView")) { // Placeholder DetailView
                    VStack(alignment: .leading) {
                        Text(museum.name)
                            .font(.headline)
                        Text(museum.address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Museums")
        }
    }
}

struct ContentView: View {
    let museums = [
        Museum(name: "Музей Мирового океана", address: "г. Калининград, набережная Петра Великого, 1 - 9", coordinate: CLLocationCoordinate2D(latitude: 54.7041, longitude: 20.5077)),
        Museum(name: "Музей янтаря", address: "г. Калининград, ул. Фрунзе, 112", coordinate: CLLocationCoordinate2D(latitude: 54.7029, longitude: 20.5154)),
        Museum(name: "Башня Дона", address: "г. Калининград, Литовский вал, 107", coordinate: CLLocationCoordinate2D(latitude: 54.7097, longitude: 20.5083))
    ]

    @State private var isAuthenticated: Bool = false
    @State private var isRegistering: Bool = false
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var selectedImage: Image? = nil
    
    var body: some View {
        TabView {
            MapView(selectedMuseum: museums[0], museums: museums)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            MuseumListView(museums: museums)
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("List")
                }
            if isAuthenticated {
                ProfileView(selectedImage: $selectedImage)
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
                    .navigationBarItems(trailing:
                        Button(action: {
                            isAuthenticated = false
                            selectedImage = nil
                        }) {
                            Text("Logout")
                        }
                    )
            } else {
                if isRegistering {
                    VStack {
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Register") {
                            // Реализация логики регистрации
                            isRegistering = false
                            isAuthenticated = true
                        }
                        .padding()
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Register")
                    }
                } else {
                    VStack {
                        TextField("Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Login") {
                            if authenticate(username: username, password: password) {
                                isAuthenticated = true
                            } else {
                                showAlert = true
                            }
                        }
                        .padding()
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Authentication Failed"), message: Text("Invalid username or password"), dismissButton: .default(Text("OK")))
                        }
                        
                        Button("Register") {
                            isRegistering = true
                        }
                        .padding()
                    }
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Login")
                    }
                }
            }
        }
    }
    
    func authenticate(username: String, password: String) -> Bool {
        // Реализуйте вашу логику аутентификации здесь
        return username == "user" && password == "password"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Image?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var selectedImage: Image?

        init(selectedImage: Binding<Image?>) {
            _selectedImage = selectedImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                selectedImage = Image(uiImage: uiImage)
            }

            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Do nothing here
    }
}
