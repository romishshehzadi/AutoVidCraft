// import 'package:flutter/material.dart';
//
// class GradientButton extends StatelessWidget {
//   final Widget child;
//   final VoidCallback onPressed;
//   final double height;
//   final double radius;
//
//   const GradientButton({
//     Key? key,
//     required this.child,
//     required this.onPressed,
//     this.height = 50,
//     this.radius = 16,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         height: height,
//         decoration: BoxDecoration(
//           gradient:  LinearGradient(
//             colors: [Colors.purple, Colors.blueAccent],
//           ),
//           borderRadius: BorderRadius.circular(radius),
//         ),
//         child: Center(child: child),
//       ),
//     );
//   }
// }
