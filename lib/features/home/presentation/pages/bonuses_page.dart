import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/home/bonuses/bonuses_event.dart';

import '../../bonuses/bonuses_bloc.dart';
import '../../bonuses/bonuses_state.dart';

class BonusesPage extends StatefulWidget {
  const BonusesPage({super.key});

  @override
  State<BonusesPage> createState() => _BonusesPageState();
}

class _BonusesPageState extends State<BonusesPage> {
  Map<String, String> _editableBonuses = {};
  List<TextEditingController> _keyControllers = [];
  List<TextEditingController> _valueControllers = [];

  @override
  void initState() {
    super.initState();
    context.read<BonusesBloc>().add(BonusesGetEvent());
  }

  @override
  void dispose() {
    for (var controller in _keyControllers) {
      controller.dispose();
    }
    for (var controller in _valueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Бонусы'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              final Map<String, String> updatedMap = {};
              for (int i = 0; i < _keyControllers.length; i++) {
                final newKey = _keyControllers[i].text.trim();
                final newValue = _valueControllers[i].text.trim();
                if (newKey.isNotEmpty) {
                  updatedMap[newKey] = newValue;
                }
              }
              context.read<BonusesBloc>().add(BonusesUpdateEvent(bonuses: updatedMap));
            },
          ),
        ],
      ),
      body: BlocBuilder<BonusesBloc, BonusesState>(
        builder: (context, state) {
          if (state is BonusesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BonusesUpdateSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<BonusesBloc>().add(BonusesGetEvent());
            });
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BonusesSuccess) {
            final Map<String, String> bonuses = state.bonuses;

            if (bonuses.isEmpty) {
              return const Center(child: Text('Список бонусов пуст'));
            }

            _editableBonuses = Map.from(bonuses);
            _keyControllers = _editableBonuses.keys.map((k) => TextEditingController(text: k)).toList();
            _valueControllers = _editableBonuses.values.map((v) => TextEditingController(text: v)).toList();

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _keyControllers.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 20),
              itemBuilder: (ctx, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _keyControllers[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Название',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _valueControllers[index],
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Значение',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: UnderlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (state is BonusesError) {
            return Center(child: Text('Ошибка: ${state.failure}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
