import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../state/avatar_cache.dart';
import 'package:legal_case_manager/features/profile/screens/profile_screen.dart';


class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Row(
      children: [
        /// AVATAR WITH LIVE UPDATE
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: ValueListenableBuilder<File?>(
            valueListenable: AvatarCache.notifier,
            builder: (context, avatar, _) {
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String initial = 'U';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    if (data != null && data.containsKey('name') && data['name'] != null) {
                      final name = data['name'].toString();
                      if (name.isNotEmpty) {
                        initial = name[0].toUpperCase();
                      }
                    }
                  }


                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    backgroundImage:
                    avatar != null ? FileImage(avatar) : null,
                    child: avatar == null
                        ? Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(width: 12),

        /// SEARCH
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {},
        ),
      ],
    );
  }
}






