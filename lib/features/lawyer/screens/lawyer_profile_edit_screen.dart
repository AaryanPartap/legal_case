import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../common/state/avatar_cache.dart';
import 'package:legal_case_manager/features/lawyer/screens/lawyer_portfolio_editor.dart';

class LawyerProfileEditScreen extends StatefulWidget {
  final String lawyerId;
  const LawyerProfileEditScreen({super.key, required this.lawyerId});

  @override
  State<LawyerProfileEditScreen> createState() => _LawyerProfileEditScreenState();
}

class _LawyerProfileEditScreenState extends State<LawyerProfileEditScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  File? _image;
  double? _officeLat;
  double? _officeLng;
  bool _removeAvatar = false;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF0F172A); // Midnight Blue
  final Color accentColor = const Color(0xFF2563EB); // Royal Blue

  @override
  void initState() {
    super.initState();
    _image = AvatarCache.image;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(widget.lawyerId).get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _nameController.text = data?['name'] ?? '';
          _addressController.text = data?['officeAddress'] ?? '';
          _officeLat = data?['officeLat'];
          _officeLng = data?['officeLng'];
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _removeAvatar = false;
      });
    }
  }

  Future<void> _detectLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18');
      final response = await http.get(url, headers: {'User-Agent': 'legal_case_manager'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _addressController.text = data['display_name'] ?? 'Unknown Location';
          _officeLat = position.latitude;
          _officeLng = position.longitude;
        });
      }
    } catch (e) {
      _toast("Location error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'officeAddress': _addressController.text.trim(),
        'officeLat': _officeLat,
        'officeLng': _officeLng,
      };

      await FirebaseFirestore.instance.collection('users').doc(widget.lawyerId).update(updates);

      if (_passwordController.text.trim().length >= 6) {
        await FirebaseAuth.instance.currentUser!.updatePassword(_passwordController.text.trim());
      }

      AvatarCache.image = _removeAvatar ? null : (_image ?? AvatarCache.image);
      _toast("Profile updated successfully");
      Navigator.pop(context);
    } catch (e) {
      _toast("Update failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildSectionHeader("Account Details"),
              _buildCard([
                _buildTextField(_nameController, "Full Name", Icons.person_outline),
                const Divider(height: 32),
                _buildTextField(_passwordController, "New Password", Icons.lock_outline, obscure: true),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader("Office Location"),
              _buildCard([
                _buildTextField(
                    _addressController,
                    "Office Address",
                    Icons.location_on_outlined,
                    maxLines: 2,
                    suffix: IconButton(
                      icon: Icon(Icons.my_location, color: accentColor),
                      onPressed: _detectLocation,
                    )
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionHeader("Professional Settings"),
              _buildPortfolioButton(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 30),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue.shade50,
              backgroundImage: _image != null ? FileImage(_image!) : null,
              child: _image == null ? Icon(Icons.person, size: 60, color: accentColor) : null,
            ),
          ),
          CircleAvatar(
            backgroundColor: accentColor,
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
              onPressed: _pickImage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, int maxLines = 1, Widget? suffix}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixIcon: suffix,
        border: InputBorder.none,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        floatingLabelStyle: TextStyle(color: accentColor),
      ),
    );
  }

  Widget _buildPortfolioButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LawyerPortfolioEditor(lawyerId: widget.lawyerId))),
        leading: Icon(Icons.article_outlined, color: accentColor),
        title: const Text("Manage Portfolio", style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Text("Experience, Specialization, Docs"),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [accentColor, const Color(0xFF1E40AF)]),
        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _saveChanges,
        child: const Text('SAVE PROFILE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
      ),
    );
  }
}