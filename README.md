
# 🌱 Krishi - Smart Farming Assistant App

**“Empowering farmers with real-time insights, AI-driven decisions, and accessible tools for a better tomorrow.”**

A smart farming assistant platform designed to **empower Indian farmers** by delivering **real-time weather updates, AI-based predictions**, and **automated alerts** — bridging the gap between traditional agriculture and modern technology.

---

## 📝 Table of Contents
- [🚀 Features](#-features)
- [✨ Novelty](#-novelty)
- [🛠️ Tech Stack](#️-tech-stack)
- [🖼️ UI Screenshots](#️-ui-screenshots)
- [🔐 .env Configuration](#-env-configuration)
- [📦 Setup Instructions](#-setup-instructions)
- [🤝 Contribution Guidelines](#-contribution-guidelines)
- [📄 License](#-license)

---

## 🚀 Features

| Feature | Description |
|--------|-------------|
| 🌦 **Real-Time Weather Updates** | Summary + detailed forecast for farmers |
| 📰 **Agricultural News** | Stay updated with the latest farming-related news |
| 📈 **AI-Based Crop Price Prediction** | Get predicted market prices using ML models |
| 🌾 **Crop Recommendations** | Season and region-wise crop suggestions |
| 📅 **Seasonal Calendar** | Month-wise farm activity suggestions |
| 📋 **Farm Activity Log** | Track sowing, fertilizing, and harvesting |
| 📢 **Govt Schemes Info** | Discover relevant schemes and benefits |
| 📲 **Offline SMS Alerts** | Weather warnings and task reminders via SMS |
| 👤 **Farmer Profile Section** | Editable profile with personalized suggestions |

---

## ✨ Novelty

- ✅ **Unified Platform** combining weather, market prices, and government info.
- 📶 **Offline Functionality** using SMS alerts for low-connectivity areas.
- 👨‍🌾 **Rural-Oriented Design**: Simple UI, vernacular usability, and minimal data consumption.
- 🤖 **AI-Powered Insights**: Crop recommendation and price prediction using trained ML models.

---

## 🛠️ Tech Stack

| Layer | Technology |
|------|------------|
| **Frontend** | [Flutter](https://flutter.dev/) (Dart) |
| **Backend APIs** | OpenWeatherMap API, News API, TextBee SMS API |
| **Database & Auth** | [Firebase](https://firebase.google.com/) |
| **Machine Learning** | Python (Scikit-learn, Pandas) for crop price prediction and crop recommendation |
| **Other** | dotenv for environment variable management |

---

## 🖼️ UI Screenshots

| Page | Screenshot |
|------|------------|
| **User Login Page** | ![Userloginpage](https://github.com/user-attachments/assets/a00c8598-3583-4e35-9d37-1344f1aa2af4) |
| **Home Screen** | ![Home Screen](screenshots/home.png) |
| **Profile Page** | ![Profile](screenshots/profile.png) |
| **Helpline Page** | ![Helpline](screenshots/helpline.png) |
| **Crop Recommendation Page** | ![Crop Recommendation](screenshots/crop_recommendation.png) |

> 📸 *Place your UI screenshots inside the `screenshots/` folder in the root directory of your project.*

---

## 🔐 .env Configuration

Create a `.env` file in the root directory:

```ini
WEATHER_API_KEY=your_weather_api_key
TEXTBEE_API_KEY=your_textbee_api_key
TEXTBEE_DEVICE_ID=your_textbee_device_id
NEWS_API_KEY=your_news_api_key
```

> 🔒 **Note:** Ensure `.env` and `firebase_options.dart` are added to `.gitignore`.

---

## 📦 Setup Instructions

```bash
# Clone the repository
git clone https://github.com/your-username/smart-farming-app.git

# Navigate into the project directory
cd smart-farming-app

# Install dependencies
flutter pub get

# Add your .env file with API keys

# Run the app
flutter run
```

---

## 🤝 Contribution Guidelines

1. **Fork** the repository.
2. **Create a new branch** for your feature or bugfix:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** and test thoroughly.
4. **Commit** with a clear message:
   ```bash
   git commit -m "Add: feature description"
   ```
5. **Push** your branch and open a **Pull Request**.
6. Follow standard **naming conventions** and maintain **clean code**.

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
