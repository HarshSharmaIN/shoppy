import 'package:ecommerce_app/controllers/db_service.dart';
import 'package:ecommerce_app/providers/user_provider.dart';
import 'package:ecommerce_app/utils/snackbar_utils.dart';
import 'package:ecommerce_app/widgets/modern_button.dart';
import 'package:ecommerce_app/widgets/modern_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = user.name;
    _emailController.text = user.email;
    _addressController.text = user.address;
    _phoneController.text = user.phone;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Update Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              ModernTextField(
                controller: _nameController,
                label: "Full Name",
                hint: "Enter your full name",
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value!.isEmpty ? "Name cannot be empty." : null,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                controller: _emailController,
                label: "Email",
                hint: "Email address",
                prefixIcon: Icons.email_outlined,
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? "Email cannot be empty." : null,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                controller: _addressController,
                label: "Address",
                hint: "Enter your complete address",
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? "Address cannot be empty." : null,
              ),
              const SizedBox(height: 20),
              ModernTextField(
                controller: _phoneController,
                label: "Phone Number",
                hint: "Enter your phone number",
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Phone cannot be empty." : null,
              ),
              const SizedBox(height: 32),
              ModernButton(
                text: "Update Profile",
                onPressed: _updateProfile,
                isLoading: _isLoading,
                width: double.infinity,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      var data = {
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "address": _addressController.text.trim(),
        "phone": _phoneController.text.trim(),
      };

      await DbService().updateUserData(extraData: data);

      SnackBarUtils.showSuccess(context, "Profile updated successfully!");
      Navigator.pop(context);
    } catch (e) {
      SnackBarUtils.showError(
        context,
        "Failed to update profile. Please try again.",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
