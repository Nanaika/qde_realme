import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:qde_realme/features/auth/presentation/bloc/auth_state.dart';
import 'package:qde_realme/features/home/bloc/confirm_account_bloc.dart';
import 'package:qde_realme/features/home/bloc/confirm_account_event.dart';
import 'package:qde_realme/features/home/bloc/confirm_account_state.dart';

class ConfirmAccountPage extends StatefulWidget {
  const ConfirmAccountPage({super.key});

  @override
  State<ConfirmAccountPage> createState() => _ConfirmAccountPageState();
}

class _ConfirmAccountPageState extends State<ConfirmAccountPage> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ConfirmAccountBloc, ConfirmAccountState>(
      builder: (BuildContext context, state) {
        if (state is ConfirmAccountLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const Text('CONFIRM ACCOUNT PAGE'),
                  const SizedBox(height: 50),

                  const Text('Enter tel number'),
                  TextField(decoration: InputDecoration(hint: Text('12345567890')), controller: controller,),
                  ElevatedButton(
                    onPressed: () {
                      final user = (context.read<AuthBloc>().state as AuthAuthenticated).currentUser.copyWith(number: controller.text);
                      context.read<ConfirmAccountBloc>().add(ConfirmEvent(user));
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      listener: (BuildContext context, state) {
        if (state is ConfirmAccountSuccess) {
          context.pop();
        } else if (state is ConfirmAccountError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.failure.message)));
        }
      },
    );
  }
}
