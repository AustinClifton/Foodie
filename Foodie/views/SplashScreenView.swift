import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    let delay = 1.5

    var body: some View {
        ZStack {
            if isActive {
                ContentView()
                    .transition(.opacity)
            } else {
                VStack(alignment: .center) {
                    Spacer()
                    
                    Text("Foodie")
                        .font(.custom("ChakraPetch-Bold", size: 28))
                        .foregroundColor(Color(customOrange))
                    
                    Text("Roulette - CardSwipe - MapView")
                        .font(.system(size: 16))
                        .italic()
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }//onAppear
            }//else
        }//ZStack
    }//body
}
