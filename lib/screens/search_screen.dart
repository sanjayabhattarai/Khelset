import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/utils/responsive_utils.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';
import 'event_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = true;
  bool _hasSearched = false;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'Players', 'Events'];

  @override
  void initState() {
    super.initState();
    _loadRealData();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRealData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _fetchEvents(),
        _fetchPlayers(),
      ]);

      final events = results[0];
      final players = results[1];

      print('Loaded ${events.length} events and ${players.length} players');
      if (events.isNotEmpty) {
        print('First event: ${events.first['title']}');
      }
      if (players.isNotEmpty) {
        print('First player: ${players.first['title']}');
      }

      setState(() {
        _allData = [...events, ...players];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchEvents() async {
    try {
      // Get all events without ordering first to test basic connectivity
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .get();
      
      print('Events collection query returned ${snapshot.docs.length} documents');
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Use either 'name' or 'eventName' field
        final eventTitle = data['name'] ?? data['eventName'] ?? 'Unknown Event';
        
        print('Event found: $eventTitle');
        
        return {
          'id': doc.id,
          'title': eventTitle,
          'subtitle': data['description'] ?? 'No description',
          'type': 'Event',
          'category': 'Events',
          'status': data['status'] ?? 'active',
          'location': data['location'] ?? '',
          'color': Colors.green,
          'icon': Icons.event,
          'stats': 'Location: ${data['location'] ?? 'TBD'}',
          'rawData': data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPlayers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('players')
          .orderBy('name')
          .get();
      
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'title': doc.data()['name'] ?? 'Unknown Player',
        'subtitle': doc.data()['role'] ?? 'Unknown Role',
        'type': 'Player',
        'category': 'Players',
        'teamId': doc.data()['teamId'],
        'eventId': doc.data()['eventId'],
        'color': Colors.orange,
        'icon': Icons.person,
        'stats': 'Role: ${doc.data()['role'] ?? 'Unknown'}',
        'rawData': doc.data(),
      }).toList();
    } catch (e) {
      print('Error fetching players: $e');
      return [];
    }
  }

  void _handleSearch(String query) {
    setState(() {
      _hasSearched = true;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allData.where((item) {
          final title = item['title']?.toString() ?? '';
          final category = item['category']?.toString() ?? '';
          
          // Only search in title/name for events, not in descriptions or other fields
          final matchesQuery = title.toLowerCase().contains(query.toLowerCase());
          
          final matchesFilter = _selectedFilter == 'All' || category == _selectedFilter;
          
          return matchesQuery && matchesFilter;
        }).toList();
      }
    });
  }

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (_hasSearched) {
        _handleSearch(_searchController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Search',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Integrated Search Bar
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search players and events...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.white.withValues(alpha: 0.7)),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                  _handleSearch(value);
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => _handleFilterChange(filter),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      selectedColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      checkmarkColor: Colors.black,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : !_hasSearched
                      ? _buildInitialState()
                      : _searchResults.isEmpty
                          ? _buildNoResults()
                          : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Search players and events',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Find cricket players and tournament events\nLoaded ${_allData.length} items from database',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            'Try different keywords or change filters',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_searchResults.where((result) => result['type'] == 'Event').length} events found',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            if (_selectedFilter != 'All')
              Chip(
                label: Text(
                  _selectedFilter,
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
                backgroundColor: Colors.white,
                side: BorderSide.none,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final result = _searchResults[index];
              
              // Only show event cards, skip other types
              if (result['type'] != 'Event') {
                return const SizedBox.shrink();
              }
              
              return _buildEventCard(result);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard(Map<String, dynamic> result) {
    final eventName = result['title'] ?? 'Unnamed Event';
    final location = result['rawData']['location'] ?? 'Location not specified';
    final eventId = result['id'];

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardBackgroundColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(eventId: eventId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Event icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eventName,
                      style: const TextStyle(
                        color: fontColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: subFontColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(
                              color: subFontColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite button
              FutureBuilder<bool>(
                future: FavoritesService().isEventFavorite(eventId),
                builder: (context, snapshot) {
                  final isFavorite = snapshot.data ?? false;
                  return IconButton(
                    onPressed: () => _toggleFavorite(eventId),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : subFontColor,
                      size: 24,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to add favorites'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FavoritesService().toggleFavorite(eventId);
      // Trigger a rebuild to update the favorite icon
      setState(() {});
      
      final isFavorite = await FavoritesService().isEventFavorite(eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          backgroundColor: isFavorite ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}