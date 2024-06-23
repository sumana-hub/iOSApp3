import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var isAlertPresented = false
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var markGeocacheLocation: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coordinates = "Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)"
            coordinatesLabel.text = coordinates
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                if let error = error {
                    self.addressLabel.text = "Error: \(error.localizedDescription)"
                    return
                }
                
                if let placemark = placemarks?.first {
                    let address = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
                    self.addressLabel.text = address
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location services are temporarily unavailable.")
                showErrorAlert(message: "Location services are temporarily unavailable. Please try again later.")
            case .denied:
                print("Location access has been denied by the user.")
                showErrorAlert(message: "Location access has been denied. Please enable location services for this app in Settings.")
            default:
                print("Failed to find user's location: \(error.localizedDescription)")
                showErrorAlert(message: "Failed to find user's location: \(error.localizedDescription)")
            }
        } else {
            print("Failed to find user's location: \(error.localizedDescription)")
            showErrorAlert(message: "Failed to find user's location: \(error.localizedDescription)")
        }
    }

    
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

    @IBAction func markGeocacheLocation(_ sender: UIButton) {
        if let text = coordinatesLabel.text, !text.isEmpty {
            print("Marked Geocache Location: \(text)")
            // Code to mark the geocache location, e.g., save to a list or database
        } else {
            showErrorAlert(message: "No location data available to mark.")
        }
    }
}

