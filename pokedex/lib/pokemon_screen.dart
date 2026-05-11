import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';

class PokemonScreen extends StatelessWidget {
  final Pokemon pokemon;
  final String docId;

  const PokemonScreen({super.key, required this.pokemon, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(pokemon.name),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PokemonCard(pokemon: pokemon),
            const SizedBox(height: 16),
            BattlePanel(pokemon: pokemon, docId: docId),
          ],
        ),
      ),
    );
  }
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage: NetworkImage(pokemon.spriteUrl),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pokemon.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final type in pokemon.types) ...[
                      Chip(
                        label: Text(type),
                        backgroundColor: Colors.deepPurple.shade50,
                        labelStyle:
                            TextStyle(color: Colors.deepPurple.shade700),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BattlePanel extends StatefulWidget {
  final Pokemon pokemon;
  final String docId;

  const BattlePanel({super.key, required this.pokemon, required this.docId});

  @override
  State<BattlePanel> createState() => _BattlePanelState();
}

class _BattlePanelState extends State<BattlePanel> {
  int hp = 100;
  int xp = 0;
  late int level;

  @override
  void initState() {
    super.initState();
    level = widget.pokemon.level;
  }

  Color get hpColor {
    if (hp > 60) return Colors.green;
    if (hp > 30) return Colors.yellow;
    return Colors.red;
  }

  String get statusMessage {
    if (hp == 0) return '${widget.pokemon.name} desmaiou!';
    if (hp <= 30) return 'HP crítico!';
    return '';
  }

  void _atacar() {
    setState(() {
      hp = (hp - 20).clamp(0, 100);
      xp = xp + 10;
      if (xp >= 100) {
        level++;
        xp = 0;
      }
    });
  }

  void _usarPocao() {
    setState(() {
      hp = (hp + 30).clamp(0, 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Nível $level',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _StatBar(label: 'HP', value: hp, maxValue: 100, color: hpColor),
            _StatBar(
                label: 'XP', value: xp, maxValue: 100, color: Colors.blue),
            if (statusMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                statusMessage,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: hp > 0 ? _atacar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Atacar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hp < 100 ? _usarPocao : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Usar Poção'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('pokemons')
                      .doc(widget.docId)
                      .update({'level': level});
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Encerrar Batalha'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;

  const _StatBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label   $value / $maxValue',
            style: TextStyle(color: Colors.grey.shade800, fontSize: 12),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final ratio = (value / maxValue).clamp(0.0, 1.0);
              return Stack(
                children: [
                  Container(
                    height: 12,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 12,
                    width: constraints.maxWidth * ratio,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
