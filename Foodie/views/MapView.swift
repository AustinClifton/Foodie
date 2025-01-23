import SwiftUI
import MapKit

struct MapView: View {
    //shared managers
    @EnvironmentObject var CLM: CurrentLocationManager
    @StateObject private var yelpHandler = YelpHandler()
    
    //state properties
    @State private var filters: [String] = []
    @State private var setSearchRadius: Int = 1 //for display purposes only
    @State private var chosenSearchRadius: Int = 1
    @State private var isLoading = false
    @State private var totalLocations = 0
    @State private var searchResults: [Restaurant] = []
    @State private var selectedSearchLogic: SearchLogic = .anyFiltersApply
    
    //map-related state
    @State private var selectedResult: Restaurant? //represents the marker clicked on by the user
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        ZStack {
            //map
            Map(position: $position, selection: $selectedResult) {
                UserAnnotation()
                
                ForEach(searchResults, id: \.self) { result in
                    let item = createMKMapItem(from: result)
                    Marker(item: item)
                        .mapItemDetailSelectionAccessory(.sheet)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass()
            }
            //change camera position when new markers load in
            .onChange(of: searchResults) { oldValue, newValue in
                position = .automatic //requires Restaurant to conform to Equatable
            }

            //radius distance + result count box
            VStack {
                HStack {
                    Text("Radius: \(setSearchRadius) miles\nResults: \(searchResults.count)")
                        .padding(10)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 5)
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            //map scroll view
            MapScrollView(
                filters: $filters,
                setSearchRadius: $setSearchRadius,
                chosenSearchRadius: $chosenSearchRadius,
                isLoading: $isLoading,
                totalLocations: $totalLocations,
                selectedSearchLogic: $selectedSearchLogic,
                finalizeSearchAction: finalizeSearch
            )
        }
    }

    //finalize search function
    private func finalizeSearch() {
        guard let userCoordinates = CLM.userCL2DCoord else { return }
        isLoading = true
        setSearchRadius = chosenSearchRadius
        
        //trigger the search
        yelpHandler.search(
            filters: filters,
            coordinates: userCoordinates,
            radius: setSearchRadius,
            searchLogic: selectedSearchLogic
        ) { results, error in
            isLoading = false
            if let results = results {
                searchResults = results //update the map with results
            } else if let error = error {
                print("Error fetching results: \(error.localizedDescription)")
            }
        }
    }
    
    //helper function to create an MKMapItem with detailed info
    private func createMKMapItem(from restaurant: Restaurant) -> MKMapItem {
        let placemark = MKPlacemark(
            coordinate: CLLocationCoordinate2D(
                latitude: restaurant.latitude!,
                longitude: restaurant.longitude!
            )
        )
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = restaurant.name
        mapItem.phoneNumber = restaurant.phoneNumber
        return mapItem
    }
}
