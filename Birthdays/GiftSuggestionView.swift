import Foundation

// Define a struct for gift suggestions
struct GiftSuggestion {
    let interest: String
    let ageGroup: String
    let gifts: [String]
}

// Predefined data for gift suggestions
let giftSuggestions: [GiftSuggestion] = [
    GiftSuggestion(
        interest: "Creativity",
        ageGroup: "0-12",
        gifts: ["Art supplies", "Lego sets", "Building blocks"]
    ),
    GiftSuggestion(
        interest: "Creativity",
        ageGroup: "13-18",
        gifts: ["Sketchbooks", "Advanced art kits", "Calligraphy sets"]
    ),
    GiftSuggestion(
        interest: "Creativity",
        ageGroup: "19-35",
        gifts: ["Digital drawing tablet", "Creative writing journals", "Art classes"]
    ),
    GiftSuggestion(
        interest: "Creativity",
        ageGroup: "36+",
        gifts: ["DIY craft kits", "Easel and painting supplies", "Adult coloring books"]
    ),
    GiftSuggestion(
        interest: "Outdoors",
        ageGroup: "0-12",
        gifts: ["Toy camping sets", "Binoculars", "Butterfly nets"]
    ),
    GiftSuggestion(
        interest: "Outdoors",
        ageGroup: "13-18",
        gifts: ["Hiking gear", "Skateboards", "Outdoor games"]
    ),
    GiftSuggestion(
        interest: "Outdoors",
        ageGroup: "19-35",
        gifts: ["Camping equipment", "Adventure vouchers", "Fitness trackers"]
    ),
    GiftSuggestion(
        interest: "Outdoors",
        ageGroup: "36+",
        gifts: ["Gardening tools", "Bird-watching kits", "Walking poles"]
    ),
    // Add more interests and age groups as needed
]
