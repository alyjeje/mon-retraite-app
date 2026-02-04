/// Modèle Utilisateur
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final AddressModel address;
  final DateTime birthDate;
  final bool isProfileComplete;
  final bool hasBiometricEnabled;
  final bool has2FAEnabled;
  final DateTime lastLogin;
  final List<String> connectedDevices;
  final DateTime? memberSince;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.address,
    required this.birthDate,
    this.isProfileComplete = false,
    this.hasBiometricEnabled = false,
    this.has2FAEnabled = false,
    required this.lastLogin,
    this.connectedDevices = const [],
    this.memberSince,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}

/// Modèle Adresse
class AddressModel {
  final String street;
  final String? complement;
  final String postalCode;
  final String city;
  final String country;

  AddressModel({
    required this.street,
    this.complement,
    required this.postalCode,
    required this.city,
    this.country = 'France',
  });

  String get fullAddress => '$street, $postalCode $city';
}

/// Modèle Bénéficiaire
class BeneficiaryModel {
  final String id;
  final String firstName;
  final String lastName;
  final String relationship;
  final double percentage;
  final int priority;
  final DateTime birthDate;
  final bool isArchived;

  BeneficiaryModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.relationship,
    required this.percentage,
    required this.priority,
    required this.birthDate,
    this.isArchived = false,
  });

  String get fullName => '$firstName $lastName';
}
