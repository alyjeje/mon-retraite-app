import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user_model.dart';

/// Donnees profil retournees par le BFF (inclut la liste des contrats)
class ProfilData {
  final UserModel user;
  final List<ContractSummary> contracts;

  ProfilData({required this.user, required this.contracts});
}

/// Resume d'un contrat (retourne avec le profil)
class ContractSummary {
  final double scont;
  final int codeCb;
  final String type;
  final String typeLabel;
  final String name;
  final String reference;
  final String startDate;
  final bool isActive;

  ContractSummary({
    required this.scont,
    required this.codeCb,
    required this.type,
    required this.typeLabel,
    required this.name,
    required this.reference,
    required this.startDate,
    required this.isActive,
  });

  factory ContractSummary.fromJson(Map<String, dynamic> json) {
    return ContractSummary(
      scont: (json['scont'] as num).toDouble(),
      codeCb: json['codeCb'] ?? 0,
      type: json['type'] ?? '',
      typeLabel: json['typeLabel'] ?? '',
      name: json['name'] ?? '',
      reference: json['reference'] ?? '',
      startDate: json['startDate'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }
}

class ProfilRepository {
  final ApiClient _api;

  ProfilRepository(this._api);

  Future<ProfilData> getProfil() async {
    final data = await _api.get(ApiEndpoints.profil);

    final user = UserModel(
      id: data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: AddressModel(
        street: data['address']?['street'] ?? '',
        complement: data['address']?['complement'],
        postalCode: data['address']?['postalCode'] ?? '',
        city: data['address']?['city'] ?? '',
      ),
      birthDate: DateTime.tryParse(data['birthDate'] ?? '') ?? DateTime(1970),
      isProfileComplete: true,
      lastLogin: DateTime.now(),
    );

    final contracts = (data['contracts'] as List? ?? [])
        .map((c) => ContractSummary.fromJson(c))
        .toList();

    return ProfilData(user: user, contracts: contracts);
  }

  Future<void> updateAddress({
    required String street,
    String? complement,
    required String postalCode,
    required String city,
  }) async {
    await _api.put(ApiEndpoints.profilAddress, body: {
      'street': street,
      'complement': complement,
      'postalCode': postalCode,
      'city': city,
    });
  }

  Future<void> updateEmail(String email) async {
    await _api.put(ApiEndpoints.profilEmail, body: {'email': email});
  }

  Future<void> updatePhone(String phone) async {
    await _api.put(ApiEndpoints.profilPhone, body: {'phone': phone});
  }
}
