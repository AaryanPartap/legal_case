import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../common/state/avatar_cache.dart';

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
  bool _removeAvatar = false;
  bool _isLoading = false;

  // Track coordinates locally so we can save them for the client's map
  double? _officeLat;
  double? _officeLng;

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

  // ---------------- IMAGE PICKER ----------------
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _removeAvatar = false;
      });
    }
  }

  // ---------------- GPS LOCATION DETECTION ----------------
  Future<void> _detectLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=18');
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

  // ---------------- SAVE ALL CHANGES ----------------
  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String manualAddress = _addressController.text.trim();

      double? finalLat = _officeLat;
      double? finalLng = _officeLng;

      // Geocoding: If the user typed an address manually, try to get coordinates for the map
      if (manualAddress.isNotEmpty) {
        try {
          final query = Uri.encodeComponent(manualAddress);
          final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1');
          final response = await http.get(url, headers: {'User-Agent': 'legal_case_manager'});

          if (response.statusCode == 200) {
            final List data = json.decode(response.body);
            if (data.isNotEmpty) {
              finalLat = double.parse(data[0]['lat']);
              finalLng = double.parse(data[0]['lon']);
            }
          }
        } catch (e) {
          debugPrint("Geocoding failed, using last known coordinates: $e");
        }
      }

      // 1. Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.lawyerId).update({
        'name': _nameController.text.trim(),
        'officeAddress': manualAddress,
        'officeLat': finalLat,
        'officeLng': finalLng,
      });

      // 2. Update Password if provided
      if (_passwordController.text.trim().length >= 6) {
        await user.updatePassword(_passwordController.text.trim());
      }

      // 3. Sync Avatar Cache
      if (_removeAvatar) {
        AvatarCache.image = null;
      } else if (_image != null) {
        AvatarCache.image = _image;
      }

      _toast("Profile updated successfully");
      if (mounted) Navigator.pop(context);
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
          // Avatar
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
                    child: _image == null ? const Icon(Icons.person, size: 50) : null,
                  ),
                ),
                if (_image != null)
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() { _image = null; _removeAvatar = true; }),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
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
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Enter address manually or use GPS icon',
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