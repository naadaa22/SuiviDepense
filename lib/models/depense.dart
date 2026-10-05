class Depense {
  final String? id;
  final String nom;
  final double montant;
  final String categorie;
  final DateTime date;

  Depense({
    this.id,
    required this.nom,
    required this.montant,
    required this.categorie,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'montant': montant,
      'categorie': categorie,
      'date': date.toIso8601String(),
    };
  }

  factory Depense.fromMap(Map<String, dynamic> map, String id) {
    return Depense(
      id: id,
      nom: map['nom'] ?? '',
      montant: (map['montant'] as num?)?.toDouble() ?? 0.0,
      categorie: map['categorie'] ?? 'Autre',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    );
  }
}