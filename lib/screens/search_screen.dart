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
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            color: Colors.white, 
            fontSize: isDesktop ? 24 : 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : isTablet ? 24 : 16,
            vertical: isDesktop ? 24 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Integrated Search Bar
            Container(
              height: isDesktop ? 56 : 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.12),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isDesktop ? 28 : 24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: isDesktop 
                      ? 'Search tournaments, events, players...'
                      : 'Search cricket events...',
                  hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    margin: EdgeInsets.only(
                      left: isDesktop ? 16 : 12,
                      right: isDesktop ? 12 : 8,
                    ),
                    child: Icon(
                      Icons.search_rounded, 
                      color: Colors.white.withOpacity(0.6),
                      size: isDesktop ? 24 : 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Container(
                          margin: EdgeInsets.only(
                            right: isDesktop ? 12 : 8,
                          ),
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.close_rounded, 
                                color: Colors.white.withOpacity(0.7),
                                size: isDesktop ? 16 : 14,
                              ),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _handleSearch('');
                            },
                            splashRadius: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 20 : 16, 
                    vertical: isDesktop ? 16 : 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                  _handleSearch(value);
                },
              ),
            ),              SizedBox(height: isDesktop ? 20 : 16),
              
              // Filter Chips
              SizedBox(
                height: isDesktop ? 44 : 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedFilter == filter;
                    
                    return Padding(
                      padding: EdgeInsets.only(right: isDesktop ? 16 : 12),
                      child: GestureDetector(
                        onTap: () => _handleFilterChange(filter),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 20 : 16,
                            vertical: isDesktop ? 12 : 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.04),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
                            border: Border.all(
                              color: isSelected 
                                  ? primaryColor.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: isDesktop ? 16 : 14,
                                    color: Colors.white,
                                  ),
                                ),
                              Text(
                                filter,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  fontSize: isDesktop ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              SizedBox(height: isDesktop ? 32 : 24),
              
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
      ),
    );
  }

  Widget _buildInitialState() {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : isTablet ? 32 : 24,
            vertical: isDesktop ? 32 : 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryColor.withOpacity(0.2),
                      primaryColor.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.search,
                  size: isDesktop ? 56 : isTablet ? 48 : 40,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: isDesktop ? 32 : isTablet ? 24 : 20),
              Text(
                'Discover Cricket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 28 : isTablet ? 24 : 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 16 : isTablet ? 12 : 10),
              Text(
                isDesktop 
                    ? 'Search for cricket tournaments, events,\nand players from across the community'
                    : 'Search for cricket tournaments,\nevents, and players',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 40 : isTablet ? 32 : 24),
              // Quick search suggestions
              LayoutBuilder(
                builder: (context, constraints) {
                  if (isDesktop) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSuggestionChip('Cricket Tournament', Icons.emoji_events),
                        const SizedBox(width: 12),
                        _buildSuggestionChip('Local League', Icons.groups),
                        const SizedBox(width: 12),
                        _buildSuggestionChip('Players', Icons.person),
                      ],
                    );
                  } else {
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSuggestionChip('Cricket Tournament', Icons.emoji_events),
                        _buildSuggestionChip('Local League', Icons.groups),
                        _buildSuggestionChip('Players', Icons.person),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, IconData icon) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return InkWell(
      onTap: () {
        _searchController.text = label;
        _handleSearch(label);
        _searchFocusNode.unfocus();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 16 : isTablet ? 14 : 12,
          vertical: isDesktop ? 12 : isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isDesktop ? 20 : isTablet ? 18 : 16,
              color: Colors.white.withOpacity(0.8),
            ),
            SizedBox(width: isDesktop ? 8 : 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: isDesktop ? 14 : isTablet ? 13 : 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : isTablet ? 32 : 24,
            vertical: isDesktop ? 32 : 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 20 : isTablet ? 18 : 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.search_off,
                  size: isDesktop ? 56 : isTablet ? 48 : 40,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),
              Text(
                'No matches found',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isDesktop ? 24 : isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 12 : isTablet ? 10 : 8),
              Text(
                'Try searching with different keywords\nor check your spelling',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: isDesktop ? 16 : isTablet ? 15 : 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isDesktop ? 32 : isTablet ? 24 : 20),
              // Quick suggestion to clear search
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _handleSearch('');
                  _searchFocusNode.requestFocus();
                },
                icon: Icon(
                  Icons.refresh, 
                  color: primaryColor,
                  size: isDesktop ? 20 : 18,
                ),
                label: Text(
                  'Clear search',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: isDesktop ? 16 : 14,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: isDesktop ? 12 : 8,
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildEventImage(Map<String, dynamic> eventData, double iconSize) {
    final posterUrl = eventData['posterUrl'] as String?;
    final sportType = eventData['sportType'] as String? ?? 'cricket';
    final containerSize = 48.0; // Smaller size for search cards
    
    if (posterUrl != null && posterUrl.isNotEmpty) {
      // Show poster image
      return Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getSportColor(sportType).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.network(
            posterUrl,
            width: containerSize,
            height: containerSize,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  color: _getSportColor(sportType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getSportColor(sportType)),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              // Show event icon if poster fails to load
              return _buildEventIcon(sportType, iconSize);
            },
          ),
        ),
      );
    } else {
      // Show event icon if no poster URL
      return _buildEventIcon(sportType, iconSize);
    }
  }

  Widget _buildEventIcon(String sportType, double iconSize) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getSportColor(sportType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _getSportIcon(sportType),
        color: _getSportColor(sportType),
        size: iconSize,
      ),
    );
  }

  IconData _getSportIcon(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_football;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports_tennis; // Use tennis icon for badminton
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.event;
    }
  }

  Color _getSportColor(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'cricket':
        return const Color(0xFF4CAF50); // Green
      case 'football':
        return const Color(0xFF2196F3); // Blue
      case 'basketball':
        return const Color(0xFFFF9800); // Orange
      case 'tennis':
        return const Color(0xFF9C27B0); // Purple
      case 'badminton':
        return const Color(0xFFE91E63); // Pink
      case 'volleyball':
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return primaryColor;
    }
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
              // Event image/icon
              _buildEventImage(result['rawData'] ?? {}, 24),
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