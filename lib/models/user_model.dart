// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime createdAt;
  final UserPreferences preferences;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoURL,
    required this.createdAt,
    required this.preferences,
  });

  // Create from Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? 'User',
      email: data['email'] ?? '',
      photoURL: data['photoURL'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      preferences: UserPreferences.fromMap(data['preferences'] ?? {}),
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
      'preferences': preferences.toMap(),
    };
  }

  // Create from Firebase User
  factory UserModel.fromFirebaseUser(
    String uid,
    String email,
    String name, {
    String? photoURL,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      photoURL: photoURL,
      createdAt: DateTime.now(),
      preferences: UserPreferences.defaultPreferences(),
    );
  }

  // Copy with
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    DateTime? createdAt,
    UserPreferences? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
    );
  }
}

class UserPreferences {
  final bool notifications;
  final bool darkMode;
  final String language;

  UserPreferences({
    required this.notifications,
    required this.darkMode,
    this.language = 'en',
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      notifications: map['notifications'] ?? true,
      darkMode: map['darkMode'] ?? false,
      language: map['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'darkMode': darkMode,
      'language': language,
    };
  }

  factory UserPreferences.defaultPreferences() {
    return UserPreferences(
      notifications: true,
      darkMode: false,
      language: 'en',
    );
  }

  UserPreferences copyWith({
    bool? notifications,
    bool? darkMode,
    String? language,
  }) {
    return UserPreferences(
      notifications: notifications ?? this.notifications,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
    );
  }
}