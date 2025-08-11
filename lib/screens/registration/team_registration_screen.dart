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
  final _playerRoleController = TextEditingController();

  // This list will hold the players as the user adds them
  final List<Player> _players = [];
  bool _isLoading = false;

  // Function to add a player to our local list
  void _addPlayer() {
    if (_playerNameController.text.isNotEmpty && _playerRoleController.text.isNotEmpty) {
      setState(() {
        _players.add(Player(
          name: _playerNameController.text,
          role: _playerRoleController.text,
        ));
        // Clear the text fields after adding
        _playerNameController.clear();
        _playerRoleController.clear();
      });
    }
  }

  // Function to save the entire team to Firestore
  Future<void> _registerTeam() async {
    if (!_formKey.currentState!.validate()) return;

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
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Team registered successfully with optimized structure!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register team: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text("Register Your Team"), backgroundColor: backgroundColor, elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // --- TEAM NAME SECTION ---
                  TextFormField(
                    controller: _teamNameController,
                    style: const TextStyle(color: fontColor),
                    decoration: const InputDecoration(labelText: "Team Name", labelStyle: TextStyle(color: subFontColor)),
                    validator: (value) => value!.trim().isEmpty ? 'Please enter a team name' : null,
                  ),
                  const Divider(color: Colors.grey, height: 40),

                  // --- ADD PLAYER SECTION ---
                  const Text("Add Players", style: TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextFormField(controller: _playerNameController, style: const TextStyle(color: fontColor), decoration: const InputDecoration(labelText: "Player Name", labelStyle: TextStyle(color: subFontColor))),
                  const SizedBox(height: 10),
                  TextFormField(controller: _playerRoleController, style: const TextStyle(color: fontColor), decoration: const InputDecoration(labelText: "Player Role (e.g., Batsman)", labelStyle: TextStyle(color: subFontColor))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: subFontColor),
                    onPressed: _addPlayer,
                    child: const Text("Add Player"),
                  ),
                  const Divider(color: Colors.grey, height: 40),
                  
                  // --- PLAYER LIST SECTION ---
                  const Text("Team Roster", style: TextStyle(color: fontColor, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // This builds a list of the players you've added so far
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.person, color: primaryColor),
                        title: Text(_players[index].name, style: const TextStyle(color: fontColor)),
                        subtitle: Text(_players[index].role, style: const TextStyle(color: subFontColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _players.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
                   if (_players.isEmpty)
                    const Text("No players added yet.", style: TextStyle(color: subFontColor)),

                  const SizedBox(height: 40),

                  // --- SUBMIT BUTTON ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 15)),
                    onPressed: _registerTeam,
                    child: const Text("Submit Team for Approval"),
                  ),
                ],
              ),
            ),
    );
  }
}