import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khelset/theme/app_theme.dart';
import 'match_card.dart';
import 'package:khelset/screens/match_details_screen.dart'; // Import the MatchDetailsScreen


class InfoTab extends StatelessWidget {
  final Map<String, dynamic> eventData;
  final String eventId;

  const InfoTab({
    super.key,
    required this.eventData,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    final eventName = eventData['eventName'] ?? 'Unnamed Event';
    final location = eventData['location'] ?? 'No Location';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Event Header Card
        _buildEventHeaderCard(eventName, location),
        const SizedBox(height: 24),
        
        // Rules & Requirements Card
        _buildRulesCard(),
        const SizedBox(height: 24),

  // --- CONDITIONAL UI SECTION ---
  // Only show the schedule, registration handled by floating button in main screen
  _buildScheduleCard(),
      ],
    );
  }

  Widget _buildEventHeaderCard(String eventName, String location) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eventName,
            style: const TextStyle(
              color: Colors.white, 
              fontSize: 24, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                location,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRulesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule_outlined, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Rules & Requirements",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Event Description
          if (eventData['description'] != null && eventData['description'].toString().isNotEmpty) ...[
            const Text(
              "Event Description:",
              style: TextStyle(
                color: Colors.white70, 
                fontSize: 16, 
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventData['description'],
              style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
          
          // Custom Rules Text from rules field
          if (eventData['rules'] != null && 
              eventData['rules']['customRulesText'] != null && 
              eventData['rules']['customRulesText'].toString().isNotEmpty) ...[
            const Text(
              "Other Rules / Additional Information:",
              style: TextStyle(
                color: Colors.white70, 
                fontSize: 16, 
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventData['rules']['customRulesText'],
              style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
          ],
          
          // Match Rules (if available)
          if (eventData['rules'] != null && _hasMatchRules()) ...[
            const Text(
              "Match Format:",
              style: TextStyle(
                color: Colors.white70, 
                fontSize: 16, 
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildMatchRules(),
            const SizedBox(height: 16),
          ],
          
          // Show default message if no content
          if (!_hasRulesContent()) ...[
            const Text(
              "No rules or requirements have been provided for this event yet.",
              style: TextStyle(color: Colors.grey, fontSize: 15, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  // Helper method to check if there are match rules to display
  bool _hasMatchRules() {
    final rules = eventData['rules'] as Map<String, dynamic>?;
    if (rules == null) return false;
    
    return rules['totalOvers'] != null || 
           rules['playersPerTeam'] != null || 
           rules['maxOversPerBowler'] != null;
  }

  // Helper method to build match rules display
  Widget _buildMatchRules() {
    final rules = eventData['rules'] as Map<String, dynamic>? ?? {};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rules['totalOvers'] != null) ...[
          _buildRuleItem("Total Overs", "${rules['totalOvers']} overs per innings"),
        ],
        if (rules['playersPerTeam'] != null) ...[
          _buildRuleItem("Players per Team", "${rules['playersPerTeam']} players"),
        ],
        if (rules['maxOversPerBowler'] != null) ...[
          _buildRuleItem("Max Overs per Bowler", "${rules['maxOversPerBowler']} overs"),
        ],
      ],
    );
  }

  // Helper method to build individual rule items
  Widget _buildRuleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to check if there's any rules content to display
  bool _hasRulesContent() {
    return (eventData['description'] != null && eventData['description'].toString().isNotEmpty) ||
           (eventData['rules'] != null && eventData['rules']['customRulesText'] != null && eventData['rules']['customRulesText'].toString().isNotEmpty) ||
           _hasMatchRules();
  }

  // A new helper widget for the schedule section card
  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: primaryColor, size: 22),
              const SizedBox(width: 8),
              const Text(
                "Match Schedule",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildScheduleList(eventId),
        ],
      ),
    );
  }

  // This method for fetching the schedule list remains the same
  Widget _buildScheduleList(String eventId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('matches').where('eventId', isEqualTo: eventId).orderBy('scheduledTime').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Schedule has not been posted yet.", style: TextStyle(color: Colors.grey)));
        }
        final matches = snapshot.data!.docs;
        return Column(
          children: matches.map((doc) => InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchDetailsScreen(matchId: doc.id),
                ),
              );
            },
            child: MatchCard(matchDoc: doc),
          )).toList(),
        );
      },
    );
  }
}