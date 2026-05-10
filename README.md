# AppCrew Notes – Flutter + Firebase Technical Assignment

Built as part of a Flutter Developer technical assessment to showcase production-ready Flutter development, Firebase integration, and defensive application architecture.

---

# 📱 Features

## 🔐 Authentication
- Firebase Email & Password Authentication
- Secure login & signup flow
- Persistent user sessions after app restart
- Proper validation and error handling

## 📝 Notes Management (CRUD)
Each authenticated user can:
- Create notes
- Read/View notes
- Update existing notes
- Delete notes

### Note Schema
Each note contains:
- `id`
- `title`
- `content`
- `created_at`
- `updated_at`
- `user_id`

### Security
Notes are securely scoped per authenticated user using Firestore paths:

```text
users/{userId}/notes/{noteId}
```

A user can only access their own notes.

---

## 🌐 Offline Handling (Assignment Option A)

Implemented offline-aware behavior using the `connectivity_plus` package to ensure stable and predictable UX during network interruptions.

### Features
- Detects active network connectivity changes in real time
- Prevents app crashes when internet is unavailable
- Displays a graceful offline alert/banner to inform the user
- Disables note actions while offline:
  - Create Note
  - Update Note
  - Delete Note
- Prevents failed Firebase write operations during connectivity loss
- Handles timeout/loading states safely to avoid frozen UI behavior

---

## 🎨 UI & UX
- Clean monochrome design system
- Responsive layouts
- Dark & Light theme support
- Loading indicators & defensive UI states
- Adaptive Android app icons

---

# 🏛️ Architecture

The application follows a **Feature-First Layered Architecture** to ensure scalability, maintainability, and separation of concerns.

## Folder Structure

```text
lib/
├── core/          # App-wide configurations (routing, themes, errors)
├── features/      # Feature modules (auth, notes)
├── models/        # Data models/entities
├── providers/     # State management & business logic
├── services/      # Firebase & external integrations
└── widgets/       # Reusable UI components
```

---

# 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Flutter | Frontend Framework |
| Firebase Authentication | User Authentication |
| Cloud Firestore | Notes Database |
| Provider | State Management |
| connectivity_plus | Network State Detection |
| internet_connection_checker_plus | Real Internet Validation |
| shared_preferences | Local Theme Persistence |

---

# 💎 Engineering Highlights

## Two-Step Internet Validation
Most applications only check device connectivity status, which can produce false positives when connected to WiFi without internet access.

This app uses:
- `connectivity_plus`
- `internet_connection_checker_plus`

to validate both:
1. Physical network connection
2. Actual internet reachability

This prevents Firebase requests from hanging indefinitely.

---

## Centralized Error Handling
Implemented:
- `AsyncResult<T>`
- `Failure` abstraction
- Error mappers

This ensures:
- Predictable async flows
- Consistent UI error handling
- No silent crashes

---

## Defensive Async Lifecycle Handling
The app includes:
- `.timeout()` guarded Firebase operations
- `context.mounted` checks
- Global async exception handling
- Graceful recovery states

---

# 🔥 Firebase Setup

## Authentication
Enabled:
- Email/Password Authentication

## Firestore Structure

```text
users (collection)
 └── userId (document)
      └── notes (subcollection)
           └── noteId
```

---

# 🧹 Code Quality

This project emphasizes:
- Null safety
- Clean architecture
- Reusable widgets
- Scalable folder organization
- Defensive programming
- Readable and maintainable code

Reusable atomic widgets include:
- `CustomButton`
- `CustomTextField`
- `OfflineBanner`

---

# ⚠️ Assumptions & Trade-offs

- Chose `Provider` for simplicity, scalability, and strong Flutter ecosystem integration.
- Firestore subcollections were used to enforce user-level data isolation cleanly.
- Offline handling was prioritized over search functionality as the assignment’s optional feature.

---

# 🙏 Thank You

Thank you for taking the time to review this assignment submission.

I approached this project with a strong focus on:
- clean architecture,
- production-ready engineering practices,
- secure Firebase integration,
- and resilient user experience handling.

I truly appreciate the opportunity to showcase my Flutter development skills through this assignment.

Looking forward to your feedback.