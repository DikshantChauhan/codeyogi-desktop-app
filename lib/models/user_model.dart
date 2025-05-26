class User {
  final String id;
  final String name;
  final String password;
  final bool isGuest;
  final int? maxLevelCount;
  final String? maxSubLevelId;
  final int? currentLevelCount;
  final String? currentSubLevelId;

  User({
    required this.id,
    required this.name,
    required this.password,
    required this.isGuest,
    this.maxLevelCount,
    this.maxSubLevelId,
    this.currentLevelCount,
    this.currentSubLevelId,
  });

  User copyWith({
    String? id,
    String? name,
    String? password,
    bool? isGuest,
    int? maxLevelCount,
    String? maxSubLevelId,
    int? currentLevelCount,
    String? currentSubLevelId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      isGuest: isGuest ?? this.isGuest,
      maxLevelCount: maxLevelCount ?? this.maxLevelCount,
      maxSubLevelId: maxSubLevelId ?? this.maxSubLevelId,
      currentLevelCount: currentLevelCount ?? this.currentLevelCount,
      currentSubLevelId: currentSubLevelId ?? this.currentSubLevelId,
    );
  }

  factory User.fromMap(Map<String, dynamic> data) {
    //validate data
    if (data.containsKey('name') && data.containsKey('password')) {
      return User(
        id: data['id'],
        name: data['name'],
        password: data['password'],
        isGuest: data['isGuest'],
        maxLevelCount: data['maxLevelCount'],
        maxSubLevelId: data['maxSubLevelId'],
        currentLevelCount: data['currentLevelCount'],
        currentSubLevelId: data['currentSubLevelId'],
      );
    }
    throw Exception('Invalid data');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'isGuest': isGuest,
      'maxLevelCount': maxLevelCount,
      'maxSubLevelId': maxSubLevelId,
      'currentLevelCount': currentLevelCount,
      'currentSubLevelId': currentSubLevelId,
    };
  }

  // Added an equality operator and hashCode, so Riverpod can correctly determine
  // if the user object has changed.  This is crucial for proper state management.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.password == password &&
        other.isGuest == isGuest;
  }

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ password.hashCode ^ isGuest.hashCode;
}
