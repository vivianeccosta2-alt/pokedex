import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  
  // Variável para guardar qual avatar foi clicado
  int _selectedAvatar = 0; 
  
  final List<String> _avatars = [
    'assets/trainers/trainer_1.png',
    'assets/trainers/trainer_2.png',
    'assets/trainers/trainer_3.png',
    'assets/trainers/trainer_4.png',
    'assets/trainers/trainer_5.png',
    'assets/trainers/trainer_6.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance
        .collection('config')
        .doc('treinador')
        .get();
        
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameController.text = data['name'] as String? ?? '';
        _selectedAvatar = data['avatarIndex'] as int? ?? 0;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      
      await FirebaseFirestore.instance
          .collection('config')
          .doc('treinador')
          .set({
        'name': _nameController.text,
        'avatarIndex': _selectedAvatar,
      }, SetOptions(merge: true)); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil salvo!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Treinador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do treinador',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'O nome deve ter no mínimo 2 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              const Text('Escolha seu avatar:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAvatar == index;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                        ),
                        child: Image.asset(_avatars[index]),
                      ),
                    );
                  },
                ),
              ),
              
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}