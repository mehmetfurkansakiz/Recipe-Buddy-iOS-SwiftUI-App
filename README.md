-----

# 🧁 Recipe Buddy

**Recipe Buddy** is a modern, SwiftUI-based iOS application designed for recipe lovers. It provides a seamless experience for discovering, creating, and managing recipes, complete with a powerful shopping list feature. The app is built with a modern tech stack, featuring Supabase for the backend and AWS S3 for image storage, making it a robust and scalable solution.

## ✨ Features

  - **🥞 Full Recipe Management (CRUD):** Users can create, view, edit, and delete their personal recipes with an intuitive, multi-step creation process.
  - **🔐 User Authentication:** Secure sign-up and login functionality powered by Supabase Auth.
  - **🏠 Dynamic Home Feed:** A beautiful home screen featuring top-rated ("Öne Çıkanlar") recipes and a "Discover" ("Keşfet") section with infinite scrolling.
  - **🔍 Advanced Search & Filtering:** Easily search for public recipes or filter them by category.
  - **❤️ Favorites & Ratings:** Users can favorite recipes from the community and give them a star rating.
  - **📝 Personal Recipe Book:** A dedicated tab to view your own created recipes and the ones you've favorited.
  - **🛒 Smart Shopping List:**
      - Create and manage multiple shopping lists.
      - Add all ingredients from a recipe to a list with a single tap.
      - Intelligently combines duplicate ingredients, summing their amounts.
      - Check off items as you shop.
  - **👤 User Profiles:** A profile screen displaying user stats like total recipes and favorites received.
  - **☁️ Cloud Image Storage:** Recipe images are efficiently handled and served via AWS S3 and CloudFront CDN.

## 🛠️ Technology Stack & Architecture

### Tech Stack

  - **UI Framework:** [SwiftUI](https://www.google.com/search?q=https://developer.apple.com/xcode/swiftui/)
  - **Backend as a Service:** [Supabase](https://supabase.io/)
      - **Database:** Supabase Postgres
      - **Authentication:** Supabase Auth
      - **APIs:** Supabase PostgREST & RPCs for custom functions.
  - **Image Storage:** [Amazon S3](https://aws.amazon.com/s3/)
  - **Content Delivery Network (CDN):** [Amazon CloudFront](https://aws.amazon.com/cloudfront/)
  - **Asynchronous Image Loading:** [Nuke](https://github.com/kean/Nuke)
  - **Dependencies:** Swift Package Manager (SPM)

### Architecture

The project follows a modern and scalable architecture:

  - **MVVM (Model-View-ViewModel):** The UI is separated from the business logic, making the codebase clean and maintainable.
  - **Coordinator Pattern:** An `AppCoordinator` manages the main navigation flow, deciding whether to show the authentication flow or the main app content.
  - **Singleton Services:** Network operations are handled by singleton services (`RecipeService`, `UserService`, etc.) for easy access and state management.
  - **DataManager:** A central `DataManager` class, implemented as an `ObservableObject`, acts as the single source of truth for user-specific data (owned recipes, favorites, etc.) and is provided to the views through the SwiftUI `Environment`.
  - **NotificationCenter:** Used to broadcast changes (like a new recipe being created or a favorite status changing) across the app to ensure all relevant views update in real-time.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

  - Xcode 15 or later
  - An Apple Developer account (for running on a physical device)

### Installation & Setup

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/your-username/RecipeBuddy.git
    cd RecipeBuddy
    ```

2.  **Open the project in Xcode:**
    Open the `Recipe Buddy.xcodeproj` file. Xcode will automatically resolve all Swift Package Manager dependencies.

3.  **Configure Backend Keys:**
    The project requires API keys for Supabase and AWS to function.

      - In the `RecipeBuddy/Recipe Buddy/Data/Network/` directory, create a new file named `Keys.plist`.
      - Right-click the file, choose "Open As" -\> "Source Code", and paste the following content.
      - **Replace the placeholder values** with your actual keys from your Supabase and AWS accounts.

    <!-- end list -->

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>CloudFrontDomain</key>
        <string>https://your-cloudfront-domain.net</string>
        <key>SupabaseURL</key>
        <string>https://your-project-id.supabase.co</string>
        <key>SupabaseKey</key>
        <string>your-supabase-anon-key</string>
        <key>AWSAccessKeyID</key>
        <string>your-aws-access-key-id</string>
        <key>AWSSecretAccessKey</key>
        <string>your-aws-secret-access-key</string>
        <key>S3BucketName</key>
        <string>your-s3-bucket-name</string>
        <key>S3Region</key>
        <string>your-s3-bucket-region</string>
    </dict>
    </plist>
    ```

4.  **Build and Run:**
    Select your target simulator or device and run the project (Cmd+R).

### Supabase Backend

This project relies on a specific Supabase database schema and several RPCs (Remote Procedure Calls) for functionalities like toggling favorites or fetching aggregated counts. You will need to set up your own Supabase project and replicate the necessary tables and functions.

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` file for more information.

-----
