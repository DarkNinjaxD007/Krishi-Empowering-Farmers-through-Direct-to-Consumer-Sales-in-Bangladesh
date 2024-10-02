import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Utils/constant.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? userProfile;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _isEditing = false;
  bool _isLoading = false;
  String _selectedAddress = "";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    fullNameController.addListener(_updateSaveButtonState);
    emailController.addListener(_updateSaveButtonState);
    phoneNumberController.addListener(_updateSaveButtonState);
    addressController.addListener(_updateSaveButtonState);
  }

  @override
  void dispose() {
    fullNameController.removeListener(_updateSaveButtonState);
    emailController.removeListener(_updateSaveButtonState);
    phoneNumberController.removeListener(_updateSaveButtonState);
    addressController.removeListener(_updateSaveButtonState);
    fullNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _updateSaveButtonState() {
    setState(() {});
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && mounted) {
          setState(() {
            userProfile = UserProfile(
              fullName: data['fullName'] ?? '',
              email: data['email'] ?? '',
              phoneNumber: data['phone_number'] ?? '',
              address: data['address'] ?? '',
              profilePhotoUrl: data['profilePhotoUrl'] ?? '',
              type: data['type'] ?? '',
            );
            fullNameController.text = userProfile!.fullName;
            emailController.text = userProfile!.email;
            phoneNumberController.text = userProfile!.phoneNumber;
            addressController.text = "";
            _selectedAddress = userProfile!.address;
          });
        }
      }
    }

    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }

  }

  Future<void> _updateProfile() async {

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && userProfile != null) {
      try {
        String photoUrl = userProfile!.profilePhotoUrl;
        if (_image != null) {
          photoUrl = await _uploadProfilePhoto(user.uid);
        }

        await FirebaseFirestore.instance.collection('user').doc(user.uid).update({
          'fullName': fullNameController.text,
          'email': emailController.text,
          'phone_number': phoneNumberController.text,
          'address': _selectedAddress,
          'profilePhotoUrl': photoUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('প্রোফাইল সফলভাবে আপডেট করা হয়েছে')),
        );

        _loadUserProfile();
        setState(() {
          _isEditing = false;
        });
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে আপডেট করা যায়নি। আবার চেষ্টা করুন।')),
        );
      }
    }
  }

  Future<String> _uploadProfilePhoto(String uid) async {
    // Create a reference to the file location in Firebase Storage
    final Reference storageRef = FirebaseStorage.instance.ref().child('profile_photos/$uid.jpg');

    // Upload the file to Firebase Storage
    final UploadTask uploadTask = storageRef.putFile(_image!);

    // Get the task snapshot
    final TaskSnapshot taskSnapshot = await uploadTask;

    // Get the download URL
    final String url = await taskSnapshot.ref.getDownloadURL();

    return url;
  }


  Future<void> _pickImage() async {
    if (_isEditing && _image == null) {
      try {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      } catch (e) {
        print('Error picking image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error picking image. Please try again.')),
        );
      }
    }
  }

  bool _canSaveProfile() {
    return fullNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        _selectedAddress.isNotEmpty;
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      if (userProfile != null) {
        fullNameController.text = userProfile!.fullName;
        emailController.text = userProfile!.email;
        phoneNumberController.text = userProfile!.phoneNumber;
        addressController.text = userProfile!.address;
        _image = null;
        _selectedAddress =userProfile!.address;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (userProfile == null) {
      return const Center(child: Text('প্রোফাইল ডাটা পাওয়া যায় নি'));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('প্রোফাইল পেজ'),
          actions: [
            if (_isEditing)
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: _cancelEditing,
              ),
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isEditing
                  ? () {
                if (_canSaveProfile()) {
                  _updateProfile();
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All Field are requird!')));
                  return;
                }
              }
                  : () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 42),
          children: [
            Center(
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : NetworkImage(userProfile!.profilePhotoUrl) as ImageProvider<Object>,
                    ),
                    if (_isEditing)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              _buildTextField(fullNameController, 'পুরো নাম'),
              _buildTextField(emailController, 'ইমেইল', inputType: TextInputType.emailAddress),
              _buildTextField(phoneNumberController, 'ফোন নাম্বার', inputType: TextInputType.phone),
              Column(
                children: [
                  // Autocomplete Text Field
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      } else {
                        return Constant.districtList.where((word) => word
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      }
                    },
                    onSelected: (selectedString) {
                      setState(() {
                        _selectedAddress = selectedString; // Always set the selected address
                        addressController.clear();
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                      controller.text = "";

                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onEditingComplete: onEditingComplete,
                        decoration: const InputDecoration(
                          labelText: "ঠিকানা খুঁজুন",
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  // Chips Display
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _selectedAddress != ""
                          ? [
                        Chip(
                          label: Text(_selectedAddress),
                          onDeleted: () {
                            setState(() {
                              _selectedAddress = "";
                            });
                          },
                        ),
                      ]
                          : [],
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildDisplayTile('পুরো নাম', userProfile!.fullName, Icons.person),
              _buildDisplayTile('ইমেইল', userProfile!.email, Icons.email),
              _buildDisplayTile('ফোন নাম্বার', userProfile!.phoneNumber, Icons.phone),
              _buildDisplayTile('ঠিকানা', userProfile!.address, Icons.home),
              _buildDisplayTile('টাইপ', userProfile!.type, Icons.account_box_outlined),
            ],
            const Divider(),
            _buildTypeSpecificWidgets(),
          ],
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDisplayTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _buildTypeSpecificWidgets() {
    if (userProfile == null) return Container();
    switch (userProfile!.type) {
      case 'consumer':
        return _buildConsumerWidgets();
      case 'farmer':
        return _buildFarmerWidgets();
      default:
        return Container();
    }
  }

  Widget _buildConsumerWidgets() {
    return Container();
  }

  Widget _buildFarmerWidgets() {
    return Container();
  }

}

class UserProfile {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String profilePhotoUrl;
  final String type;

  UserProfile({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profilePhotoUrl,
    required this.type,
  });
}
