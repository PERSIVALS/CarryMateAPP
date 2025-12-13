import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class ProfileSummary extends StatelessWidget {
  final UserProfile profile;
  const ProfileSummary({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(profile.email),
        Text('Steps: ${profile.steps}'),
        Text('Calories: ${profile.calories}'),
      ],
    );
  }
}