import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_screen.dart';
import 'new_pokemon_screen.dart';
import 'trainer_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final collection = FirebaseFirestore.instance.collection('pokemons');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Pokédex'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
  
        leading: _buildTrainerAvatar(), 

        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrainerProfileScreen()),
              );
              setState(() {}); 
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewPokemonScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: _buildPokemonList(), 
    );
  }

  Widget _buildTrainerAvatar() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('config').doc('treinador').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          );
        }
        
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final avatarIndex = data['avatarIndex'] as int? ?? 0;
          final imageNumber = avatarIndex + 1; 
          
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade300,
              backgroundImage: AssetImage('assets/trainers/trainer_$imageNumber.png'),
            ),
          );
        }
        
        return const Icon(Icons.person_outline);
      },
    );
  }

  Widget _buildPokemonList() {
    return StreamBuilder(
      stream: collection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Nenhum Pokémon cadastrado.'));
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final docId = docs[index].id;
                        
            final String urlDaImagem = data.containsKey('spriteUrl') 
                ? data['spriteUrl'] as String 
                : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${data['spriteId']}.png';

            final pokemon = Pokemon(
              name: data['name'] as String,
              types: List<String>.from(data['types'] as List),
              spriteUrl: urlDaImagem,
              level: data['level'] as int,
            );

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: NetworkImage(pokemon.spriteUrl),
                ),
                title: Text(pokemon.name),
                subtitle: Text('${pokemon.types.join(' / ')} · Nível ${pokemon.level}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                  onPressed: () => collection.doc(docId).delete(),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PokemonScreen(pokemon: pokemon, docId: docId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}