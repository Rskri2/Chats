import 'package:chatapp/services/bloc/auth_bloc.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:chatapp/services/bloc/auth_state.dart';
import 'package:chatapp/services/firebase_auth_provider.dart';
import 'package:chatapp/views/loading/loading_screen.dart';
import 'package:chatapp/views/chats/chat_home.dart';
import 'package:chatapp/views/auth/forgot_password.dart';
import 'package:chatapp/views/auth/login.dart';
import 'package:chatapp/views/auth/register.dart';
import 'package:chatapp/views/auth/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: HomePage(),

      ),

    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(AuthEventInitialise());
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingScreen().show(context: context, text: state.loadingText);
          }
          else{
            LoadingScreen().hide();
          }

        },
        builder: (context, state) {
          if (state is AuthStateLoggedOut) {
            return Login();
          } else if (state is AuthStateRegistering) {
            return Register();
          } else if (state is AuthStateNeedsVerification) {
            return VerifyEmail();
          } else if (state is AuthStateForgotPassword) {
            return ForgotPassword();
          } else if (state is AuthStateLoggedIn) {
            return ChatHome();
          } else{
             return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
