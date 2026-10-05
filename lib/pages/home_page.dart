import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/depense.dart';
import 'add_depense_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Dépenses'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // 🔑 FILTRE : uniquement les dépenses de l'utilisateur connecté
        stream: FirebaseFirestore.instance
            .collection('depenses')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          // Tri côté client (évite de créer un index composite)
          final depenses = (snapshot.data?.docs ?? []).toList()
            ..sort((a, b) {
              final da = a.data()['date'] ?? '';
              final db = b.data()['date'] ?? '';
              return db.compareTo(da); // plus récentes d'abord
            });

          if (depenses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune dépense enregistrée',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre première dépense pour commencer',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          double total = 0;
          for (final doc in depenses) {
            final d = Depense.fromMap(doc.data(), doc.id);
            total += d.montant;
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.deepPurple.shade50,
                child: Column(
                  children: [
                    Text(
                      'Bonjour ${user.email ?? ""}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total des dépenses',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: depenses.length,
                  itemBuilder: (context, index) {
                    final doc = depenses[index];
                    final depense = Depense.fromMap(doc.data(), doc.id);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getCategoryColor(depense.categorie),
                          child: Text(
                            depense.categorie.isNotEmpty
                                ? depense.categorie[0]
                                : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          depense.nom,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${depense.date.day}/${depense.date.month}/${depense.date.year} · ${depense.categorie}',
                        ),
                        trailing: Text(
                          '${depense.montant.toStringAsFixed(2)} €',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                        onLongPress: () =>
                            _supprimerDepense(context, doc.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDepensePage()),
          );
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _supprimerDepense(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer ?'),
        content:
            const Text('Voulez-vous vraiment supprimer cette dépense ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('depenses')
                  .doc(id)
                  .delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Nourriture':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Loisirs':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}