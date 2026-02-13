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

  @override
  void initState() {
    super.initState();
    _image = AvatarCache.image;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
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
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------- IMAGE METHODS ----------------
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _removeAvatar = false;
      });
    }
  }

  // ---------------- LOCATION METHODS ----------------
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
      _toast("Error detecting location: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- SAVE ALL ----------------
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String manualAddress = _addressController.text.trim();

      // Attempt to Geocode if the address was typed manually
      if (manualAddress.isNotEmpty) {
        try {
          final query = Uri.encodeComponent(manualAddress);
          final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
          final response = await http.get(url, headers: {'User-Agent': 'legal_case_manager'});

          if (response.statusCode == 200) {
            final List data = json.decode(response.body);
            if (data.isNotEmpty) {
              _officeLat = double.parse(data[0]['lat']);
              _officeLng = double.parse(data[0]['lon']);
            }
          }
        } catch (e) {
          debugPrint("Manual Geocoding failed: $e");
        }
      }

      Map<String, dynamic> updates = {
        'name': _nameController.text.trim(),
        'officeAddress': manualAddress,
        'officeLat': _officeLat,
        'officeLng': _officeLng,
      };

      await FirebaseFirestore.instance.collection('users').doc(widget.lawyerId).update(updates);

      if (_passwordController.text.trim().length >= 6) {
        await user.updatePassword(_passwordController.text.trim());
      }

      if (_removeAvatar) {
        AvatarCache.image = null;
      } else if (_image != null) {
        AvatarCache.image = _image;
      }

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
      appBar: AppBar(title: const Text('Edit Lawyer Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null ? const Icon(Icons.camera_alt, size: 40) : null,
                  ),
                ),
                if (_image != null)
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => setState(() { _image = null; _removeAvatar = true; }),
                  )
              ],
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          const Text("Office Location", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter address manually or use GPS',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.my_location, color: Colors.blue),
                onPressed: _detectLocation,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password (Optional)', border: OutlineInputBorder()),
          ),

          // Add this inside the ListView in your build method, before the 'Save Profile' button
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.blue),
            ),
            icon: const Icon(Icons.description),
            label: const Text('Manage Professional Portfolio'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LawyerPortfolioEditor(lawyerId: widget.lawyerId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          const SizedBox(height: 30),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              onPressed: _saveChanges,
              child: const Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }
}