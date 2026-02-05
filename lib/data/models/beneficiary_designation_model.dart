/// Modèles pour la désignation de bénéficiaire en cas de décès
/// Contrats retraite

/// Type de désignation
enum DesignationType {
  nominative, // Bénéficiaires nominatifs
  standardClause, // Clause type
  freeClause, // Clause libre
}

/// Type de démembrement
enum DismembermentType {
  none, // Pleine propriété
  usufruct, // Usufruit
  bareOwnership, // Nue-propriété
}

/// Mode de répartition
enum DistributionMode {
  percentage, // Répartition en pourcentages
  equalParts, // Parts égales
}

/// Relation avec le souscripteur
enum BeneficiaryRelationship {
  spouse, // Conjoint
  partner, // Partenaire PACS
  child, // Enfant
  grandchild, // Petit-enfant
  parent, // Parent
  sibling, // Frère/Soeur
  other, // Autre
}

extension BeneficiaryRelationshipExtension on BeneficiaryRelationship {
  String get label {
    switch (this) {
      case BeneficiaryRelationship.spouse:
        return 'Conjoint(e)';
      case BeneficiaryRelationship.partner:
        return 'Partenaire PACS';
      case BeneficiaryRelationship.child:
        return 'Enfant';
      case BeneficiaryRelationship.grandchild:
        return 'Petit-enfant';
      case BeneficiaryRelationship.parent:
        return 'Parent';
      case BeneficiaryRelationship.sibling:
        return 'Frère/Soeur';
      case BeneficiaryRelationship.other:
        return 'Autre';
    }
  }
}

/// Clauses types prédéfinies
enum StandardClauseType {
  spouseOnly, // Conjoint seul
  spouseThenChildren, // Conjoint, à défaut enfants
  childrenOnly, // Enfants par parts égales
  spouseThenChildrenThenHeirs, // Conjoint, à défaut enfants, à défaut héritiers
  heirs, // Héritiers légaux
}

extension StandardClauseTypeExtension on StandardClauseType {
  String get label {
    switch (this) {
      case StandardClauseType.spouseOnly:
        return 'Mon conjoint';
      case StandardClauseType.spouseThenChildren:
        return 'Mon conjoint, à défaut mes enfants';
      case StandardClauseType.childrenOnly:
        return 'Mes enfants, par parts égales';
      case StandardClauseType.spouseThenChildrenThenHeirs:
        return 'Mon conjoint, à défaut mes enfants, à défaut mes héritiers';
      case StandardClauseType.heirs:
        return 'Mes héritiers légaux';
    }
  }

  String get description {
    switch (this) {
      case StandardClauseType.spouseOnly:
        return 'Le capital sera versé intégralement à votre conjoint marié.';
      case StandardClauseType.spouseThenChildren:
        return 'Le capital sera versé à votre conjoint. En cas de décès de celui-ci avant vous, le capital sera versé à vos enfants par parts égales.';
      case StandardClauseType.childrenOnly:
        return 'Le capital sera versé à vos enfants, vivants ou représentés, par parts égales entre eux.';
      case StandardClauseType.spouseThenChildrenThenHeirs:
        return 'Le capital sera versé à votre conjoint. À défaut, à vos enfants par parts égales. À défaut, à vos héritiers légaux.';
      case StandardClauseType.heirs:
        return 'Le capital sera versé à vos héritiers légaux selon les règles de la succession.';
    }
  }
}

/// Bénéficiaire nominatif détaillé
class NominativeBeneficiary {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String? birthPlace;
  final BeneficiaryRelationship relationship;
  final String? otherRelationship; // Si relationship == other
  final String? address;
  final String? postalCode;
  final String? city;
  final int rank; // Rang de priorité (1, 2, 3...)
  final double percentage; // Pourcentage de répartition
  final DismembermentType dismembermentType;
  final String? linkedBeneficiaryId; // Pour démembrement: ID du nu-propriétaire/usufruitier lié

  NominativeBeneficiary({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    this.birthPlace,
    required this.relationship,
    this.otherRelationship,
    this.address,
    this.postalCode,
    this.city,
    required this.rank,
    required this.percentage,
    this.dismembermentType = DismembermentType.none,
    this.linkedBeneficiaryId,
  });

  String get fullName => '$firstName $lastName';

  String get relationshipLabel {
    if (relationship == BeneficiaryRelationship.other && otherRelationship != null) {
      return otherRelationship!;
    }
    return relationship.label;
  }

  String get dismembermentLabel {
    switch (dismembermentType) {
      case DismembermentType.none:
        return 'Pleine propriété';
      case DismembermentType.usufruct:
        return 'Usufruit';
      case DismembermentType.bareOwnership:
        return 'Nue-propriété';
    }
  }

