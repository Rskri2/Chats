import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:chatapp/services/bloc/auth_event.dart';
import 'package:chatapp/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_auth_provider.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  late final UserService userService;
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AuthBloc(FirebaseAuthProvider provider)
    : super(AuthStateUninitialised(isLoading: true)) {
    on<AuthEventInitialise>((event, emit) async {
      await provider.initialise();


      flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings,
      );

      flutterLocalNotificationsPlugin.initialize(initSettings);
       setupFirebaseMessaging();
      final user = provider.getUser;
      if (user == null) {
        emit(AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.emailVerified) {
        emit(AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });
    on<AuthEventForgotPassword>((event, emit) async {
      final email = event.email;
      emit(
        AuthStateForgotPassword(
          exception: null,
          didSendEmail: false,
          isLoading: false,
        ),
      );
      if (email == null) {
        return;
      }
      try {
        await provider.sendPasswordResetEmail(email: email);
        emit(
          AuthStateForgotPassword(
            exception: null,
            didSendEmail: true,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateForgotPassword(
            exception: e,
            didSendEmail: false,
            isLoading: false,
          ),
        );
      }
    });
    on<AuthEventShouldRegister>((event, emit) async {
      emit(AuthStateRegistering(exception: null, isLoading: false));
    });
    on<AuthEventLogout>((event, emit) async {
      try {
        await provider.logout();
        emit(AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      final name = event.name;
      emit(
        AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while registering',
        ),
      );
      try {
        await provider.register(email: email, password: password, name: name);
        userService = UserService();
        await userService.createUser();

        await provider.sendEmailVerification(email: email);

        emit(AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });
    on<AuthEventLogin>((event, emit) async {
      emit(
        AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while logging in',
        ),
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.signIn(email: email, password: password);

        if (!user!.emailVerified) {
          emit(AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedOut(exception: null, isLoading: false));
          emit(AuthStateLoggedIn(isLoading: false, user: user));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    on<AuthEventSendVerification>((event, emit) {
      final user = FirebaseAuth.instance.currentUser;
      user?.sendEmailVerification();
      emit(state);
    });
  }
  void setupFirebaseMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("New Notification: ${message.notification?.title}");

      showNotification(message.notification?.title ?? "No Title",
          message.notification?.body ?? "No Body");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("User opened notification: ${message.notification?.title}");
    });
  }

  void showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel Name
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }
}


