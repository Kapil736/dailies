import os
import requests
import nltk
import re
import random
import json
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

# NewsAPI configuration
API_KEY = "4b86fa6e6b14416283b94a8f4a4f1bc8"
API_URL = "https://newsapi.org/v2/top-headlines"

# Firebase configuration
FIREBASE_CREDENTIALS = "dailies-695c1-firebase-adminsdk-17mnl-4f6e18a4bd.json"

def initialize_firebase():
    """Initialize Firebase connection."""
    try:
        cred = credentials.Certificate(FIREBASE_CREDENTIALS)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        exit(1)

def fetch_news():
    """Fetch top headlines from NewsAPI."""
    params = {
        "apiKey": API_KEY,
        "language": "en",
        "pageSize": 10  # Fetch 10 articles
    }
    response = requests.get(API_URL, params=params)
    if response.status_code == 200:
        data = response.json()
        return data.get("articles", [])
    else:
        print(f"Error fetching news: {response.status_code}")
        return []

def extract_keywords(articles):
    """Extract 5-letter keywords from article titles and descriptions."""
    nltk.download('punkt')
    nltk.download('stopwords')
    stopwords = set(nltk.corpus.stopwords.words('english'))
    words = []

    for article in articles:
        text = (article.get("title") or "") + " " + (article.get("description") or "")
        tokens = nltk.word_tokenize(text)
        for word in tokens:
            word = word.upper()
            if (
                len(word) == 5
                and word.isalpha()
                and word not in stopwords
            ):
                words.append(word)

    return sorted(list(set(words)))

def upload_to_firebase(db, word, explanation):
    """Upload the daily word and explanation to Firestore."""
    try:
        doc_name = datetime.now().strftime("%Y-%m-%d")  # Unique document name per day
        db.collection("daily_word").document(doc_name).set({
            "daily_word": word,
            "explanation": explanation,
            "timestamp": firestore.SERVER_TIMESTAMP
        })
        print(f"Uploaded daily word: {word}")
    except Exception as e:
        print(f"Error uploading to Firebase: {e}")

def main():
    # Initialize Firebase
    db = initialize_firebase()

    print("Fetching news...")
    articles = fetch_news()
    if not articles:
        print("No articles found!")
        return

    print("Extracting keywords...")
    keywords = extract_keywords(articles)
    if keywords:
        print(f"Found {len(keywords)} keywords: {keywords}")
        daily_word = random.choice(keywords)
        explanation = f"The word '{daily_word}' is relevant to recent news."
        upload_to_firebase(db, daily_word, explanation)
    else:
        print("No suitable keywords found.")

if __name__ == "__main__":
    main()
   
