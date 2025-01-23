import SwiftUI
import MapKit

let customGreen = UIColor(rgb: 0x32CD32)
let customRed = UIColor(rgb: 0xc1121f)
let customYellow = UIColor(rgb: 0xffbe0b)
let customOrange = UIColor(rgb: 0xF76902)

struct ContentView: View {
    //shared manager(s)
    @EnvironmentObject var CLM: CurrentLocationManager

    var body: some View {
        TabView {
            RouletteView()
                .tabItem {
                    Image(systemName: "circle.dotted")
                }

            CardSwipeView()
                .tabItem {
                    Image(systemName: "lanyardcard.fill")
                }

            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                }
        }
        .accentColor(.white)
        .onAppear {
            CLM.requestWhenInUseAuthorization()
        }
    }//body
}//ContentView

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

#Preview {
    ContentView()
}
