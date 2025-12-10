
# 🏥 Life Care — Multi-App Flutter Monorepo

A unified healthcare platform built with Flutter, containing **three standalone apps** designed for Admins, Doctors, and Patients.
Each app is isolated and developed independently within its own folder.

---

# 📱 Apps Included

```
life_care/
├── admin_ui/     # Admin App
├── doctor_ui/    # Doctor App
└── patient_ui/   # Patient App
```

---

## 🟦 ADMIN UI — (Admin Panel)

Central dashboard for managing the Life Care ecosystem.

### 🔐 Authentication

* Admin login

### 🩺 Doctor Management

* Add new doctors
* Verify / approve doctor accounts
* Edit doctor details
* Activate / deactivate / block doctors
* View list of all doctors with filters (specialization, status)

### 💊 Medicine Management

* Add new medicines
* Edit and update medicine details
* Delete medicines
* Upload medicine images
* Manage categories (tablets, syrups, injections etc.)
* Inventory overview

### 📅 Booking & Patient Monitoring 

* View all patient bookings
* Cancel or override bookings (in emergencies)
* View patients list and profiles

### 📊 Dashboard

* Total doctors
* Total patients
* Total bookings today
* Pending approvals

---

## 🟩 DOCTOR UI — (Doctor App)

A dedicated app for registered and approved doctors.

### 🔐 Authentication

* Register with medical details & documents
* Login with email/password
* Profile update

### 📅 Booking Management

* View all upcoming patient appointments
* Accept or reject booking requests
* Reschedule appointments
* Appointment reminders

### 👨‍⚕️ Patient Management

* View patient profile
* View booking history
* View past prescriptions

### 💊 Prescriptions / Medical Records

* Create digital prescriptions
* Add medicines, dosage, duration
* Upload attachments (e.g., reports)

### 📊 Doctor Dashboard

* Today’s appointments
* Patient statistics

---

## 🟧 PATIENT UI — (Patient App)

User-friendly app for patients to interact with healthcare services.

### 🔐 Authentication

* User login & registration
* Profile update
* Saved doctors & favorites

### 👨‍⚕️ Book a Doctor

* Browse doctors by specialization
* View doctor details, ratings, experience
* Real-time availability
* Book appointments
* Appointment reminders
* Cancel or reschedule

### 💊 Order Medicines

* View list of medicines
* Add to cart
* Checkout and place order
* Track order status

### 📄 Prescriptions & Reports

* View prescriptions given by doctors
* Download/view medical reports

### 🏠 Patient Dashboard

* Upcoming bookings
* Past appointments
* Medicine orders
* Health notifications

---

# ⚙️ Requirements

* Flutter (stable)
* Dart SDK
* Android SDK / Android Studio
* Xcode (for iOS)
* Firebase account + Firebase CLI (if using Firebase)

---

# 🚀 Quick Start (for any app)

### 1️⃣ Navigate to specific UI

```bash
cd admin_ui
# or
cd doctor_ui
# or
cd patient_ui
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Setup Firebase

* Add `google-services.json` → `android/app/`
* Add `GoogleService-Info.plist` → `ios/Runner/`
* Update `firebase_options.dart` if regenerated using:

```bash
flutterfire configure
```

### 4️⃣ Run the app

```bash
flutter run
```


# 📁 Project Structure for each folder

```
android/   – Android platform code  
ios/       – iOS platform code  
lib/       – Dart source files (main.dart entry)  
web/       – Web support  
macos/     – macOS support  
linux/     – Linux support  
windows/   – Windows support  
test/      – Unit & widget tests  
```

---

# 🧪 Development Tools

```bash
flutter analyze      # Static analysis
flutter test         # Run tests
flutter format lib/** 
```

---

# 🔮 Future Enhancements (Optional Section)


* 🔄 Real-time chat between doctor & patient
* 🧾 Printable PDF prescriptions
* 💳 Stripe or Razorpay payment gateway
* 🩺 Video consultations (WebRTC)
* 📍 Location-based doctor search
* 🔔 Push notifications (Firebase Cloud Messaging)
* 📦 Medicine delivery tracking
* 🧠 AI symptom checker (future integration)

---


