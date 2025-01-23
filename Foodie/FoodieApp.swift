import SwiftUI

@main
struct FoodieApp: App {
    @StateObject private var CLM = CurrentLocationManager()
    @StateObject var handler = YelpHandler()
    
    init() {
       Task { @MainActor in
           UISegmentedControl.appearance().selectedSegmentTintColor = .white
           UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
       }
   }
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .environmentObject(CLM)
                .environmentObject(handler)
        }
    }
}
