import Foundation
import CoreLocation

//defines a Restaurant class with observable properties for UI updates
class Restaurant: ObservableObject, Identifiable, Equatable, Hashable, Decodable {
    //published properties to hold restaurant data
    var id: String?
    var name: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var phoneNumber: String?
    var displayPhone: String?
    var website: URL?
    var rating: Double?
    var price: String?
    var categories: [String]?
    var imageUrl: String?
    var isOpenNow: Bool?
    var reviewCount: Int?
    var distance: Double?
    var transactions: [String]?
    
    var coordinate: CLLocationCoordinate2D {
        get {
            CLLocationCoordinate2D(latitude: latitude ?? 0, longitude: longitude ?? 0)
        }
    }

    //initializes a Restaurant object using data from a YelpBusiness object
    init(from yelpBusiness: YelpBusiness) {
        self.id = yelpBusiness.id
        self.name = yelpBusiness.name
        self.address = yelpBusiness.location?.fullAddress()
        self.latitude = yelpBusiness.coordinates?.latitude
        self.longitude = yelpBusiness.coordinates?.longitude
        self.phoneNumber = yelpBusiness.phone
        self.displayPhone = yelpBusiness.display_phone
        self.website = URL(string: yelpBusiness.url ?? "")
        self.rating = yelpBusiness.rating
        self.price = yelpBusiness.price
        self.categories = yelpBusiness.categories.map { $0.title! }
        self.imageUrl = yelpBusiness.image_url
        self.isOpenNow = yelpBusiness.business_hours.first?.is_open_now ?? false
        self.reviewCount = yelpBusiness.review_count
        self.distance = yelpBusiness.distance
        self.transactions = yelpBusiness.transactions
    }
    
    //conform to Equatable (for MapView markers)
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id
    }
    
    //conform to Hashable (for MapView markers)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}



//codable structs for decoding a Yelp API response
struct YelpAPIResponse: Codable {
    let businesses: [YelpBusiness]
}

struct YelpBusiness: Codable {
    let id: String?
    let name: String?
    let rating: Double?
    let price: String?
    let location: YelpLocation?
    let coordinates: YelpCoordinates?
    let phone: String?
    let display_phone: String?
    let isOpen: Bool?
    let url: String?
    let image_url: String?
    let business_hours: [YelpBusinessHours]
    let review_count: Int?
    let categories: [YelpCategory]
    let distance: Double?
    let transactions: [String]?
}

struct YelpLocation: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let state: String?
    let zip_code: String?
    let country: String?

    func fullAddress() -> String {
        let components = [address1, city, state, zip_code].compactMap { $0 }
        guard !components.isEmpty else { return "No address available" }
        return components.joined(separator: ", ")
    }
}

struct YelpCoordinates: Codable {
    let latitude: Double?
    let longitude: Double?
}

struct YelpCategory: Codable {
    let title: String?
    let alias: String?
}

struct YelpBusinessHours: Codable {
    let open: [OpenHours]
    let hours_type: String
    let is_open_now: Bool
}

struct OpenHours: Codable {
    let is_overnight: Bool
    let start: String
    let end: String
    let day: Int
}
