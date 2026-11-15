import 'package:flutter/material.dart';
import '../helpers/shared_pref_helper.dart';
import '../theme/rick_morty_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'favorite_screen.dart';
import 'episode_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  String _username = '';

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  final GlobalKey<FavoriteScreenState> _favKey = GlobalKey<FavoriteScreenState>();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SharedPrefHelper.getUsername();
    setState(() {
      _username = name ?? 'Explorer';
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RickMortyColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: RickMortyColors.borderGlow),
        ),
        title: const Row(
          children: [
            Icon(Icons.exit_to_app_rounded, color: RickMortyColors.dangerLaser),
            SizedBox(width: 10),
            Text('Keluar Portal?', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah kamu yakin ingin menutup sesi dimensi ini dan kembali ke gerbang login?',
          style: TextStyle(color: RickMortyColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: RickMortyColors.textDim)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: RickMortyColors.dangerLaser,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SharedPrefHelper.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        key: _homeKey,
        onFavoriteChanged: () {
          _favKey.currentState?.loadFavorites();
        },
      ),
      FavoriteScreen(
        key: _favKey,
        onFavoriteChanged: () {
          _homeKey.currentState?.refreshFavorites();
        },
      ),
      const EpisodeScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: RickMortyColors.portalGreen,
                boxShadow: [
                  BoxShadow(
                    color: RickMortyColors.portalGreen,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _currentIndex == 0
                    ? 'CITADEL'
                    : _currentIndex == 1
                        ? 'FAVORITES'
                        : 'EPISODES',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: RickMortyColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RickMortyColors.borderGlow),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 16, color: RickMortyColors.portalGreen),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 85),
                  child: Text(
                    _username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: RickMortyColors.textWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Tutup Portal (Logout)',
            icon: const Icon(Icons.power_settings_new_rounded, color: RickMortyColors.dangerLaser),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            _homeKey.currentState?.refreshFavorites();
          } else if (index == 1) {
            _favKey.currentState?.loadFavorites();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Characters',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library_rounded),
            label: 'Episodes',
          ),
        ],
      ),
    );
  }
}
