import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/depense.dart';

class DepenseService {
  // ─────────────────────────────────────────────
  // 📁 Référence à la collection Firestore
  // ─────────────────────────────────────────────
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('depenses');

  // ─────────────────────────────────────────────
  // ➕ CREATE : Ajouter une dépense
  // ─────────────────────────────────────────────
  Future<void> ajouterDepense(Depense depense) async {
    await _collection.add(depense.toMap());
  }

  // ─────────────────────────────────────────────
  // 📖 READ : Stream temps réel (trié par date desc)
  // ─────────────────────────────────────────────

  Stream<List<Depense>> getDepenses() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Depense.fromMap(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  // ─────────────────────────────────────────────
  // ✏️ UPDATE : Modifier une dépense
  // ─────────────────────────────────────────────
  Future<void> modifierDepense(Depense depense) async {
    if (depense.id == null) return;
    await _collection.doc(depense.id).update(depense.toMap());
  }

  // ─────────────────────────────────────────────
  // 🗑️ DELETE : Supprimer une dépense
  // ─────────────────────────────────────────────
  Future<void> supprimerDepense(String id) async {
    await _collection.doc(id).delete();
  }

  // ─────────────────────────────────────────────
  // 💰 STATS : Calculer le total des dépenses
  // ─────────────────────────────────────────────
  Future<double> getTotalDepenses() async {
    final snapshot = await _collection.get();
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      total += (data['montant'] ?? 0).toDouble();
    }
    return total;
  }

  // ─────────────────────────────────────────────
  // 📊 STATS : Total par catégorie
  // ─────────────────────────────────────────────
  Future<Map<String, double>> getTotalParCategorie() async {
    final snapshot = await _collection.get();
    final Map<String, double> totaux = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final cat = data['categorie'] ?? 'Autre';
      final montant = (data['montant'] ?? 0).toDouble();
      totaux[cat] = (totaux[cat] ?? 0) + montant;
    }
    return totaux;
  }
}