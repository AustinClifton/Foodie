import SwiftUI
import MapKit

struct FoodButtonsView: View {
    //shared managers
    @EnvironmentObject var CLM: CurrentLocationManager
    
    //binding properties for filters, radius, search logic
    @Binding var filters: [String]
    @Binding var radius: Int
    @Binding var selectedSearchLogic: SearchLogic
    
    //array of tuples representing each food button category
    let categories: [(title: String, foodTypes: [(query: String, label: String, icon: String)])] = [
        ("OPERATIONAL STATUS", [
            ("Open Now", "Open Now", "open"),
            ("Closed Now", "Closed Now", "close")
        ]),
        
        ("PRICE RANGE", [
            ("$1", "Inexpensive ($)", "coins"),
            ("$2", "Moderate ($$)", "dollar"),
            ("$3", "Expensive ($$$)", "credit"),
            ("$4", "Very Expensive ($$$$)", "money-bag")
        ]),
        
        ("RESTAURANT TYPES", [
            ("Bar", "Bar", "bar"),
            ("Pizzeria", "Pizzeria", "wholepizza"),
            ("Steakhouse", "Steakhouse", "steak"),
            ("Fast Food", "Fast Food", "mcdonalds"),
            ("Barbeque", "Barbeque", "barbeque"),
            ("Cafe", "Cafes", "cafe"),
            ("Pub", "Pub", "pub"),
            ("Brewery", "Brewery", "beer"),
            ("Diner", "Diner", "fried-egg"),
            ("Buffet", "Buffet", "buffet"),
            ("Deli", "Deli", "deli"),
            ("Bakery", "Bakery", "bakery"),
            ("Food Trucks", "Food Trucks", "food-truck"),
            ("Dessert", "Desserts", "dessert")
        ]),
        
        ("FOOD TYPES", [
            ("Pizza", "Pizza", "pizzaslice"),
            ("Sushi", "Sushi", "sushi"),
            ("Tacos", "Tacos", "taco"),
            ("Chicken", "Chicken", "chicken"),
            ("Burgers", "Burgers", "cheeseburger"),
            ("Seafood", "Seafood", "seafood"),
            ("Subs", "Subs", "sandwich"),
            ("Steak", "Steak", "steak"),
            ("Pasta", "Pasta", "pasta"),
            ("Sandwiches", "Sandwiches", "sandwich"),
            ("Soup", "Soup", "soup"),
            ("Coffee", "Subs", "coffee"),
            ("Ice Cream", "Ice Cream", "icecreamcone"),
            ("Salad", "Salad", "salad"),
            ("Bagels", "Bagels", "bagel"),
            ("Wings", "Wings", "wings")
        ]),
        
        ("DIETARY PREFERENCES", [
            ("Gluten-Free", "Gluten-Free", "glutenfree"),
            ("Halal", "Halal", "halalsign"),
            ("Vegetarian", "Vegetarian", "vegetarian"),
            ("Vegan", "Vegan", "vegan"),
            ("Organic", "Organic", "organic"),
            ("Kosher", "Kosher", "kosher")
        ]),
        
        ("CUISINES", [
            ("American", "American", "usa"),
            ("Italian", "Italian", "italy"),
            ("Mexican", "Mexican", "mexico"),
            ("Chinese", "Chinese", "china"),
            ("Japanese", "Japanese", "japan"),
            ("Indian", "Indian", "india"),
            ("Mediterranean", "Mediterranean", "mediterranean"),
            ("French", "French", "france"),
            ("Thai", "Thai", "thailand"),
            ("Greek", "Greek", "greece"),
            ("Korean", "Korean", "southkorea"),
            ("Southern", "Southern", "usa"),
            ("Vietnamese", "Vietnamese", "vietnam"),
            ("Jamaican", "Jamaican", "jamaica"),
            ("Spanish", "Spanish", "spain"),
            ("Ethiopian", "Ethiopian", "ethiopia"),
            ("Turkish", "Turkish", "turkey"),
            ("Peruvian", "Peruvian", "peru"),
            ("Portuguese", "Portuguese", "portugal"),
            ("Brazilian", "Brazilian", "brazil"),
            ("Australian", "Australian", "australia")
        ])
    ]
    
    //button section layout
    var body: some View {
            VStack {
                //distance picker
                VStack {
                    Text("Tap To Set Distance (miles)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Picker("Tap To Set Distance (miles)", selection: $radius) {
                        ForEach(1..<8, id: \.self) { radius in
                            Text("\(radius)")
                                .tag(radius)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(Color.red)
                    .padding(.horizontal, 25)
                    
                    Text("\(radius) miles")
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .padding(.top, 20)
                
                //toggle for search logic
                VStack(alignment: .leading) {
                    HStack {
                        Text("Search Logic: \(selectedSearchLogic == .allFiltersApply ? "All Filters" : "Any Filter")")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()

                        HStack {
                            Toggle(isOn: Binding(
                                get: { selectedSearchLogic == .allFiltersApply },
                                set: { selectedSearchLogic = $0 ? .allFiltersApply : .anyFiltersApply }
                            )) {
                                EmptyView()
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .green))
                            .frame(width: 65, height: 30)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.2))
                                    .padding(.leading, 25)
                            )
                        }//HStack
                    }//HStack
                    .padding(.top, 25)

                    VStack {
                        Text(
                            selectedSearchLogic == .anyFiltersApply ?
                            "The 'Any Filter' option allows for a match if any filter is applicable." :
                            "The 'All Filters' option requires all selected filters to be applicable for a match."
                        )
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 2)
                    }//VStack
                    
                    Divider()
                }//VStack

                //loop to construct each food button category section
                ForEach(categories, id: \.title) { category in
                    VStack(alignment: .leading) {
                        Text(category.title)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.black)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(category.foodTypes, id: \.query) { food in
                                    foodButton(query: food.query, label: food.label, icon: food.icon)
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                    .padding(.top, 15)
                }
            }
        }
        
        //function to create a custom SwiftUI button for selecting/deselecting food types
        private func foodButton(query: String, label: String, icon: String) -> some View {
            Button(action: {
                if let index = filters.firstIndex(of: query) {
                    filters.remove(at: index)
                    print("filters: ", filters)
                } else {
                    filters.append(query)
                    print("filters: ", filters)
                }
            }) {
                VStack {
                    Image(icon)
                        .resizable()
                        .frame(width: 30, height: 30)
                    Text(label)
                        .font(.subheadline)
                        .foregroundColor(.black)
                }
                .frame(width: 83, height: 32)
                .padding()
                .background((filters.contains(query)) ? Color(customGreen) : .white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black, lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
