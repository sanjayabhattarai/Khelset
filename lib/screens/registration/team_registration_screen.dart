// lib/screens/registration/team_registration_screen.dart

import 'package:flutter/material.dart';
import 'package:khelset/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A simple class to hold player data temporarily
class Player {
  final String name;
  final String role;
  Player({required this.name, required this.role});
  
  // A helper method to convert our Player object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'role': role};
  }
}

class TeamRegistrationScreen extends StatefulWidget {
  final String eventId;
  const TeamRegistrationScreen({super.key, required this.eventId});

  @override
  State<TeamRegistrationScreen> createState() => _TeamRegistrationScreenState();
}

class _TeamRegistrationScreenState extends State<TeamRegistrationScreen> {
  // Form keys and controllers
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _playerNameController = TextEditingController();
  
  // Separate form key for the player addition section
  final _playerFormKey = GlobalKey<FormState>();
  
  // Player role options
  final List<String> _playerRoleOptions = [
    'Batsman',
    'Bowler',
    'All-rounder',
    'Wicketkeeper',
    'Captain',
    'Coach',
    'Team Manager',
  ];
  
  String? _selectedRole;

  // This list will hold the players as the user adds them
  final List<Player> _players = [];
  bool _isLoading = false;

  // Function to add a player to our local list
  void _addPlayer() {
    if (_playerFormKey.currentState!.validate()) {
      // Only add if both fields are valid
      if (_playerNameController.text.isNotEmpty && _selectedRole != null) {
        setState(() {
          _players.add(Player(
            name: _playerNameController.text,
            role: _selectedRole!,
          ));
          // Clear the text fields after adding
          _playerNameController.clear();
          _selectedRole = null;
          // Reset the player form
          _playerFormKey.currentState!.reset();
        });
      }
    }
  }

  // Function to save the entire team to Firestore
  Future<void> _registerTeam() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validate minimum players (at least 1)
    if (_players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one player to your team")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in.")));
      return;
    }
    
    setState(() => _isLoading = true);

    try {
      // Create the team document first
      final teamDoc = await FirebaseFirestore.instance.collection('teams').add({
        'name': _teamNameController.text,
        'eventId': widget.eventId,
        'captainId': user.uid,
        'captainName': user.displayName ?? 'Unknown',
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'playerCount': _players.length,
        'playerIds': [], // Will be populated as players are created
      });

      // Create individual player documents and update team
      final List<String> playerIds = [];
      for (final player in _players) {
        // Create player document
        final playerDoc = await FirebaseFirestore.instance.collection('players').add({
          'name': player.name,
          'role': player.role,
          'teamId': teamDoc.id,
          'teamName': _teamNameController.text,
          'eventId': widget.eventId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        playerIds.add(playerDoc.id);
      }

      // Update team document with all player IDs
      await teamDoc.update({
        'playerIds': playerIds,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Team registered successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to register team: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Register Your Team", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: fontColor),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- TEAM NAME SECTION ---
                  Text(
                    "Team Details",
                    style: TextStyle(
                      color: fontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _teamNameController,
                      style: TextStyle(color: fontColor),
                      decoration: InputDecoration(
                        labelText: "Team Name",
                        labelStyle: TextStyle(color: subFontColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100]?.withOpacity(0.1),
                        prefixIcon: Icon(Icons.flag, color: primaryColor),
                      ),
                      validator: (value) => value!.trim().isEmpty ? 'Please enter a team name' : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- ADD PLAYER SECTION ---
                  Row(
                    children: [
                      Text(
                        "Team Players",
                        style: TextStyle(
                          color: fontColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${_players.length} players",
                        style: TextStyle(
                          color: subFontColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _playerFormKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _playerNameController,
                              style: TextStyle(color: fontColor),
                              decoration: InputDecoration(
                                labelText: "Player Name",
                                labelStyle: TextStyle(color: subFontColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter player name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              style: TextStyle(color: fontColor),
                              decoration: InputDecoration(
                                labelText: "Player Role",
                                labelStyle: TextStyle(color: subFontColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              dropdownColor: backgroundColor,
                              items: _playerRoleOptions.map((String role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role, style: TextStyle(color: fontColor)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a role';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.person_add, size: 20),
                                label: const Text("Add Player"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _addPlayer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // --- PLAYER LIST SECTION ---
                  if (_players.isNotEmpty) ...[
                    Text(
                      "Team Roster",
                      style: TextStyle(
                        color: fontColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: primaryColor.withOpacity(0.2),
                              child: Icon(Icons.person, color: primaryColor),
                            ),
                            title: Text(
                              _players[index].name,
                              style: TextStyle(
                                color: fontColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              _players[index].role,
                              style: TextStyle(color: subFontColor),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                              onPressed: () {
                                setState(() {
                                  _players.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.group,
                            size: 60,
                            color: subFontColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No players added yet",
                            style: TextStyle(
                              color: subFontColor,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Add players to build your team roster",
                            style: TextStyle(
                              color: subFontColor.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // --- SUBMIT BUTTON ---
                  if (_players.isNotEmpty) 
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _registerTeam,
                        child: const Text(
                          "Submit Team for Approval",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}