import 'dart:ui';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:registrai/providers/chat_provider.dart';
import 'package:registrai/providers/dashboard_provider.dart';
import 'package:registrai/routes/app_routes.dart';

void main () async{
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("pt_BR", null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp.router(
        title: 'RegistrAi',
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.router,
        
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B4332)
          ),
          useMaterial3: true,
        ),
      ),
    );
  }
}