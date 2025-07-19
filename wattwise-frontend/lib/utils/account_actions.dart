// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../views/auth/login_page.dart';
// import 'dart:convert';

// /// Logs out the current user and navigates to the login screen.
// Future<void> logoutUser(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('token');
//   await prefs.remove('fullName');

//   if (context.mounted) {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginPage()),
//       (_) => false,
//     );
//   }
// }

// /// Confirms and deletes the user's account from the backend.
// Future<void> confirmDeleteAccount(BuildContext context) async {
//   final confirmed = await showDialog<bool>(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: const Text("Confirm Deletion"),
//       content: const Text(
//         "Are you sure you want to delete your account? This cannot be undone.",
//       ),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text("Cancel")),
//         ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text("Delete")),
//       ],
//     ),
//   );

//   if (confirmed != true) return;

//   final prefs = await SharedPreferences.getInstance();
//   final token = prefs.getString('token');

//   try {
//     final response = await http.delete(
//       Uri.parse("http://192.168.132.146:8000/api/auth/delete"),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       await prefs.clear();
//       if (context.mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginPage()),
//           (_) => false,
//         );
//       }
//     } else {
//       final msg = json.decode(response.body)['msg'] ?? "Delete failed";
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//     }
//   } catch (_) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Network error")),
//     );
//   }
// }
