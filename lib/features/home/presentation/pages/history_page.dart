import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/history/history_bloc.dart';
import 'package:qde_realme/features/home/history/history_event.dart';
import 'package:qde_realme/features/home/history/history_state.dart';
import 'package:qde_realme/features/home/history/history_type.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({
    super.key,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  late final String userId;

  @override
  void initState() {
    super.initState();
    userId = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.id;
    context.read<HistoryBloc>().add(
      HistoryGetFirstEvent(userId: userId),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<HistoryBloc>().add(
        HistoryGetNextEvent(userId: userId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryStateLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is HistoryStateError) {
            return Center(
              child: Text(state.failure.message),
            );
          }

          if (state is HistoryStateSuccess) {
            if (state.items.isEmpty) {
              return const Center(
                child: Text('История пуста'),
              );
            }

            final items = state.items;

            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (sepContext, index) {
                return const SizedBox(height: 20);
              },
              itemBuilder: (listContext, index) {
                final item = items[index];
                final type = HistoryType.fromString(item.type);

                final color = switch (type) {
                  HistoryType.imeiPending => Colors.yellow,
                  HistoryType.imeiAccepted => Colors.green,
                  HistoryType.imeiDeclined => Colors.red,
                  HistoryType.imeiPaid => Colors.grey,
                  HistoryType.userAccepted => Colors.green,
                  HistoryType.userDeclined => Colors.red,
                  HistoryType.userPending => Colors.yellow,
                  HistoryType.other => Colors.grey,
                };

                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.date?.toString() ?? '',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
