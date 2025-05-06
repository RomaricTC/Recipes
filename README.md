
## Requirements

- **Xcode 14.0** or later
- **iOS 15.0** or later
- **Swift 5.6** or later

## Getting Started

### Building the Project

1. **Clone the repository:**
    ```sh
    https://github.com/RomaricAR/RecipesApp.git
    ```
2. **Open the project in Xcode:**
    ```sh
    cd recipes-app
    open Recipes.xcodeproj
    ```
3. **Build the project:**
   - Select your target device or simulator.
   - Press `Cmd + R` or click the "Run" button in Xcode.

### Running Tests

Unit tests are provided in the `RecipesTests` target. To run the tests:

1. **Open the test navigator:**
   - In Xcode, press `Cmd + 6` or click the "Test Navigator" icon.
2. **Run the tests:**
   - Press `Cmd + U` or click the "Run" button next to `RecipesTests`.

### Folder Structure Explanation

- **Models:** Contains the data models used in the app, such as `Recipe` and `RecipeDetailsModel`.
- **ViewModels:** Contains the ViewModel classes (`RecipesViewModel`, `RecipeDetailsViewModel`) that manage data fetching and business logic.
- **Views:** Contains SwiftUI views (`RecipesView`, `RecipeDetailsView`) that define the app's user interface.
- **Services:** Contains the networking service responsible for fetching data from the API.
- **Utilities:** Contains utility files, extensions, and error handling logic.
- **RecipesTests:** Contains unit tests for the app, including mock services for testing.

## API Reference

This app uses the [TheMealDB API](https://www.themealdb.com/api.php). The following endpoints are utilized:

- **Fetch Recipes:** `https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert`
- **Fetch Recipe Details:** `https://www.themealdb.com/api/json/v1/1/lookup.php?i={MEAL_ID}`

