import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/mainScreen.dart';
import 'stores/challengesStore.dart';
import 'stores/studioStore.dart';
import 'stores/sessionStore.dart';

void main() {
  runApp(const MeuJogoApp());
}

class MeuJogoApp extends StatelessWidget {
  const MeuJogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SessionStore()),
        ChangeNotifierProvider(create: (context) => ChallengesStore()),
        ChangeNotifierProvider(create: (context) => StudioStore()),
      ],
      child: MaterialApp(
        title: 'Quiz Game',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667eea)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
