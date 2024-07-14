### Chat App

Chat App that allows user to chat with each other. Users can create an account and send messages to other users.

URL: https://group-project-one-team-f-fa683.web.app

### ⚙ Technologies Used
- `Flutter` as the front-end framework
- `Firebase` as database and authentication

#### 🏃‍♀️ Running the app locally

_Clone_ this app, then:

```bash
cp lib/config/firebase_options.dart.example lib/config/firebase_options.dart
# fill in your firebase api keys under firebase_options.dart

flutter pub get
flutter run -d chrome
```


For hosting the app on firebase:
```
flutter build web
firebase experiments:enable webframeworks
firebase init hosting
firebase deploy
```
