// import 'package:flutter/material.dart';

// class WelcomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('assets/logo.png'), // Replace with your logo image path
//             SizedBox(height: 20),
//             Text(
//               'Safe - Strong and empowered community',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Welcome',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/login');
//               },
//               style: ElevatedButton.styleFrom(
//                 primary: Colors.red,
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//               ),
//               child: Text('Login'),
//             ),
//             SizedBox(height: 20),
//             OutlinedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/register');
//               },
//               style: OutlinedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//                 side: BorderSide(color: Colors.black), // Border color
//               ),
//               child: Text('Register', style: TextStyle(color: Colors.black)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
