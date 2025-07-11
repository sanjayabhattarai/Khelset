// lib/screens/registration/team_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TeamRegistrationScreen extends StatefulWidget {
  final String eventId;
  const TeamRegistrationScreen({super.key, required this.eventId});

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _captainNameController = TextEditingController();
  final _captainPhoneController = TextEditingController();
  final _viceCaptainNameController = TextEditingController();
  final _coachNameController = TextEditingController();
  final _coachPhoneController = TextEditingController();

  List<Map<String, String>> players = [
    {'name': '', 'role': 'Batsman'},
  ];

  bool _isLoading = false;

  Future<void> _registerTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to register a team.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create team document
      final teamDoc = await FirebaseFirestore.instance.collection('teams').add({
        'name': _teamNameController.text.trim(),
        'eventId': widget.eventId,
        'captainId': user.uid,
        'captainName': _captainNameController.text.trim(),
        'captainPhone': _captainPhoneController.text.trim(),
        'viceCaptainName': _viceCaptainNameController.text.trim(),
        'coachName': _coachNameController.text.trim(),
        'coachPhone': _coachPhoneController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add players
      for (var player in players) {
        await teamDoc.collection('players').add({
          'name': player['name'],
          'role': player['role'],
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Team registered successfully! Waiting for approval.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register team: ${e.toString()}")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Team Registration"),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text("Team Information", style: TextStyle(
                  color: fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
                const Divider(height: 20, thickness: 1),

                _buildTextField(_teamNameController, "Team Name*"),

                const SizedBox(height: 24),
                const Text("Captain Details", style: TextStyle(
                  color: fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
                const Divider(height: 20, thickness: 1),

                _buildTextField(_captainNameController, "Captain Name*"),
                _buildTextField(_captainPhoneController, "Captain Phone*", 
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter phone number';
                    if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                      return 'Enter valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                const Text("Vice Captain Details", style: TextStyle(
                  color: fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
                const Divider(height: 20, thickness: 1),

                _buildTextField(_viceCaptainNameController, "Vice Captain Name*"),

                const SizedBox(height: 24),
                const Text("Coach Details", style: TextStyle(
                  color: fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
                const Divider(height: 20, thickness: 1),

                _buildTextField(_coachNameController, "Coach Name*"),
                _buildTextField(_coachPhoneController, "Coach Phone*", 
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter phone number';
                    if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
                      return 'Enter valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
                const Text("Team Players", style: TextStyle(
                  color: fontColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
                const Divider(height: 20, thickness: 1),
                const Text("Add at least 5 players", style: TextStyle(
                  color: subFontColor,
                  fontSize: 14,
                )),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Player ${index + 1} Name*',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) => players[index]['name'] = value,
                                    validator: (value) => 
                                        (value == null || value.trim().isEmpty) 
                                            ? 'Required' 
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                DropdownButton<String>(
                                  value: players[index]['role'],
                                  items: ['Batsman', 'Bowler', 'All-Rounder', 'Wicket Keeper']
                                      .map((role) => DropdownMenuItem(
                                            value: role,
                                            child: Text(role),
                                          ))
                                      .toList(),
                                  onChanged: (role) => setState(() => players[index]['role'] = role!),
                                ),
                              ],
                            ),
                            if (players.length > 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () => setState(() => players.removeAt(index)),
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  label: const Text("Remove", style: TextStyle(color: Colors.red)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Another Player"),
                  onPressed: () => setState(() => players.add({'name': '', 'role': 'Batsman'})),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: primaryColor),
                  ),
                ),

                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _registerTeam,
                        child: const Text(
                          "SUBMIT FOR APPROVAL",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: fontColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: subFontColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: primaryColor),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        validator: validator ?? 
            ((value) => (value == null || value.trim().isEmpty) ? 'This field is required' : null),
      ),
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _captainNameController.dispose();
    _captainPhoneController.dispose();
    _viceCaptainNameController.dispose();
    _coachNameController.dispose();
    _coachPhoneController.dispose();
    super.dispose();
  }
}