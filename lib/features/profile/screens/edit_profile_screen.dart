import 'dart:io'; // ✅ Fixes 'File' isn't a type
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Fixes 'XFile' and 'ImagePicker'
import '../../../common/state/avatar_cache.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage; // Local file holder
  bool _isLoading = false;

  final Color primaryDark = const Color(0xFF0F172A);
  final Color accentBlue = const Color(0xFF2563EB);
  final Color backgroundSlate = const Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    // ✅ Use your existing mechanism: Load from cache
    _selectedImage = AvatarCache.image;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        _nameController.text = doc.data()?['name'] ?? '';
        _phoneController.text = doc.data()?['phone'] ?? '';
      });
    }
  }

  // ✅ LOCAL STORAGE MECHANISM: Pick image and save to Cache
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // ✅ Existing mechanism: Update the global cache immediately
      AvatarCache.image = _selectedImage;
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // Save text data to Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        // Note: For local-only, we just rely on AvatarCache.image
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Updated Locally"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundSlate,
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 32),
                _buildFormCard([
                  _buildModernField(_nameController, "Full Name", Icons.person_outline),
                  const Divider(height: 32),
                  _buildModernField(_phoneController, "Phone Number", Icons.phone_outlined, keyboardType: TextInputType.phone),
                ]),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15)],
            ),
            child: CircleAvatar(
              radius: 65,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? Icon(Icons.person, size: 55, color: accentBlue)
                  : null,
            ),
          ),
          GestureDetector(
            onTap: _pickImage, // ✅ Triggers the new local pick function
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: accentBlue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Keep your _buildFormCard, _buildModernField, and _buildSaveButton as they were)
  // Just ensure _buildSaveButton calls _saveProfile()

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildModernField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
        border: InputBorder.none,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: _saveProfile,
        child: const Text("SAVE PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}