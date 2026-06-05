import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:registrai/routes/app_routes.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4332),
        title: const Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go(AppRoutes.chat),
        ),
      ),
      body: const Center(
        child: Text("Dashboard em construção..."),
      ),
    );
  }
}