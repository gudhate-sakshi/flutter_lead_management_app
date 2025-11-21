import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/theme/app_theme.dart';
import '/presentation/provider/theme_provider.dart';
import '/presentation/provider/lead_provider.dart';
import '/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
   
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LeadProvider()),
      ],
      child: const LeadManagerApp(),
    ),
  );
}

class LeadManagerApp extends StatelessWidget {
  const LeadManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Lead Manager',
      debugShowCheckedModeBanner: false,
      
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode, 
      
      home: const HomeScreen(),
    );
  }
}