  NominativeBeneficiary copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? birthPlace,
    BeneficiaryRelationship? relationship,
    String? otherRelationship,
    String? address,
    String? postalCode,
    String? city,
    int? rank,
    double? percentage,
    DismembermentType? dismembermentType,
    String? linkedBeneficiaryId,
  }) {
    return NominativeBeneficiary(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      relationship: relationship ?? this.relationship,
      otherRelationship: otherRelationship ?? this.otherRelationship,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      rank: rank ?? this.rank,
      percentage: percentage ?? this.percentage,
      dismembermentType: dismembermentType ?? this.dismembermentType,
      linkedBeneficiaryId: linkedBeneficiaryId ?? this.linkedBeneficiaryId,
    );
  }
}

/// Modèle principal de désignation de bénéficiaire
class BeneficiaryDesignation {
  final String id;
  final String contractId;
  final String contractName;
  final DesignationType designationType;

  // Pour désignation nominative
  final List<NominativeBeneficiary> nominativeBeneficiaries;
  final DistributionMode distributionMode;

  // Pour clause type
  final StandardClauseType? standardClauseType;

  // Pour clause libre
  final String? freeClauseText;

  // Métadonnées
  final DateTime createdAt;
  final DateTime? signedAt;
  final String? signatureReference;
  final bool isSigned;
  final String? pdfPath;

  BeneficiaryDesignation({
    required this.id,
    required this.contractId,
    required this.contractName,
    required this.designationType,
    this.nominativeBeneficiaries = const [],
    this.distributionMode = DistributionMode.percentage,
    this.standardClauseType,
    this.freeClauseText,
    required this.createdAt,
    this.signedAt,
    this.signatureReference,
    this.isSigned = false,
    this.pdfPath,
  });

  /// Vérifie si la répartition est valide (100% pour chaque rang)
  bool get isDistributionValid {
    if (designationType != DesignationType.nominative) return true;
    if (distributionMode == DistributionMode.equalParts) return true;

    // Grouper par rang et vérifier que chaque rang totalise 100%
    final Map<int, double> rankTotals = {};
    for (final beneficiary in nominativeBeneficiaries) {
      rankTotals[beneficiary.rank] =
          (rankTotals[beneficiary.rank] ?? 0) + beneficiary.percentage;
    }

    return rankTotals.values.every((total) => (total - 100).abs() < 0.01);
  }

  /// Obtient les bénéficiaires par rang
  Map<int, List<NominativeBeneficiary>> get beneficiariesByRank {
    final Map<int, List<NominativeBeneficiary>> result = {};
    for (final beneficiary in nominativeBeneficiaries) {
      result.putIfAbsent(beneficiary.rank, () => []);
      result[beneficiary.rank]!.add(beneficiary);
    }
    return Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );
  }

  /// Obtient le texte de la clause pour le PDF
  String get clauseText {
    switch (designationType) {
      case DesignationType.standardClause:
        return standardClauseType?.label ?? '';
      case DesignationType.freeClause:
        return freeClauseText ?? '';
      case DesignationType.nominative:
        return _generateNominativeClauseText();
    }
  }

  String _generateNominativeClauseText() {
    final buffer = StringBuffer();
    final byRank = beneficiariesByRank;

    for (final entry in byRank.entries) {
      final rank = entry.key;
      final beneficiaries = entry.value;

      if (rank > 1) {
        buffer.write('\n\nÀ défaut, ');
      }

      if (distributionMode == DistributionMode.equalParts) {
        buffer.write('par parts égales entre : ');
      }

      for (int i = 0; i < beneficiaries.length; i++) {
        final b = beneficiaries[i];
        if (i > 0) buffer.write(', ');

        buffer.write('${b.fullName}, né(e) le ${_formatDate(b.birthDate)}');
        if (b.birthPlace != null) buffer.write(' à ${b.birthPlace}');
        buffer.write(' (${b.relationshipLabel})');

        if (distributionMode == DistributionMode.percentage) {
          buffer.write(' pour ${b.percentage.toStringAsFixed(0)}%');
        }

        if (b.dismembermentType != DismembermentType.none) {
          buffer.write(' en ${b.dismembermentLabel.toLowerCase()}');
        }
      }
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  BeneficiaryDesignation copyWith({
    String? id,
    String? contractId,
    String? contractName,
    DesignationType? designationType,
    List<NominativeBeneficiary>? nominativeBeneficiaries,
    DistributionMode? distributionMode,
    StandardClauseType? standardClauseType,
    String? freeClauseText,
    DateTime? createdAt,
    DateTime? signedAt,
    String? signatureReference,
    bool? isSigned,
    String? pdfPath,
  }) {
    return BeneficiaryDesignation(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      contractName: contractName ?? this.contractName,
      designationType: designationType ?? this.designationType,
      nominativeBeneficiaries: nominativeBeneficiaries ?? this.nominativeBeneficiaries,
      distributionMode: distributionMode ?? this.distributionMode,
      standardClauseType: standardClauseType ?? this.standardClauseType,
      freeClauseText: freeClauseText ?? this.freeClauseText,
      createdAt: createdAt ?? this.createdAt,
      signedAt: signedAt ?? this.signedAt,
      signatureReference: signatureReference ?? this.signatureReference,
      isSigned: isSigned ?? this.isSigned,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }
}
