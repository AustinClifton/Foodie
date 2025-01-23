import SwiftUI
import Foundation
import MapKit

struct CardView: View, Identifiable {
    let id = UUID()
    let restaurant: Restaurant

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                //restaurant image
                AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                        .overlay(
                            Text("No image available")
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
                .frame(maxHeight: 275)
                .clipShape(RoundedCornerShape(radius: 20, corners: [.topLeft, .topRight]))
                .clipped()
                
                //yelp logo (only if the restaurant image is available)
                if let imageUrl = restaurant.imageUrl, !imageUrl.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image("yelp_logo")
                                .resizable()
                                .frame(width: 70, height: 30)
                                .padding([.bottom, .trailing], 8)
                        }//HStack
                    }//VStack
                }
            }//ZStack
            
            //info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    //restaurant name
                    Text(restaurant.name ?? "Name unavailable")
                        .font(.custom("ChakraPetch-Bold", size: 32))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 270, alignment: .leading)
                    
                    Spacer()
                    
                    Text(restaurant.isOpenNow == true ? "NOW OPEN" : "CLOSED")
                        .font(.custom("ChakraPetch-Bold", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(restaurant.isOpenNow == true ? .green : .red)
                }
                
                //price, rating, review count
                HStack() {
                    //round rating to the nearest 0.5
                    let roundedRating = round((restaurant.rating ?? 0.0) * 2) / 2
                    
                    //build the image name based on the rounded rating (e.g., yelp_review_0_5, yelp_review_1, etc.)
                    let ratingImageName = "yelp_review_" + (roundedRating == floor(roundedRating) ? String(Int(roundedRating)) : String(format: "%.1f", roundedRating).replacingOccurrences(of: ".", with: "_"))
                    
                    if let ratingImage = UIImage(named: ratingImageName) {
                        Image(uiImage: ratingImage)
                            .resizable()
                            .frame(width: 135, height: 25)
                    } else {
                        Text("Image not found")
                            .foregroundColor(.black)
                    }
                    
                    //review count text
                    Text("\(restaurant.reviewCount ?? 0) Reviews")
                        .font(.custom("ChakraPetch-Bold", size: 20))
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .truncationMode(.tail)
                    
                    //price text
                    Text(restaurant.price ?? "$")
                        .font(.custom("ChakraPetch-Bold", size: 22))
                        .fontWeight(.bold)
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .truncationMode(.tail)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    //categories text
                    Text(restaurant.categories?.joined(separator: ", ").capitalized ?? "No categories")
                        .font(.system(size: 16))
                        .italic()
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    //features text
                    let transactionsText = restaurant.transactions?.isEmpty == false
                        ? restaurant.transactions!.joined(separator: ", ").capitalized
                        : "no special features"
                    Text("Offers \(transactionsText)")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    //address
                    Text(restaurant.address ?? "Address unavailable")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    //distance
                    Text(
                        restaurant.distance != nil
                        ? "\(String(format: "%.1f", restaurant.distance! / 1609.34)) miles away"
                        : "Distance unavailable"
                    )
                    .font(.subheadline)
                    .foregroundColor(.black)
                }
                
                Spacer()
                
                //restaurant-specific buttons
                HStack(spacing: 12) {
                    Spacer()
                    
                    //phone button
                    if let phoneNum = restaurant.phoneNumber, let url = URL(string: "tel://\(phoneNum)") {
                        CustomButton(iconName: "phone.fill", action: {
                            UIApplication.shared.open(url)
                        }, backgroundColor: .red, iconColor: .white)
                    }
                    
                    //website button
                    if let website = restaurant.website {
                        CustomButton(iconName: "globe", action: {
                            UIApplication.shared.open(website)
                        }, backgroundColor: .blue, iconColor: .white)
                    }
                    
                    //map button
                    CustomButton(iconName: "arrow.trianglehead.turn.up.right.circle.fill", action: {
                        let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: restaurant.latitude!, longitude: restaurant.longitude!)))
                        destination.name = restaurant.name
                        MKMapItem.openMaps(with: [destination], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                    }, backgroundColor: Color(customGreen), iconColor: .white)
                    
                    Spacer()
                }//HStack
            }//VStack info
            .padding(10)
            .background(.white)
            
        }//VStack
        .frame(width: UIScreen.main.bounds.width * 0.95, height: UIScreen.main.bounds.height * 0.65)
        .cornerRadius(20)
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct CustomButton: View {
    let iconName: String
    let action: () -> Void
    var backgroundColor: Color
    var iconColor: Color
    var cornerRadius: CGFloat = 8
    var width: CGFloat = 100
    var height: CGFloat = 45

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .foregroundColor(iconColor)
                .frame(width: 30, height: 30)
                .padding()
                .frame(width: width, height: height)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
