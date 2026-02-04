import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../common/state/avatar_cache.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  File? _image;          // preview image
  bool _removeAvatar = false;

  @override
  void initState() {
    super.initState();
    _image = AvatarCache.image; // ✅ preload existing avatar
  }

  // ---------------- PICK IMAGE ----------------
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _removeAvatar = false;
      });
    }
  }

  // ---------------- DELETE AVATAR ----------------
  void _deleteAvatar() {
    setState(() {
      _image = null;
      _removeAvatar = true;
    });
  }

  // ---------------- SAVE ----------------
  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser!;
    final uid = user.uid;

    /// Update name
    if (_nameController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'name': _nameController.text.trim()});
    }

    /// Update password
    if (_passwordController.text.trim().length >= 6) {
      await user.updatePassword(_passwordController.text.trim());
    }

    /// Commit avatar
    if (_removeAvatar) {
      AvatarCache.image = null;
    } else if (_image != null) {
      AvatarCache.image = _image;
    }

    Navigator.pop(context);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            /// AVATAR + DELETE BUTTON
            Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue,
                    backgroundImage:
                    _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 36,
                    )
                        : null,
                  ),
                ),

                /// DELETE ICON (visible if avatar exists)
                if (_image != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: _deleteAvatar,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            /// NAME
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// PASSWORD
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password (min 6 chars)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
