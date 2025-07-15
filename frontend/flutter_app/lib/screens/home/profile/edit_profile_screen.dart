import 'package:flutter/material.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/core/secure_storage.dart';
import 'package:flutter_app/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Future<ProfileModel>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfileData();
  }

  Future<ProfileModel> _fetchProfileData() async {
    final token = await SecureStorage.getToken();
    return await AuthService().getProfile(token ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<ProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error loading profile data'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return EditProfileBody(profile: snapshot.data!);
          } else {
            return const Center(child: Text('No profile data found.'));
          }
        },
      ),
    );
  }
}

class EditProfileBody extends ConsumerStatefulWidget {
  const EditProfileBody({super.key, required this.profile});

  final ProfileModel profile;

  @override
  ConsumerState<EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends ConsumerState<EditProfileBody> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.profile.firstName,
    );
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _emailController = TextEditingController(text: widget.profile.email);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();

      // Create updated profile model
      final updatedProfile = ProfileModel(
        id: widget.profile.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        createdAt: widget.profile.createdAt,
        updatedAt: DateTime.now(),
      );

      // Call API to update profile
      await AuthService().updateProfile(token ?? '', updatedProfile);

      // Invalidate auth provider to refresh profile data
      ref.invalidate(authProvider);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );

        // Navigate back to profile screen with result
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final username = '${widget.profile.firstName} ${widget.profile.lastName}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile picture section (same as original)
            Container(
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.teal, width: 4),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal[100],
                child: Text(
                  username[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[900],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                // TODO: Implement profile picture change functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile picture update coming soon'),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt, size: 16),
              label: const Text('Change Photo'),
              style: TextButton.styleFrom(foregroundColor: Colors.teal),
            ),
            const SizedBox(height: 30),

            // Form fields
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: _validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: _validateName,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // TODO: Fix email changes
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),

            // Action buttons
            SizedBox(
              width: screenWidth * 0.7,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProfile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isLoading ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: screenWidth * 0.7,
              child: OutlinedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                      },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
