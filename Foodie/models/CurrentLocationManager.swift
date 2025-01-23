import MapKit
import Foundation
import CoreLocation

/**
 THE LocationManager CLASS IS DESIGNED TO MANAGE THE USER'S LOCATION UPDATES
 */
class CurrentLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var userCLManager: CLLocationManager //instance of CLLocationManager that handles the location services
    @Published var userCL2DCoord: CLLocationCoordinate2D? //stores the user's current location

    override init() {
        //for picker
        //UISegmentedControl.appearance().selectedSegmentTintColor = .white
        //UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        self.userCLManager = CLLocationManager() //create an instance of CLLocationManager
        super.init() //initialize
        self.userCLManager.delegate = self //this means that this class will handle location updates
        self.requestWhenInUseAuthorization() //request location authorization
        self.userCLManager.startUpdatingLocation() //start updating the location
    }

    //function to request location authorization
    func requestWhenInUseAuthorization() {
        self.userCLManager.requestWhenInUseAuthorization()
    }

    //function that is called when the location manager receives new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let ucl = locations.first else { return }
        self.userCL2DCoord = ucl.coordinate
    }

    //error handling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
