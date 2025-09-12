import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/mainScreen.dart';
import 'stores/slidesStore.dart';

void main() {
  runApp(const MeuJogoApp());
}

class MeuJogoApp extends StatelessWidget {
  const MeuJogoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SlidesStore(),
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
