import SwiftUI
import MapKit

struct RouletteResultView: View {
    //shared managers
    @EnvironmentObject var CLM: CurrentLocationManager
    @EnvironmentObject var handler: YelpHandler

    //binding properties
    @Binding var filters: [String]
    @Binding var radius: Int
    @Binding var selectedSearchLogic: SearchLogic
    
    //state properties
    @State private var totalLocations = 0
    @State private var randomRestaurant: Restaurant?
    @State private var possibleOptions: Int = -1
    @State private var showRestaurant: Bool = false
    
    var body: some View {
//        //capsule (visual aesthetic only)
//        if showRestaurant && possibleOptions > 0 {
//            Capsule()
//                .frame(width: 40, height: 6)
//                .foregroundColor(.gray)
//                .padding(.top, 2)
//                .frame(maxWidth: .infinity, alignment: .center)
//        }
    
        VStack {
            //selected filters section
            VStack {
                
                //title
                Text("Search for food spots")
                    .font(.headline)
                
                //search radius
                Text("Search Radius: \(Int(radius)) miles")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                //search logic
                Text("Search Logic: \(selectedSearchLogic == .allFiltersApply ? "All Filters" : selectedSearchLogic == .anyFiltersApply ? "Any Filters" : "Default Text")")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                //filters
                Text("Filters: \(filters.joined(separator: ", "))")
                    .font(.headline)
                    .foregroundColor(.blue)

                //possible options count
                if possibleOptions >= 0 {
                    Text("Possible Options: \(possibleOptions)")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            .padding()

            //display the random restaurant
            VStack {
                if showRestaurant {
                    if possibleOptions > 0, let restaurant = randomRestaurant {
                        //restaurant card
                        CardView(restaurant: restaurant)
                    } else {
                        Text("No restaurants found.")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }//VStack

            //'FIND A RESTAURANT' button to trigger search
            Button(action: {
                withAnimation {
                    showRestaurant = false
                    totalLocations = 0

                    //start search with YelpHandler
                    handler.search(filters: filters, coordinates: CLM.userCL2DCoord!, radius: radius, searchLogic: selectedSearchLogic) { _, _ in
                        
                        //update the UI after search
                        DispatchQueue.main.async {
                            let results = handler.searchResults
                            totalLocations = results.count

                            if totalLocations > 0 {
                                randomRestaurant = results.randomElement()
                                possibleOptions = results.count
                            } else {
                                randomRestaurant = nil
                                possibleOptions = 0
                            }
                            showRestaurant = true
                        }
                    }
                }
            }) {
                HStack {
                    Text("FIND A RESTAURANT")
                        .font(.custom("PlayfairDisplay-VariableFont_wght", size: 22))
                        .frame(maxWidth: .infinity)
                        .padding() //gives the button height
                        .foregroundColor(.black)
                        .background(Color(customYellow))
                        .cornerRadius(16)
                }
                .padding(.horizontal)
            }
        }//VStack
    }
}
