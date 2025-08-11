import 'package:flutter/material.dart';
import 'package:khelset/screens/profile_screen.dart';

// Theme colors
const Color primaryColor = Color(0xff1DB954);
const Color backgroundColor = Color(0xff121212);
const Color fontColor = Colors.white;
const Color accentColor = Color(0xFF4CAF50);

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final String? title;
  final List<Widget>? additionalActions;

  const CustomAppBar({
    super.key,
    this.showBackButton = false,
    this.title,
    this.additionalActions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, 
                  color: fontColor, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                color: fontColor,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 0), // Adjust this if needed
                child: Image.asset(
                  'assets/khelset_logo.png',
                  height: 250,
                  filterQuality: FilterQuality.high,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
      titleSpacing: 0, // This removes default padding
      actions: [
        if (additionalActions != null) ...additionalActions!,
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[900]!.withOpacity(0.5),
            ),
            child: const Icon(Icons.search, color: fontColor, size: 22),
          ),
          onPressed: () {
            showSearch(context: context, delegate: _KhelsetSearchDelegate());
          },
        ),
        Stack(
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[900]!.withOpacity(0.5),
                ),
                child: const Icon(Icons.notifications_outlined, 
                    color: fontColor, size: 22),
              ),
              onPressed: () {
                // TODO: Implement notifications screen
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor: accentColor.withOpacity(0.2),
              child: const Icon(
                Icons.account_circle_outlined,
                color: accentColor,
                size: 24,
              ),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: Colors.grey[800],
          height: 0.5,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _KhelsetSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Search results for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Search for events, teams, or players'),
    );
  }
}
