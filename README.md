# Flutter-Project
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Directory Layout
```
/my_flutter_project
│-- /android
│-- /ios
│-- /lib
│   │-- main.dart  <-- Your main Dart file
│   │-- home.dart  <-- Additional Dart files (if needed)
│-- /test
│-- pubspec.yaml
│-- README.md
```
## Combined Fromat
```
Flutter Frontend (Android, iOS)
    |
    |-- REST API or GraphQL Backend
    |     |
    |     |-- User Service (Login/Signup/Profile)
    |     |-- Recipe Service (CRUD recipes, Search)
    |     |-- Chatbot Service (Chat history, Q&A)
    |     |-- Voice Service (Text-to-Speech)
    |
    |-- Cloud Storage
    |     |-- Image Storage (Firebase Storage / AWS S3)
    |
    |-- Database
          |-- Recipes Table
          |-- Users Table
          |-- Chats Table
          |-- Bookmarks Table
```
## Entity-Relationship Diagram (ERD)
```
User
|-- id (PK)
|-- username
|-- email
|-- password
|-- profile_picture

Recipe
|-- id (PK)
|-- name
|-- image_url
|-- country
|-- ingredients (List)
|-- steps (List)
|-- youtube_link
|-- created_by (FK to User)

Bookmark
|-- id (PK)
|-- user_id (FK)
|-- recipe_id (FK)

Chat
|-- id (PK)
|-- recipe_id (FK)
|-- user_id (FK)
|-- message
|-- timestamp

```
## Differnt Screen's Design
### 🏠 1. Home Screen
```
------------------------------------------------
|  Platr Logo         [Search Bar 🔍]           |
------------------------------------------------
| 🍲 Indian Cuisine                         ➔  |
| 🍝 Italian Cuisine                        ➔  |
| 🍣 Japanese Cuisine                       ➔  |
| 🌮 Mexican Cuisine                        ➔  |
| ... (scroll)                                |
------------------------------------------------
| [Bottom Nav Bar: Home | Bookmarks | Profile] |
------------------------------------------------
```
### 🔎 2. Search Results Screen
```
------------------------------------------------
| [Back ←]   Search: "Chicken"                 |
------------------------------------------------
| 🍗 Butter Chicken            (India)   ➔    |
| 🍗 Chicken Alfredo           (Italy)   ➔    |
| 🍗 Teriyaki Chicken          (Japan)   ➔    |
------------------------------------------------
```
### 📜 3. Recipe Details Screen
```
------------------------------------------------
| [Back ←]  Butter Chicken 🍗                  |
------------------------------------------------
| [Recipe Image 📷]                             |
------------------------------------------------
| 🛒 Ingredients:                             |
|  - Chicken                                   |
|  - Butter                                    |
|  - Spices                                    |
| ...                                          |
------------------------------------------------
| 📜 Steps:                                   |
| 1. Marinate chicken                         |
| 2. Cook on medium flame                     |
| 3. Add butter                               |
| ...                                          |
| [🔊 Listen to steps] [🎥 Watch on YouTube]   |
------------------------------------------------
| 💬 Ask a question... [Send]                  |
| 👥 Other people's answers below              |
------------------------------------------------
| [Bookmark ⭐] [Share 🔗]                      |
------------------------------------------------
```
### 💬 4. Chat Screen (Inside Recipe Details)
```
------------------------------------------------
| Q&A for Butter Chicken 🍗                    |
------------------------------------------------
| You: Can I replace butter with oil?          |
| ChefMina: Yes, but taste will differ slightly.|
| FoodieJoe: Try ghee, it’s better!             |
| ...                                          |
| [Type message...] [Send]                     |
------------------------------------------------
```
### 🏷️ 5. Bookmarks Screen
```
------------------------------------------------
| [Back ←]  My Bookmarks ⭐                     |
------------------------------------------------
| 🍜 Pho Soup           (Vietnam)        ➔    |
| 🍔 Cheeseburger       (USA)            ➔    |
| 🍛 Biryani            (India)          ➔    |
------------------------------------------------
```
### 👤 6. Profile Screen
```
------------------------------------------------
| [Profile Picture]                            |
| Username: FoodieJane                         |
| Email: foodie@example.com                    |
------------------------------------------------
| [My Recipes]  [My Bookmarks]                 |
| [Settings]  [Logout]                         |
------------------------------------------------
```
### Bottom Navigation Bar (persistent)
```
------------------------------------------------
| [🏠 Home] [⭐ Bookmarks] [👤 Profile]         |
------------------------------------------------
```
### 📜 Quick Flow Diagram
```
Splash ➔ Home ➔ [Search ➔ Results ➔ Details]
                      ➔ [Cuisine ➔ Recipes ➔ Details]
Details ➔ [Bookmark | Share | Chat | Listen Steps]
Profile ➔ [View Bookmarks | Settings]
```
### 💡 Tiny Improvements You Could Add Later:
- Dark Mode toggle
- Ratings for recipes (5⭐ system)
- Upload your own Recipe (future version)
## Download and Setup Instructions
### 1. Install Flutter and Setup Android Studio
You can install Flutter and set up Android Studio following this: [YouTube Video](https://www.youtube.com/watch?v=mMeQhLGD-og)
### 2. Wireless Debugging
You can run your Flutter app wirelessly. Follow this: [YouTube Video](https://www.youtube.com/watch?v=p2bsfBA6Ixg)

## Team Name
### DU_CodeBots🤖

## Authors
- Anika Sanzida Upoma (Roll-02)
- Suraya Jannat Mim (Roll-17)
- Ishrat Jahan Mim (Roll-52)
- Tasmia Sultana Sumi (Roll-54)

