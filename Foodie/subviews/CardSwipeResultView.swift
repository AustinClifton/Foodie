import SwiftUI
import MapKit

struct CardSwipeResultView: View {
    //shared managers
    @EnvironmentObject var CLM: CurrentLocationManager
    @EnvironmentObject var handler: YelpHandler

    //binding properties
    @Binding var filters: [String]
    @Binding var radius: Int
    @Binding var selectedSearchLogic: SearchLogic
    @Binding var showResultSheet: Bool

    //state properties
    @State private var totalLocations = 0
    @State private var showCards: Bool = false
    @State private var possibleOptions: Int = 0
    @State private var restaurants: [Restaurant] = []
    
    var body: some View {
//        //capsule (visual aesthetic only)
//        if showCards && possibleOptions > 0 {
//            Capsule()
//                .frame(width: 40, height: 6)
//                .foregroundColor(.gray)
//                .padding(.top, 8)
//                .frame(maxWidth: .infinity, alignment: .center)
//            
//            Spacer()
//        }
        
        VStack {
            //selected filters section
            VStack {
                if showCards { Spacer() }
                
                //title
                Text("Search for food spots with:")
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

            //display swipeable cards if restaurants are available
            VStack {
                if showCards {
                    if possibleOptions > 0 {
                        VStack(alignment: .center) {
                            CardSwipeCards(restaurants: restaurants, showResultSheet: $showResultSheet)
                        }
                        .padding()
                    } else {
                        Text("No restaurants found.")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }//VStack

            //'SHUFFLE CARDS' button to trigger search
            if !showCards {
                Button(action: {
                    withAnimation {
                        handler.search(filters: filters, coordinates: CLM.userCL2DCoord!, radius: radius, searchLogic: selectedSearchLogic) { _, _ in
                            DispatchQueue.main.async {
                                let results = handler.searchResults
                                totalLocations = results.count

                                if totalLocations > 0 {
                                    restaurants = results.shuffled()
                                    possibleOptions = results.count
                                } else {
                                    restaurants = []
                                    possibleOptions = 0
                                }
                                showCards = true
                            }
                        }
                    }
                }) { HStack {
                    Text("SHUFFLE CARDS")
                        .font(.custom("ChakraPetch-Bold", size: 22))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }//Button
            }//if
            
            if showCards && possibleOptions > 0 { Spacer() }
        }//VStack
    }//VStack
}//body
