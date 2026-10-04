import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../models/depense.dart';
import 'add_depense_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Dépenses'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Firebase.apps.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 72, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune dépense enregistrée',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ajoutez votre première dépense pour commencer',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('depenses')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur : ${snapshot.error}'),
                  );
                }

                final depenses = snapshot.data?.docs ?? [];

                if (depenses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 72, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucune dépense enregistrée',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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

                return ListView.builder(
                  itemCount: depenses.length,
                  itemBuilder: (context, index) {
                    final doc = depenses[index];
                    final depense = Depense.fromMap(doc.data(), doc.id);
                    final categorie = depense.categorie;
                    final montant = depense.montant;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getCategoryColor(categorie),
                          child: Text(categorie.isNotEmpty ? categorie[0] : '?'),
                        ),
                        title: Text(
                          depense.nom,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${depense.date.day}/${depense.date.month}/${depense.date.year} · $categorie',
                        ),
                        trailing: Text(
                          '${montant.toStringAsFixed(2)} €',
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDepensePage()),
          );
        },
        child: const Icon(Icons.add),
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