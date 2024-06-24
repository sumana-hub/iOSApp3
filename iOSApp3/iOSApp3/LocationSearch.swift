import UIKit
import CoreLocation
import MapKit

// LocationSearch class handles location search functionality with map view and search text field
class LocationSearch: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // IBOutlets for UI elements
    @IBOutlet weak var locationSearchTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    // viewDidLoad is called after the view has been loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate for mapView and locationSearchTextField
        mapView.delegate = self
        locationSearchTextField.delegate = self
    }

    // Action method called when the user inputs a location and presses return
    @IBAction func searchLocation(_ sender: UITextField) {
        // Ensure the search text field is not empty
        guard let locationString = sender.text, !locationString.isEmpty else {
            return
        }

        // Use CLGeocoder to convert the address string into coordinates
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationString) { (placemarks, error) in
            if let error = error {
                // Handle geocoding error
                self.showErrorAlert(message: "Failed to find location: \(error.localizedDescription)")
                return
            }

            // Ensure a valid placemark and location were found
            guard let placemark = placemarks?.first, let location = placemark.location else {
                self.showErrorAlert(message: "Location not found.")
                return
            }

            // Construct coordinate and address strings
            let coordinates = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
            let address = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
            
            // Set the map region to the found location
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)

            // Create and add an annotation to the map view
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = address
            self.mapView.addAnnotation(annotation)
        }
    }

    // UITextFieldDelegate method called when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismiss the keyboard
        textField.resignFirstResponder()
        
        // Trigger the searchLocation method
        searchLocation(textField)
        return true
    }

    // Function to show an error alert
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

