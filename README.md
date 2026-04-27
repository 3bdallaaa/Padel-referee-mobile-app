# 🎾 Padel Score App

A Flutter application for scoring Padel matches with voice announcements and referee whistle sounds.

## Features

- **Live Match Scoring** — Track points, games, and sets for two teams
- **Voice Announcements** — Automated score calling with customizable speech speed
- **Referee Whistle** — Plays a whistle sound at 0-0 (match start and after each game)
- **Serve Indicator** — Visual indicator showing current server and serve side (right/left)
- **Server Rotation** — Automatic server rotation following Padel rules
- **Match History** — Save and view past match results
- **Dark/Light Theme** — Toggle between dark and light modes
- **Undo Support** — Undo accidental point additions

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) SDK
- A code editor (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd padel_score_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. **Setup Players** — Enter names for all 4 players (2 per team)
2. **Choose Starting Team** — Select which team serves first
3. **Select First Server** — Pick the starting server
4. **Start Match** — Tap "Start Match" to begin
5. **Score Points** — Tap the "+ POINT" button on the appropriate team card
6. **Listen** — The app will announce the score and play a whistle at the start of each game

### Match Rules

- Points follow standard tennis scoring: 0, 15, 30, 40, Deuce, Advantage
- Games are won by reaching 4 points with a 2-point margin
- Sets are won by reaching 6 games with a 2-game margin
- Serve alternates sides (right → left) after each point
- Serve rotates to the next player in the sequence after each game

## Assets

- `assets/sounds/referee_whistle.mp3` — Referee whistle sound played at the start of every new game (0-0)

## Dependencies

- `audioplayers` — Audio playback for the referee whistle
- `flutter_tts` — Text-to-speech for score announcements
- `shared_preferences` — Local storage for match history

## Platforms

- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Linux
