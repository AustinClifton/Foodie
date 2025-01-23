import SwiftUI

struct RouletteView: View {
    //shared manager(s)
    @EnvironmentObject var CLM: CurrentLocationManager
    
    //state properties
    @State private var filters: [String] = []
    @State private var radius: Int = 1
    
    @State private var showResultSheet: Bool = false //true if the user hits the 'continue' button
    @State private var showAlert: Bool = false //controls display of the alert
    @State private var offset: CGFloat = 0 //controls vertical position of the view
    @State private var showButtons: Bool = false //used to track which section is shown
    
    @State private var selectedSearchLogic: SearchLogic = .anyFiltersApply

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                //intro section
                VStack {
                    //title, image and swipe instruction
                    ZStack {
                        VStack {
                            
                            Spacer(minLength: 30)
                            
                            Text("Foodie\nRoulette")
                                .font(.custom("PlayfairDisplay-VariableFont_wght", size: 60))
                                .foregroundColor(Color(customOrange))
                                   .bold()
                                   .fixedSize(horizontal: false, vertical: true) //prevent truncation
                                   .frame(maxWidth: .infinity, alignment: .leading)
                                   .padding(.leading, 25)
                            
                            Text("Swipe Up To Begin")
                                .font(.system(size: 28))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 375)
                            
                            //down caret
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray)
                                .padding(.bottom, 25)
                        }
                        
                        Image("roulette")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.white)
                            .frame(width: 125, height: 125)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2 + 50)
                    }
                }//VStack
                .frame(height: geometry.size.height)
                .background(.thinMaterial)
                
                //main section: buttons and picker
                ZStack {
                    Color(.white).edgesIgnoringSafeArea(.top)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            
                            //"Back Up" button
                            Button(action: {
                                withAnimation {
                                    showButtons = false
                                    offset = 0 //reset offset to show the start section
                                }
                            }) {
                                Text("Back Up")
                                    .frame(maxWidth: .infinity)
                                    .padding() //gives the button height
                                    .font(.custom("PlayfairDisplay-VariableFont_wght", size: 22))
                                    .foregroundColor(.white)
                                    .background(.black)
                                    .cornerRadius(16)
                                    
                            }
                            
                            //food buttons
                            FoodButtonsView(filters: $filters, radius: $radius, selectedSearchLogic: $selectedSearchLogic)
                            
                            //"Continue" button
                            Button(action: {
                                if filters.isEmpty { showAlert = true } else { showResultSheet = true } }
                            ) {
                                Text("CONTINUE")
                                    .font(.custom("PlayfairDisplay-VariableFont_wght", size: 22))
                                    .frame(maxWidth: .infinity)
                                    .padding() //gives the button height
                                    .foregroundColor(.black)
                                    .background(Color(customYellow))
                                    .cornerRadius(16)
                            }
                        } //VStack
                        .padding()
                    } //ScrollView
                    .frame(height: geometry.size.height)
                }
            } //VStack
            
            //if showButtons is true, offset is set to -geometry.size.height. this shifts the content up by the entire screen height, hiding the intro section and showing the main section. if showButtons is false, offset is set to 0, so the intro section is visible and aligned to the original position
            .offset(y: showButtons ? -geometry.size.height : 0)
            
            //this gesture captures the user’s vertical swipe to determine which section should be displayed
            .gesture(
                DragGesture()
                    //during the drag
                    .onChanged { gesture in
                        let dragAmount = gesture.translation.height //holds the vertical distance the user has dragged their finger
                        if !showButtons { //intro screen is in view
                            offset = min(max(dragAmount, 0), geometry.size.height) //ensures that dragAmount never goes below 0 so the screen doesn’t move up, and limits dragAmount to the screen height preventing excessive downward movement.
                        } else { //buttons section is in view
                            offset = min(max(dragAmount, -geometry.size.height), 0) //prevents dragAmount from going above -geometry.size.height so the screen doesn’t move up further, and ensures the offset doesn’t drop below 0 keeping the main section in place.
                        }
                    }
                
                    //after the drag ends
                    .onEnded { gesture in
                        if gesture.translation.height < -50 { //means the user swiped up, this sets showButtons to true which moves the button section into view by setting offset = -geometry.size.height
                            showButtons = true
                            offset = -geometry.size.height
                        }
                    }
            )
            .animation(.easeInOut, value: offset)
        }
        .sheet(isPresented: $showResultSheet) {
            RouletteResultView(filters: $filters, radius: $radius, selectedSearchLogic: $selectedSearchLogic)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("No Filters Selected"),
                  message: Text("Please select at least one filter before continuing."),
                  dismissButton: .default(Text("OK")))
        }
    }
}
