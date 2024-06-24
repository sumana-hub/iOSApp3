import UIKit
import CoreLocation
import MapKit

// ViewController class which handles location services and updates the UI accordingly
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Variable to keep track if an alert is presented to prevent multiple alerts
    var isAlertPresented = false
    
    // CLLocationManager instance to manage location services
    let locationManager = CLLocationManager()
    
    // IBOutlets for UI elements
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var markGeocacheLocation: UIButton!
    
    // viewDidLoad is called after the view has been loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate for locationManager
        locationManager.delegate = self
        
        // Request location access permission from the user
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating location
        locationManager.startUpdatingLocation()
        
        // Set the desired accuracy for location updates
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Set the distance filter to get location updates regardless of distance change
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    // Delegate method called when new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Get the latitude and longitude from the location
            let coordinates = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
            coordinatesLabel.text = coordinates
            
            // Reverse geocode to get address from coordinates
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    // Handle error in reverse geocoding
                    self.addressLabel.text = "Error: \(error.localizedDescription)"
                    return
                }
                
                if let placemark = placemarks?.first {
                    // Construct the address string from the placemark
                    let address = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                    self.addressLabel.text = address
                }
            }
        }
    }
    
    // Delegate method called when location updates fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                // Handle location unknown error
                print("Location services are temporarily unavailable.")
                showErrorAlert(message: "Location services are temporarily unavailable. Please try again later.")
            case .denied:
                // Handle location access denied error
                print("Location access has been denied by the user.")
                showErrorAlert(message: "Location access has been denied. Please enable location services for this app in Settings.")
            default:
                // Handle other location errors
                print("Failed to find user's location: \(error.localizedDescription)")
                showErrorAlert(message: "Failed to find user's location: \(error.localizedDescription)")
            }
        } else {
            // Handle non-location errors
            print("Failed to find user's location: \(error.localizedDescription)")
            showErrorAlert(message: "Failed to find user's location: \(error.localizedDescription)")
        }
    }
    
    // Function to show an error alert
    func showErrorAlert(message: String) {
        guard !isAlertPresented else {
            return
        }
        
        isAlertPresented = true
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.isAlertPresented = false
        })
        self.present(alert, animated: true, completion: nil)
    }

    // Action method called when the "Mark Geocache Location" button is tapped
    @IBAction func markGeocacheLocation(_ sender: UIButton) {
        if let text = coordinatesLabel.text, !text.isEmpty {
            // Print the geocache location coordinates
            print("Marked Geocache Location: \(text)")
            // Code to mark the geocache location, e.g., save to a list or database
        } else {
            // Show an error alert if no location data is available
            showErrorAlert(message: "No location data available to mark.")
        }
    }
}

