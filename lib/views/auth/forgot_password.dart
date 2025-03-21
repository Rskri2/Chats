import 'package:chatapp/services/bloc/auth_bloc.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/bloc/auth_state.dart';
import '../dialog/show_error_dialog.dart';
import '../dialog/show_password_reset_dialog.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late final TextEditingController _emailController;
  late final GlobalKey<FormState> _globalKey;

  @override
  void initState() {
    _emailController = TextEditingController();
    _globalKey = GlobalKey<FormState>();


    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state)async{
        if(state is AuthStateForgotPassword){
          if(state.didSendEmail){
            _emailController.clear();
            await showPasswordResetDialog(context: context);
          }
          if(state.exception != null){
            await showErrorDialog(context: context, content: 'We could not process your request. Make sure that you are a registered user');
          }
        }
      },
        child: Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(5.0),
          child: const Text('Register', style: TextStyle(color: Colors.white)),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child:SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Welcome back',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const Text(
                'Forgot password?Enter email address to receive password reset email!',
              ),
              Form(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email)
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autofocus: true,
                        autocorrect: false,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 10.0,
                      ),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_globalKey.currentState!.validate()) {
                              final email = _emailController.text;

                              context.read<AuthBloc>().add(AuthEventForgotPassword(email: email));

                            }
                          },
                          child: const Text('Reset password'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Center(
                child: TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthEventLogout());
                  },
                  child: Text("Click here to login"),
                ),
              ),
            ],
          ),
        )

      ),
    ));
  }
}
