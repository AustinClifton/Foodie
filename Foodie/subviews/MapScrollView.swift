import SwiftUI
import MapKit

struct MapScrollView: View {
    //shared managers
    @EnvironmentObject var CLM: CurrentLocationManager
    
    //binding properties
    @Binding var filters: [String]
    @Binding var setSearchRadius: Int
    @Binding var chosenSearchRadius: Int
    @Binding var isLoading: Bool
    @Binding var totalLocations: Int
    @Binding var selectedSearchLogic: SearchLogic

    //callback for finalizing search
    var finalizeSearchAction: () -> Void
    
    //states for scrolling purposes
    @State private var offset: CGFloat = 650
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            VStack {
                //capsule (visual aesthetic only)
                Capsule()
                    .frame(width: 40, height: 6)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Location Filters")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 2)
                
                //scrollable container for food options
                ScrollView {
                    VStack {
                        //all food buttons
                        FoodButtonsView(filters: $filters, radius: $chosenSearchRadius, selectedSearchLogic: $selectedSearchLogic)
                        
                        Spacer(minLength: 35)
                        
                        //reset filters & finalize search buttons
                        HStack(spacing: 15) {
                            Button("Reset Filters") {
                                filters.removeAll()
                                chosenSearchRadius = 1
                            }
                            .frame(width: 170, height: 50)
                            .font(.system(size: 21, weight: .semibold))
                            .shadow(radius: 5)
                            .background(Color.red)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            
                            Button("Finalize Search") {
                                finalizeSearchAction() //call the passed action
                                offset = 650 //bring VStack back to the bottom
                            }
                            .frame(width: 170, height: 50)
                            .font(.system(size: 21, weight: .semibold))
                            .shadow(radius: 3)
                            .background(Color.green)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                        }
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 700)
            .background(Color.white)
            .cornerRadius(20)
            .offset(y: offset + dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        dragOffset = gesture.translation.height
                    }
                    .onEnded { _ in
                        if dragOffset < -50 { //dragging up
                            offset = 50
                        } else if dragOffset > 50 { //dragging down
                            offset = 650
                        }
                        dragOffset = 0
                    }
            )
            .animation(.easeInOut, value: offset)
        }
    }
}
