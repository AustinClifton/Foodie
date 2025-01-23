import SwiftUI
import MapKit

enum DragState {
    case inactive
    case pressing
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive, .pressing:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .pressing, .dragging:
            return true
        case .inactive:
            return false
        }
    }
}

struct CardSwipeCards: View {
    //shared managers
    @EnvironmentObject var CLM: CurrentLocationManager
    
    @GestureState private var dragState = DragState.inactive
    private let dragThreshold: CGFloat = 30.0
    @State private var lastIndex = 1
    @State private var removalTransition = AnyTransition.trailingBottom
    
    @State private var showSheet = false
    @State private var selectedRestaurant: Restaurant? //for passing data to the sheet
    
    let restaurants: [Restaurant]
    
    @State private var cardViews: [CardView] = []
    
    @Binding var showResultSheet: Bool
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(cardViews) { cardView in
                    cardView
                        .zIndex(self.isTopCard(cardView: cardView) ? 1 : 0)
                        .overlay(
                            ZStack {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.red)
                                    .font(.system(size: 100))
                                    .opacity(self.dragState.translation.width < -self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0)
                                
                                Image(systemName: "heart.circle")
                                    .foregroundColor(.green)
                                    .font(.system(size: 100))
                                    .opacity(self.dragState.translation.width > self.dragThreshold && self.isTopCard(cardView: cardView) ? 1.0 : 0.0)
                            }
                        )
                        .offset(
                            x: self.isTopCard(cardView: cardView) ? self.dragState.translation.width : 0,
                            y: self.isTopCard(cardView: cardView) ? self.dragState.translation.height : 0
                        )
                        .scaleEffect(self.dragState.isDragging && self.isTopCard(cardView: cardView) ? 0.95 : 1.0)
                        .rotationEffect(Angle(degrees: self.isTopCard(cardView: cardView) ? Double(self.dragState.translation.width / 10) : 0))
                        .animation(.interpolatingSpring(stiffness: 180, damping: 100), value: dragState.isDragging)
                        .transition(self.removalTransition)
                        .gesture(
                            LongPressGesture(minimumDuration: 0.01)
                                .sequenced(before: DragGesture())
                                .updating(self.$dragState) { value, state, _ in
                                    switch value {
                                    case .first(true):
                                        state = .pressing
                                    case .second(true, let drag):
                                        state = .dragging(translation: drag?.translation ?? .zero)
                                    default:
                                        break
                                    }
                                }
                                .onEnded { value in
                                    guard case .second(true, let drag?) = value else { return }
                                    
                                    if drag.translation.width < -self.dragThreshold {
                                        UIDevice.vibrate()
                                        self.moveCard()
                                    } else if drag.translation.width > self.dragThreshold {
                                        if let topCard = cardViews.first {
                                            selectedRestaurant = topCard.restaurant
                                            showSheet = true
                                        }
                                    }
                                }//onEnded
                        )//gesture
                }//ForEach
            }//ZStack
        }//VStack
        .onAppear {
            self.initializeCardViews()
        }
        .sheet(isPresented: $showSheet) {
            if let restaurant = selectedRestaurant {
                CustomSheetView(restaurant: restaurant, userLocation: CLM.userCL2DCoord!)
            }
        }
    }
    
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id }) else {
            return false
        }
        return index == 0
    }
    
    private func moveCard() {
        cardViews.removeFirst()
        if lastIndex < restaurants.count - 1 {
            lastIndex += 1
            let restaurant = restaurants[lastIndex]
            let newCardView = CardView(restaurant: restaurant)
            cardViews.append(newCardView)
        }
        if cardViews.isEmpty {
            showResultSheet = false
        }
    }
    
    private func initializeCardViews() {
        cardViews.removeAll()
        for index in 0..<min(2, restaurants.count) {
            cardViews.append(CardView(restaurant: restaurants[index]))
        }
    }
}

extension AnyTransition {
    static var trailingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .trailing).combined(with: .move(edge: .bottom))
        )
    }
    
    static var leadingBottom: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .identity,
            removal: AnyTransition.move(edge: .leading).combined(with: .move(edge: .bottom))
        )
    }
}

extension UIDevice {
    static func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}



struct CustomSheetView: View {
    let restaurant: Restaurant
    let userLocation: CLLocationCoordinate2D
    
    var distance: String {
        let restaurantLocation = CLLocation(latitude: restaurant.latitude!, longitude: restaurant.longitude!)
        let userLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let distanceInMeters = userLocation.distance(from: restaurantLocation)
        let distanceInMiles = distanceInMeters / 1609.344
        return String(format: "%.2f miles", distanceInMiles)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(restaurant.name!)
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(nil)
            
            Text("Address: \(restaurant.address ?? "No address available.")")
                .font(.body)
                .lineLimit(nil)
            
            //directions button
            Button(action: {
                let restaurantLocation = CLLocationCoordinate2D(latitude: restaurant.latitude!, longitude: restaurant.longitude!)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: restaurantLocation))
                mapItem.name = restaurant.name
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "globe")
                        .foregroundColor(.black)
                    Text("GET DIRECTIONS")
                        .font(.custom("ChakraPetch-Bold", size: 22))
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                .background(Color(customGreen))
                .cornerRadius(10)
                .shadow(radius: 5)
            }//Button
            
            //website button
            Button(action: {
                if let url = restaurant.website {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "safari")
                        .foregroundColor(.white)
                    Text("VISIT WEBSITE")
                        .font(.custom("ChakraPetch-Bold", size: 22))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
        .padding()
        .presentationDetents([.fraction(0.4)])
    }
}

