import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color primary = Color(0xFF173B6D);

  final nameController = TextEditingController(
    text: "Mohd Shahed",
  );

  final emailController = TextEditingController(
    text: "shahed@email.com",
  );

  final phoneController = TextEditingController(
    text: "+91 9876543210",
  );

  final cityController = TextEditingController(
    text: "Hyderabad",
  );

  Widget field(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.person,
                size: 50,
              ),
            ),
          ),

          const SizedBox(height: 30),

          field(
            "Full Name",
            nameController,
            Icons.person,
          ),

          field(
            "Email",
            emailController,
            Icons.email,
          ),

          field(
            "Mobile Number",
            phoneController,
            Icons.phone,
          ),

          field(
            "City",
            cityController,
            Icons.location_city,
          ),
                    const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile Updated Successfully"),
                  ),
                );

                Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text(
                "SAVE PROFILE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    super.dispose();
  }
}