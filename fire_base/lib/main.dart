import 'package:fire_base/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:fire_base/auth/login.dart';
import 'package:fire_base/ui/home.dart';
import 'chatbot/generative_model_service.dart';
import 'chatbot/generative_model_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider<GenerativeChatService>(
          create: (_) => GenerativeChatService(),
        ),
        ChangeNotifierProvider<ChatViewModel>(
          create: (context) => ChatViewModel(
            Provider.of<GenerativeChatService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const Home();
            } else {
              return const LoginPage();
            }
          },
        ),
      ),
    );
  }
}
