import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewPokemonScreen extends StatefulWidget {
  const NewPokemonScreen({super.key});

  @override
  State<NewPokemonScreen> createState() => _NewPokemonScreenState();
}

class _NewPokemonScreenState extends State<NewPokemonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _spriteController = TextEditingController();
  final _levelController = TextEditingController();

  final _spriteFocusNode = FocusNode();
  final _levelFocusNode = FocusNode();

  String _previewName = '';
  String? _selectedType;

  @override
  void dispose() {
    _nameController.dispose();
    _spriteController.dispose();
    _levelController.dispose();
    _spriteFocusNode.dispose();
    _levelFocusNode.dispose();
    super.dispose();
  }

  Future<void> _salvarPokemon() async {
    // 1. Valida o formulário
    if (!_formKey.currentState!.validate()) return;

    // 2. Salva no Firestore
    await FirebaseFirestore.instance.collection('pokemons').add({
      'name': _nameController.text.trim(),
      'spriteId': int.parse(_spriteController.text),
      'level': int.parse(_levelController.text),
      'types': [_selectedType], // Salvando como array
    });

    // 3. Volta para a tela anterior
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Pokémon'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // PREVIEW DO NOME
            if (_previewName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Cadastrando: $_previewName...',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
              ),

            // CAMPO: NOME
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Pokémon',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _spriteFocusNode.requestFocus(),
              onChanged: (value) {
                setState(() {
                  _previewName = value.trim();
                });
              },
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'O nome deve ter no mínimo 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // CAMPO: SPRITE ID
            TextFormField(
              controller: _spriteController,
              focusNode: _spriteFocusNode,
              decoration: const InputDecoration(
                labelText: 'Sprite ID (1 a 1025)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _levelFocusNode.requestFocus(),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obrigatório';
                final id = int.tryParse(value);
                if (id == null || id < 1 || id > 1025) {
                  return 'ID inválido (1-1025)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // CAMPO: NÍVEL INICIAL
            TextFormField(
              controller: _levelController,
              focusNode: _levelFocusNode,
              decoration: const InputDecoration(
                labelText: 'Nível inicial (1 a 100)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Campo obrigatório';
                final level = int.tryParse(value);
                if (level == null || level < 1 || level > 100) {
                  return 'Nível inválido (1-100)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // CAMPO: TIPO (DROPDOWN)
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: [
                'Fogo', 'Água', 'Planta', 'Elétrico', 'Normal',
                'Psíquico', 'Gelo', 'Dragão'
              ].map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              validator: (value) => value == null ? 'Selecione um tipo' : null,
            ),
            const SizedBox(height: 32),

            // BOTÃO DE SALVAR
            ElevatedButton(
              onPressed: _salvarPokemon,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Salvar', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}