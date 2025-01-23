import Foundation
import SwiftUI
import CoreLocation
import MapKit

enum SearchLogic {
    case allFiltersApply
    case anyFiltersApply
}

@MainActor
class YelpHandler: ObservableObject {
    @EnvironmentObject var CLM: CurrentLocationManager
    @Published var searchResults: [Restaurant] = []
    
    private var apiKey: String? { return Bundle.main.object(forInfoDictionaryKey: "YELP_API_KEY") as? String }
    private var clientID: String? { return Bundle.main.object(forInfoDictionaryKey: "YELP_CLIENT_ID") as? String }
    private let synchronizationQueue = DispatchQueue(label: "com.yourapp.restaurantQueue")
    
    func search(filters: [String], coordinates: CLLocationCoordinate2D, radius: Int, searchLogic: SearchLogic, completion: @escaping ([Restaurant]?, Error?) -> Void) {
        var radiusMeters: Double = Double(radius)
        if radius < 8 { radiusMeters = Double(radius) * 1609.344 }
        
        let priceFilters = filters.filter { $0.starts(with: "$") }
            .compactMap { String($0.dropFirst()) }
            .joined(separator: ",")
        
        let otherFilters = filters.filter { !$0.starts(with: "$") && !$0.hasSuffix("S") && $0 != "open_now" }
    
        // Start building URL
        let urlString = "https://api.yelp.com/v3/businesses/search"
        var urlComponents = URLComponents(string: urlString)!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "latitude", value: String(coordinates.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinates.longitude)),
            URLQueryItem(name: "radius", value: String(Int(radiusMeters))),
            URLQueryItem(name: "limit", value: "50")
        ]

        if filters.contains("open_now") { queryItems.append(URLQueryItem(name: "open_now", value: "true")) }
        if !priceFilters.isEmpty { queryItems.append(URLQueryItem(name: "price", value: priceFilters)) }

        if searchLogic == .allFiltersApply {
            if !otherFilters.isEmpty {
                let filterString = otherFilters.joined(separator: ",")
                queryItems.append(URLQueryItem(name: "categories", value: filterString))
                queryItems.append(URLQueryItem(name: "term", value: filterString))
            }

            urlComponents.queryItems = queryItems

            guard let url = urlComponents.url else {
                completion(nil, NSError(domain: "YelpAPIHandler", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
                return
            }

            executeRequest(url: url, coordinates: coordinates, radiusMeters: radiusMeters, completion: completion)
        } else {
            searchRestaurantsWithFilter(filters: otherFilters, coordinates: coordinates, radius: radiusMeters, queryItems: queryItems, completion: completion)
        }
    }

    private func searchRestaurantsWithFilter(filters: [String], coordinates: CLLocationCoordinate2D, radius: Double, queryItems: [URLQueryItem], completion: @escaping ([Restaurant]?, Error?) -> Void) {
        var allRestaurants: [Restaurant] = []
        let dispatchGroup = DispatchGroup()

        for filter in filters {
            dispatchGroup.enter()

            var updatedQueryItems = queryItems
            updatedQueryItems.append(URLQueryItem(name: "categories", value: filter))
            updatedQueryItems.append(URLQueryItem(name: "term", value: filter))
            
            var urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/search")!
            urlComponents.queryItems = updatedQueryItems

            guard let url = urlComponents.url else {
                dispatchGroup.leave()
                continue
            }

            executeRequest(url: url, coordinates: coordinates, radiusMeters: radius) { restaurants, error in
                if let restaurants = restaurants {
                    allRestaurants.append(contentsOf: restaurants)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            completion(allRestaurants, nil)
        }
    }

    private func executeRequest(url: URL, coordinates: CLLocationCoordinate2D, radiusMeters: Double, completion: @escaping ([Restaurant]?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey ?? "")", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "YelpAPIHandler", code: 2, userInfo: [NSLocalizedDescriptionKey: "No data received"]))
                return
            }

            do {
                let decoder = JSONDecoder()
                let apiResponse = try decoder.decode(YelpAPIResponse.self, from: data)

                Task { @MainActor in
                    let filteredRestaurants: [Restaurant] = apiResponse.businesses
                        .filter { $0.distance ?? 0 <= radiusMeters }
                        .map { Restaurant(from: $0) }
                    
                    self.searchResults = filteredRestaurants
                    completion(filteredRestaurants, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
    }
}
