MissU

A private iOS app built with SwiftUI + Firebase, designed for two people to send simple “I miss you” signals and keep a shared history.

This project focuses on clean architecture, real-time sync, and a lightweight, intimate user experience.

---

Features:

- ❤️ One-tap “I miss you” interaction
- 🔄 Real-time sync across two devices (Firebase Firestore)
- 🕰 Chat-style history view with automatic scroll to latest message
- 📍 Records time and place (when available)
- 🔔 Local notifications for incoming messages

---

Key adjustments needed if you want to use:

1. currentUser: Modify currentUser to be either me or her to make it suitable for both ends
2. startDate: Modify startDate to be your own relationship start time!
3. fireBase: Setup your own firebase project and retrieve your personal .plist file. The free account is enough for this app.

---

Required Frameworks

1. FirebaseCore
2. FirebaseFirestore
3. FirebaseMessaging

---

Misc.

1. Sending real time notification (notifying while the app is not running) is a feature exclusive for apple developer accounts. Since I do not possess an apple developer account, this app can only send notifications while the app is running.

2. Distribution of the app is also not allowed for personal apple accounts.
