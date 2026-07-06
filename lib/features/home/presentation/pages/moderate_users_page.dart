import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import 'package:qde_realme/core/utils/app_constants.dart';
import 'package:qde_realme/features/auth/data/models/user_model.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';

import '../../moferate_users/moderate_users_bloc.dart';
import '../../moferate_users/moderate_users_event.dart';
import '../../moferate_users/moderate_users_state.dart';

class ModerateUsersPage extends StatefulWidget {
  const ModerateUsersPage({super.key});

  @override
  State<ModerateUsersPage> createState() => _ModerateUsersPageState();
}

class _ModerateUsersPageState extends State<ModerateUsersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // ТУТ ПИНАЕМ БЛОК НА СТАРТЕ (Поменяй на свой эвент, например LoadUsers())
    context.read<ModerateUsersBloc>().add(ModerateUsersGetFirstEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // ТУТ ПОДГРУЖАЕМ СЛЕДУЮЩУЮ ПАЧКУ (Поменяй на свой эвент, например GetNextUsers())
      context.read<ModerateUsersBloc>().add(ModerateUsersGetNextEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (int i = 0; i < 100; i++) {
            FirebaseFirestore.instance
                .collection(AppConstants.moderateUsers)
                .add(UserModel(id: '${i}', email: 'test', number: '', isModerated: false).toJson());
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text("MODERATE USERS PAGE"),
            Expanded(
              child: BlocBuilder<ModerateUsersBloc, ModerateUsersState>(
                builder: (context, state) {
                  if (state is ModerateUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ModerateUsersError) {
                    return const Center(child: Text("Error"));
                  }
                  if (state is ModerateUsersSuccess) {
                    if (state.items.isEmpty) {
                      return const Center(child: Text("Empty"));
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ModerateUsersBloc>().add(ModerateUsersGetFirstEvent());
                      },
                      child: ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount: state.items.length + (state.isMoreLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final user = state.items[index];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.blue),
                              child: Column(
                                children: [
                                  Text(user.id),
                                  Text(user.email),
                                  Text(user.number),
                                  Text('Moderated = ${user.isModerated.toString()}'),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          final userId =
                                              (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                                          context.read<ModerateUsersBloc>().add(
                                            ModerateUserEvent(userId: userId, isModerated: true),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('confirm'),
                                        ),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          final userId =
                                              (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
                                          context.read<ModerateUsersBloc>().add(
                                            ModerateUserEvent(userId: userId, isModerated: false),
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Text('decline'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  // Вместо пустого SizedBox возвращаем крутилку для Initial стейта
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
