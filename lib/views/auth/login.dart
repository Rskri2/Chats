import 'package:chatapp/services/exceptions.dart';
import 'package:chatapp/services/bloc/auth_bloc.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/bloc/auth_state.dart';
import '../dialog/show_error_dialog.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(
              context: context,
              content: 'Could not find user with given credentials',
            );
          } else if (state.exception is WrongPasswordAuthException) {
            await showErrorDialog(
              context: context,
              content: 'Wrong credentials',
            );
          }
          else if(state.exception is CouldNotFindUserAuthException){
            await showErrorDialog(context: context, content: 'Could not find user with given credentials');
          }
          else if(state.exception != null){
            await showErrorDialog(context: context, content: 'Failed to login');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: EdgeInsets.all(16.0),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  'Welcome back',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const Text('Sign in to continue'),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email),
                          ),

                          keyboardType: TextInputType.emailAddress,
                          autofocus: true,
                          autocorrect: false,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: Icon(Icons.visibility_off),
                          ),
                          autocorrect: false,
                          obscureText: true,
                          autofocus: true,
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.0,
                        ),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final email = _emailController.text;
                                final password = _passwordController.text;
                                context.read<AuthBloc>().add(
                                  AuthEventLogin(
                                    email: email,
                                    password: password,
                                  ),
                                );
                              }
                            },
                            child: const Text('Login'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Center(
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthEventShouldRegister());
                    },
                    child: Text("Don't have an account? Register"),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        AuthEventForgotPassword(email: null),
                      );
                    },
                    child: Text("Forgot password? Click here to reset"),
                  ),
                ),
              ],
            ),
          )

        ),
      ),
    );
  }
}
