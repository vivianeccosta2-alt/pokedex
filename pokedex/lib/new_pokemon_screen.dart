import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon_service.dart';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {
  late Future<List<String>> _searchFuture;
  final _queryController = TextEditingController();
  Map<String, dynamic>? _selected; // null = fase 1 (lista); preenchido = fase 2 (detalhes)
  bool _loadingDetails = false;
  
  final _levelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _searchFuture = fetchPokemonNames(); // Inicializa com os primeiros 20
  }

  @override
  void dispose() {
    _queryController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  void _buscar() {
    setState(() {
      final query = _queryController.text.trim().toLowerCase();
      if (query.isEmpty) {
        _searchFuture = fetchPokemonNames();
      } else {
        _searchFuture = fetchPokemonByName(query);
      }
    });
  }

  Future<void> _selectPokemon(String name) async {
    setState(() => _loadingDetails = true);
    try {
      final details = await fetchPokemonDetails(name);
      setState(() {
        _selected = details;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _loadingDetails = false);
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate() && _selected != null) {
      await FirebaseFirestore.instance.collection('pokemons').add({
        'name': _selected!['name'],
        'spriteUrl': _selected!['spriteUrl'], // Guardamos a URL diretamente
        'types': _selected!['types'], // A API já nos dá uma lista de strings
        'level': int.parse(_levelController.text),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Pokémon'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _selected == null ? _buildList() : _buildForm(),
    );
  }

  // FASE 1: Lista de Busca
  Widget _buildList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    hintText: 'Digite o nome do Pokémon...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _buscar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Icon(Icons.search),
              )
            ],
          ),
        ),
        if (_loadingDetails) 
          const LinearProgressIndicator(color: Colors.deepPurple),
        Expanded(
          child: FutureBuilder<List<String>>(
            future: _searchFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final names = snapshot.data!;
              if (names.isEmpty) {
                return const Center(child: Text('Nenhum Pokémon encontrado.'));
              }
              return ListView.builder(
                itemCount: names.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(names[i]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _selectPokemon(names[i]),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // FASE 2: Formulário e Preview
  Widget _buildForm() {
    final typesList = _selected!['types'] as List<String>;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Image.network(
                    _selected!['spriteUrl'], 
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (_selected!['name'] as String).toUpperCase(), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: typesList.map((t) => Chip(
                      label: Text(t, style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.deepPurple.shade300,
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => setState(() => _selected = null),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Trocar Pokémon'),
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _levelController,
            decoration: const InputDecoration(
              labelText: 'Nível (1 a 100)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Informe o nível';
              final lvl = int.tryParse(value);
              if (lvl == null || lvl < 1 || lvl > 100) return 'Deve ser entre 1 e 100';
              return null;
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _salvar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cadastrar', style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }
}