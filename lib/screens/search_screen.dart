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
          final eventsSnapshot = await FirebaseFirestore.instance
              .collection('events')
              .limit(20)
              .get();
          
          for (var doc in eventsSnapshot.docs) {
            final data = doc.data();
            final eventName = data['name'] ?? '';
            final sport = data['sport'] ?? '';
            final location = data['location'] ?? '';
            
            if (eventName.toLowerCase().contains(query.toLowerCase()) ||
                sport.toLowerCase().contains(query.toLowerCase()) ||
                location.toLowerCase().contains(query.toLowerCase())) {
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
          
          Set<Map<String, dynamic>> uniquePlayers = {};
          
          for (var doc in playersSnapshot.docs) {
            final playerData = doc.data();
            final playerName = playerData['name'] ?? '';
            final role = playerData['role'] ?? '';
            final teamId = playerData['teamId'] ?? '';
            
            if (playerName.toLowerCase().contains(query.toLowerCase()) ||
                role.toLowerCase().contains(query.toLowerCase())) {
              uniquePlayers.add({
                'type': 'player',
                'id': doc.id,
                'data': playerData,
                'title': playerName.isNotEmpty ? playerName : 'Unnamed Player',
                'subtitle': '${role.isNotEmpty ? role : 'Player'} • Team ID: ${teamId.isNotEmpty ? teamId : 'Unknown'}',
                'icon': Icons.person,
                'color': Colors.green,
              });
              
              if (uniquePlayers.length >= 20) break;
            }
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
    final dateStr = eventData['date'] as String?;
    final location = eventData['location'] as String?;
    final sport = eventData['sport'] as String?;
    
    List<String> parts = [];
    if (sport != null) parts.add(sport);
    if (dateStr != null) {
      try {
        final date = DateTime.parse(dateStr);
        parts.add(DateFormat('MMM dd, yyyy').format(date));
      } catch (e) {
        parts.add(dateStr);
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
