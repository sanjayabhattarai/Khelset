import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_details_screen.dart';

// Theme Constants
const Color primaryColor = Color(0xff1DB954);
const Color backgroundColor = Color(0xff121212);
const Color cardColor = Color(0xff1E1E1E);
const Color fontColor = Colors.white;
const Color subFontColor = Color(0xFFB3B3B3);

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = false;

  final List<String> _filterOptions = [
    'All',
    'Events',
    'Players'
  ];

  List<Map<String, dynamic>> _searchResults = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // In a real app, you'd load this from shared preferences
    _recentSearches = [
      'Cricket Tournament',
      'Football League', 
      'Virat Kohli',
      'Basketball Championship',
    ];
  }

  void _saveRecentSearch(String query) {
    if (query.trim().isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      });
      // In a real app, save to shared preferences here
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchQuery = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      List<Map<String, dynamic>> results = [];
      
      // Search Events - This should work as events have read: if true
      if (_selectedFilter == 'All' || _selectedFilter == 'Events') {
        try {
          print('Searching events for query: $query');
          final eventsSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .limit(20)
              .get();
          
          print('Found ${eventsSnapshot.docs.length} events in database');
          
          for (var doc in eventsSnapshot.docs) {
            final data = doc.data();
            print('Event data: $data');
            
            final eventName = data['name'] ?? data['eventName'] ?? '';
            final sport = data['sport'] ?? data['category'] ?? '';
            final location = data['location'] ?? data['venue'] ?? '';
            final description = data['description'] ?? '';
            
            print('Event: $eventName, Sport: $sport, Location: $location');
            
            // More flexible search - check if query is empty or matches any field
            bool matches = query.toLowerCase().isEmpty ||
                eventName.toLowerCase().contains(query.toLowerCase()) ||
                sport.toLowerCase().contains(query.toLowerCase()) ||
                location.toLowerCase().contains(query.toLowerCase()) ||
                description.toLowerCase().contains(query.toLowerCase());
            
            if (matches) {
              print('Event matches query: $eventName');
              results.add({
                'type': 'event',
                'id': doc.id,
                'data': data,
                'title': eventName.isNotEmpty ? eventName : 'Unnamed Event',
                'subtitle': _formatEventSubtitle(data),
                'icon': Icons.event,
                'color': primaryColor,
              });
            }
          }
          print('Added ${results.where((r) => r['type'] == 'event').length} events to results');
        } catch (e) {
          print('Error searching events: $e');
        }
      }

      // Search Players - Using the players collection
      if (_selectedFilter == 'All' || _selectedFilter == 'Players') {
        try {
          final playersSnapshot = await FirebaseFirestore.instance
              .collection('players')
              .limit(50)
              .get();
          
          List<Map<String, dynamic>> matchingPlayers = [];
          Set<String> teamIds = {};
          
          // First pass: collect matching players and unique team IDs
          for (var doc in playersSnapshot.docs) {
            final playerData = doc.data();
            final playerName = playerData['name'] ?? '';
            final role = playerData['role'] ?? '';
            final teamId = playerData['teamId'] ?? '';
            
            if (playerName.toLowerCase().contains(query.toLowerCase()) ||
                role.toLowerCase().contains(query.toLowerCase())) {
              
              matchingPlayers.add({
                'id': doc.id,
                'data': playerData,
                'name': playerName,
                'role': role,
                'teamId': teamId,
              });
              
              if (teamId.isNotEmpty) {
                teamIds.add(teamId);
              }
              
              if (matchingPlayers.length >= 20) break;
            }
          }
          
          // Batch fetch team names
          Map<String, String> teamNames = {};
          if (teamIds.isNotEmpty) {
            try {
              for (String teamId in teamIds) {
                final teamDoc = await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(teamId)
                    .get();
                if (teamDoc.exists) {
                  teamNames[teamId] = teamDoc.data()?['name'] ?? teamId;
                } else {
                  teamNames[teamId] = teamId;
                }
              }
            } catch (e) {
              print('Error fetching team names: $e');
            }
          }
          
          // Second pass: create results with team names
          Set<Map<String, dynamic>> uniquePlayers = {};
          for (var player in matchingPlayers) {
            final teamName = player['teamId'].isNotEmpty 
                ? (teamNames[player['teamId']] ?? 'Unknown Team')
                : 'Unknown Team';
            
            uniquePlayers.add({
              'type': 'player',
              'id': player['id'],
              'data': player['data'],
              'title': player['name'].isNotEmpty ? player['name'] : 'Unnamed Player',
              'subtitle': '${player['role'].isNotEmpty ? player['role'] : 'Player'} • $teamName',
              'icon': Icons.person,
              'color': Colors.green,
            });
          }
          
          results.addAll(uniquePlayers.toList());
        } catch (e) {
          print('Error searching players: $e');
        }
      }

      // Sort results by relevance (exact matches first)
      results.sort((a, b) {
        final aTitle = a['title'].toString().toLowerCase();
        final bTitle = b['title'].toString().toLowerCase();
        final queryLower = query.toLowerCase();
        
        final aExact = aTitle == queryLower ? 1 : 0;
        final bExact = bTitle == queryLower ? 1 : 0;
        
        if (aExact != bExact) return bExact - aExact;
        
        final aStarts = aTitle.startsWith(queryLower) ? 1 : 0;
        final bStarts = bTitle.startsWith(queryLower) ? 1 : 0;
        
        return bStarts - aStarts;
      });

      setState(() {
        _searchResults = results.take(50).toList();
        _isLoading = false;
      });

      _saveRecentSearch(query);
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatEventSubtitle(Map<String, dynamic> eventData) {
    final dateField = eventData['date'];
    final location = eventData['location'] as String?;
    final sport = eventData['sport'] as String?;
    
    List<String> parts = [];
    if (sport != null) parts.add(sport);
    
    // Handle different date formats - could be String, Timestamp, or null
    if (dateField != null) {
      try {
        DateTime date;
        if (dateField is Timestamp) {
          // If it's a Firestore Timestamp, convert to DateTime
          date = dateField.toDate();
        } else if (dateField is String) {
          // If it's a String, parse it
          date = DateTime.parse(dateField);
        } else {
          // If it's already a DateTime, use it directly
          date = dateField as DateTime;
        }
        parts.add(DateFormat('MMM dd, yyyy').format(date));
      } catch (e) {
        // If parsing fails, just add the raw value as string
        parts.add(dateField.toString());
      }
    }
    
    if (location != null) parts.add(location);
    
    return parts.join(' • ');
  }

  void _onResultTap(Map<String, dynamic> result) {
    switch (result['type']) {
      case 'event':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              eventId: result['id'],
            ),
          ),
        );
        break;
      case 'player':
        // Show a simple dialog with player details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: cardColor,
            title: Text(
              result['title'],
              style: const TextStyle(color: fontColor),
            ),
            content: Text(
              result['subtitle'],
              style: const TextStyle(color: subFontColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: fontColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: const TextStyle(color: fontColor),
          decoration: InputDecoration(
            hintText: 'Search events and players...',
            hintStyle: TextStyle(color: subFontColor),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: subFontColor),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : const Icon(Icons.search, color: subFontColor),
          ),
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
          onSubmitted: _performSearch,
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filterOptions.length,
              itemBuilder: (context, index) {
                final option = _filterOptions[index];
                final isSelected = _selectedFilter == option;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? backgroundColor : fontColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = option;
                      });
                      if (_searchQuery.isNotEmpty) {
                        _performSearch(_searchQuery);
                      }
                    },
                    backgroundColor: cardColor,
                    selectedColor: primaryColor,
                    checkmarkColor: backgroundColor,
                    side: BorderSide(
                      color: isSelected ? primaryColor : Colors.grey.shade600,
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(color: Colors.grey, height: 1),
          
          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : _searchQuery.isEmpty
                    ? _buildRecentSearches()
                    : _searchResults.isEmpty
                        ? _buildNoResults()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: subFontColor),
            SizedBox(height: 16),
            Text(
              'Search for events and players',
              style: TextStyle(color: subFontColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  color: fontColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: primaryColor),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history, color: subFontColor),
                title: Text(
                  search,
                  style: const TextStyle(color: fontColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: subFontColor),
                  onPressed: () {
                    setState(() {
                      _recentSearches.removeAt(index);
                    });
                  },
                ),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: subFontColor),
          const SizedBox(height: 16),
          Text(
            'No results found for "$_searchQuery"',
            style: const TextStyle(color: fontColor, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Try different keywords or check your spelling',
            style: TextStyle(color: subFontColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: result['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              result['icon'],
              color: result['color'],
              size: 24,
            ),
          ),
          title: Text(
            result['title'],
            style: const TextStyle(
              color: fontColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            result['subtitle'],
            style: const TextStyle(color: subFontColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: result['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result['type'].toUpperCase(),
              style: TextStyle(
                color: result['color'],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () => _onResultTap(result),
        );
      },
    );
  }
}
