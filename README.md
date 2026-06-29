<p align="center">
  <img src="assets/icons/app_icon.png" width="150"/>
</p>

<h1 align="center">Calivio</h1>

<p align="center">
An AI-powered Flutter application that recognizes food from images and tracks daily nutrition using Google Gemini AI.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=white"/>
  <img src="https://img.shields.io/badge/Gemini_AI-4285F4?style=for-the-badge&logo=google&logoColor=white"/>
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white"/>
</p>

## 📱 Application Screenshots

<p align="center">
  <img src="assets/screenshots/app_home_page.jpg" width="220"/>
  <img src="assets/screenshots/app_add_meal_page.jpg" width="220"/>
</p>

<p align="center">
  <img src="assets/screenshots/app_history_page.jpg" width="220"/>
  <img src="assets/screenshots/app_analytics_page.jpg" width="220"/>
</p>

<p align="center">
  <img src="assets/screenshots/app_edit_goals_page.jpg" width="220"/>
</p>


## 💡 Why Calivio?

Calivio is an AI-assisted nutrition tracking application that enables users to identify food from images, estimate nutritional values based on serving size, and maintain a persistent local meal history. The application combines Flutter, Gemini AI, and SQLite to deliver a responsive, offline-first mobile experience.

## ✨ Key Features

| Feature | Description |
|----------|-------------|
| 📷 AI Food Recognition | Identifies food from images using the Gemini API. |
| 🧠 Multiple AI Predictions | Displays multiple food predictions with confidence scores. |
| 🥗 Nutrition Analysis | Estimates calories, protein, macronutrients, and micronutrients based on the identified food and serving size. |
| 📊 Daily Dashboard | Tracks daily nutrition intake and progress. |
| 📝 Meal History | Stores and organizes meal history locally using SQLite. |
| ✏️ Edit & Delete | Modify or remove previously logged meals. |
| ⚡ Image Compression | Compresses images before AI requests for faster uploads. |
| 🚀 Analysis Cache | Uses in-memory caching to reduce repeated API calls. |

## 🛠️ Tech Stack

| Category | Technologies |
|----------|--------------|
| Framework | Flutter |
| Language | Dart |
| AI | Google Gemini API |
| Database | SQLite |
| Local Storage | SharedPreferences |
| Device Storage | path_provider |
| UI | Material 3 |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Android Studio / VS Code
- Gemini API Key

### Installation

```bash
git clone https://github.com/Adithyanair098/calivio.git

cd calivio

flutter pub get
```

### 🔐 Environment Variables

Create a `.env` file in the project root and add your Gemini API key:

```env
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

> **Note:** The `.env` file is ignored by Git and is not included in this repository for security reasons.

### ▶️ Run the Application

```bash
flutter run
```

## 🎯 Project Motivation

Calivio began as an opportunity to explore technologies that were new to me. Rather than building a simple demonstration project, I wanted to understand how AI services, image processing, local persistence, and clean architecture could work together in a practical mobile application.


Throughout the project, my focus shifted from simply making the app work to improving code organization, performance, and maintainability.

## 🚀 Future Improvements

- Barcode scanning for packaged foods
- Cloud synchronization across devices
- Personalized nutrition recommendations
- Weekly and monthly nutrition reports
- Improved AI accuracy for complex meals

## 👨‍💻 Author

**Adithya Nair**

If you found this project interesting, consider giving it a ⭐ on GitHub.

## 📄 License

This project is licensed under the MIT License.
