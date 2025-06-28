# Dailies – A Daily News-Based Word Game

**Dailies** is a mobile app that combines real-world news with word-based puzzles to create a unique, engaging experience. Every day, the app selects a five-letter word from current news headlines and challenges the user to guess it, similar to Wordle. Once the word is revealed, the app provides a short explanation of the word or its context in the news.

The goal is to help users stay informed while playing a quick, meaningful game each day.

---

## Features

- One daily five-letter word to guess, based on recent news headlines.
- Automatically updates every day with a new word and a simple explanation.
- Clean, simple Flutter interface with animations and visual feedback.
- Works offline after daily word is fetched (local storage fallback).
- Tracks user streaks and provides a short educational component with each word.
- Entirely powered by open APIs and automation scripts.

---

## How It Works

A Python script runs once a day to:
1. Fetch real-time headlines from NewsAPI.
2. Extract relevant five-letter words using the NLTK library.
3. Select one word randomly from a pool of high-relevance words.
4. Generate a short explanation using a language model (Hugging Face Transformers).
5. Store both the word and explanation in Firebase Firestore.

The Flutter app fetches this data and presents the puzzle to the user each day.

---

## Getting Started

### Requirements

- Flutter installed on your system
- A Firebase project (Firestore)
- NewsAPI key
- Python environment (for backend script)

---

### Flutter Setup

Clone the repository and install dependencies:

```bash / terminal

git clone https://github.com/yourusername/dailies-app.git
cd dailies-app
flutter pub get
Update any configuration files (lib/constants.dart, .env, etc.) with:



const firebaseCollection = "dailyWord";
const newsApiKey = "your_newsapi_key";
const firebaseProjectID = "your_firebase_project_id";
Run the app locally:


flutter run
Python Automation Script
In the python/ directory, you’ll find update_daily_word.py, which handles word selection and updates Firestore.

Install dependencies:

pip install requests nltk firebase-admin transformers
Run the script manually:


python update_daily_word.py

You can schedule this script to run daily using services like:

PythonAnywhere

Deta

Railway

Project Structure

dailies\lib
│   main.dart
│
├───screens
│       connections_screen.dart
│       fetch_news.py
│       home_screen.dart
│       splash_screen.dart
│       wordle_screen.dart

