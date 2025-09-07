# AI-Powered Nutrition Tracker

A Flutter-based Android application that uses AI (Google Gemini or OpenAI ChatGPT) to analyze food images and track nutrition information.

## Features

### 🤖 AI Integration

- **Dual AI Support**: Choose between Google Gemini or OpenAI ChatGPT
- **Image Analysis**: Take photos or upload images of your meals
- **Smart Recognition**: AI identifies food items and calculates nutrition
- **Editable Results**: Modify recognized food items and recalculate nutrition

### 📱 Core Functionality

- **Food Logging**: Log meals with automatic meal type selection based on time
- **Nutrition Tracking**: Track calories, protein, carbohydrates, fiber, and fat
- **Daily Statistics**: View daily totals and progress towards goals
- **Multiple Meal Types**: Breakfast, Lunch, Dinner, and 4 snack categories

### 👤 User Profile

- **Comprehensive Setup**: Height, weight, activity level, exercise type
- **BMI Calculation**: Automatic BMI calculation
- **TDEE Estimation**: Total Daily Energy Expenditure calculation
- **Goal Setting**: Maintain, Bulking, or Cutting with calorie adjustments

### ⚙️ Smart Features

- **Goal-based Warnings**: Alerts for cutting phase calorie overages
- **Flexible Targets**: Adjustable calorie deficit/surplus (-750 to +500 kcal)
- **Time-based Meal Selection**: Auto-select meal type based on current time
- **Data Persistence**: Local storage of all data using SQLite

## Setup Instructions

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Android SDK
- An API key from either:
  - [Google AI Studio](https://makersuite.google.com/app/apikey) (for Gemini)
  - [OpenAI](https://platform.openai.com/api-keys) (for ChatGPT)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd nutrition_tracker
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate JSON serialization code**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### First Time Setup

1. **Launch the app** - You'll be guided through the onboarding process
2. **Enter personal information**:

   - Height and weight
   - Daily activity level (Light/Moderate/Heavy)
   - Exercise type (Cardio/Gym/Competitive Sports)
   - Exercise frequency per week
   - Fitness goal (Maintain/Bulking/Cutting)

3. **Configure AI settings**:

   - Go to Settings → AI Configuration
   - Select your preferred AI provider (Gemini or OpenAI)
   - Enter your API key

4. **Fine-tune your goals**:
   - Adjust calorie deficit/surplus if needed
   - Set custom thresholds based on your specific goals

## How to Use

### Adding Food Entries

1. **Tap the + button** on the home screen
2. **Select meal type** (auto-selected based on current time)
3. **Take a photo** or select from gallery
4. **Optional**: Add text description of food items
5. **Analyze** - AI will process the image and return nutrition data
6. **Review and edit** if needed
7. **Save** the entry

### Viewing Daily Progress

- **Daily Summary Card**: Shows total calories, macros, and progress
- **Meal Sections**: Organized by meal type with individual entries
- **Goal Warnings**: Alerts if you exceed cutting targets
- **Date Navigation**: Browse previous days or plan ahead

### Managing Settings

- **AI Configuration**: Switch providers or update API keys
- **User Profile**: Modify physical stats and activity levels
- **Goal Adjustment**: Change calorie targets and fitness goals
- **Data Management**: Reset all data if needed

## Technical Details

### Architecture

- **State Management**: Provider pattern for reactive UI updates
- **Local Storage**: SQLite for nutrition entries, SharedPreferences for settings
- **Image Handling**: Camera and gallery integration with compression
- **AI Integration**: Modular service supporting both Gemini and OpenAI APIs

### Data Models

- **UserProfile**: Physical stats, activity level, goals
- **NutritionEntry**: Food items, macros, meal type, timestamps
- **FoodItem**: Individual food components with quantities
- **AppSettings**: AI provider, API keys, app preferences

### AI Prompt Engineering

The app uses carefully crafted prompts to ensure consistent JSON responses from both AI providers, including:

- Structured nutrition analysis requests
- Revision and recalculation commands
- Encouraging, positive feedback generation

## Privacy & Security

- **Local Data**: All nutrition data is stored locally on your device
- **API Keys**: Stored securely on device, never transmitted to third parties
- **Images**: Processed by AI services but not permanently stored by providers
- **No Cloud Sync**: Complete data privacy with local-only storage

## Troubleshooting

### Common Issues

1. **AI Analysis Fails**

   - Verify API key is correct and active
   - Check internet connection
   - Ensure image is clear and shows food items

2. **Permissions Denied**

   - Grant camera and storage permissions in device settings
   - Restart app after permission changes

3. **Build Errors**
   - Run `flutter clean` then `flutter pub get`
   - Regenerate code with `flutter packages pub run build_runner build --delete-conflicting-outputs`

## Contributing

Feel free to submit issues, feature requests, or pull requests to help improve the app.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
