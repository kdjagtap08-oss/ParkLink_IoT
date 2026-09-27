# ParkLink IoT

ParkLink IoT is a Flutter mobile app, backed by Firebase (Realtime Database + Authentication), that shows live parking slot availability across multiple campus parking locations. It combines real IoT sensor data with admin-managed demo data, and supports two user roles with distinct feature sets.

## Features

### Authentication
- Email/password signup and login (Firebase Authentication)
- Show/hide password toggle on login and signup screens
- Sign-out with confirmation prompt

### User Features
- Browse all parking locations with a live count of empty slots per location
- Tap into a location to view a theater-seat-style visual map of its slots
  - Slots are color-coded: green (empty), red (occupied)
  - Map layout mirrors each location's real shape (L / T / Linear)
  - Pinch-to-zoom and pan supported for smaller screens
- **Search All Lots** — scan every location at once and list every currently empty slot campus-wide, regardless of location

### Admin Features
- Admin dashboard listing every parking location and its slots
- Manually toggle any *demo* slot between empty and occupied
  - Sensor-backed slots are protected and shown as read-only
- Dedicated Gate Status screen to view and set the shared entry gate as open or closed

## Parking Locations

| Location | Slots | Shape | Data Source |
|---|---|---|---|
| Parking behind E Building | 10 (4 sensor-backed, consecutive) | L-shaped | 4 real sensors + 6 demo |
| Parking between B & C Building | 11 | T-shaped | Demo |
| Parking between C & D Building | 11 | T-shaped | Demo |
| VU Parking | 15 | Linear | Demo |

All four locations share a single common entry gate.

## Tech Stack

- **Frontend:** Flutter
- **Backend:** Firebase Realtime Database (live JSON data store)
- **Auth:** Firebase Authentication (Email/Password)
- **Hardware:** ESP32 (for the 4 real sensor slots at E Building)

## Data Model (Realtime Database structure)

```
locations/
  e_building/
    name: "Parking behind E Building"
    layout_shape: "L"
    total_slots: 10
    slots/
      1: { status: "empty", source_type: "demo" }
      ...
      3-6: { status: "...", source_type: "sensor" }
  vu_parking/
    name: "VU Parking"
    layout_shape: "Linear"
    total_slots: 15
    slots/ ...

gate/
  status: "open" | "closed"

users/
  {uid}/
    role: "admin" | "sensor"   (absent = regular user)
```

## Roles & Access Control

Access is enforced server-side via Firebase Security Rules:
- Any logged-in user can read `locations` and `gate`
- Only an `admin` can write to a slot marked `source_type: demo`
- Only the dedicated `sensor` account can write to slots marked `source_type: sensor`, and to `gate`
- A user can only read their own role at `/users/{uid}`

## Hardware Integration (ESP32)

One ESP32 device controls all 4 sensor-backed slots at E Building. It:
- Connects to WiFi and authenticates as a dedicated Firebase "sensor" account
- Sends an update **only when a slot's status changes** (event-driven, not continuous polling)
- Writes directly to the Realtime Database using Firebase's REST API

A simulation sketch exists that randomly toggles the 4 sensor slots and the gate status, useful for testing the app end-to-end before wiring up real sensors.

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Set up a Firebase project with Realtime Database and Authentication (Email/Password) enabled
4. Run `flutterfire configure` to link the project to your Firebase project
5. Seed the database with your parking locations and slots (see Data Model above)
6. Run `flutter run`