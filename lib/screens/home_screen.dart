import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Character> _characters = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'All';

  final List<String> _statusFilters = ['All', 'Alive', 'Dead', 'Unknown'];

  @override
  void initState() {
    super.initState();
    _fetchCharacters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCharacters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final characters = await ApiService.getCharacters(
        status: _selectedStatus == 'All' ? null : _selectedStatus,
        name: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );

      final favs = await FavoriteService.getFavorites();
      final favIds = favs.map((e) => e.id).toSet();

      if (mounted) {
        setState(() {
          _characters = characters;
          _favoriteIds = favIds;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(Character character) async {
    final isNowFav = await FavoriteService.toggleFavorite(character);
    if (!mounted) return;

    setState(() {
      if (isNowFav) {
        _favoriteIds.add(character.id);
      } else {
        _favoriteIds.remove(character.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFav
              ? '${character.name} ditambahkan ke favorit!'
              : '${character.name} dihapus dari favorit!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isNowFav ? Colors.green : Colors.redAccent,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar (Bonus)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama karakter...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _fetchCharacters();
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            onSubmitted: (_) => _fetchCharacters(),
          ),
        ),

        // Filter Bar (All, Alive, Dead, Unknown)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _statusFilters.map((status) {
              final isSelected = _selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  selectedColor: Colors.teal.withValues(alpha: 0.2),
                  checkmarkColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.teal : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                      _fetchCharacters();
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),

        // Content List / Loading / Error
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Memuat daftar karakter...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
              const SizedBox(height: 12),
              const Text(
                'Terjadi Kesalahan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchCharacters,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Tidak ada karakter yang cocok',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedStatus = 'All');
                _fetchCharacters();
              },
              child: const Text('Reset Pencarian & Filter'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCharacters,
      color: Colors.teal,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _characters.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final char = _characters[index];
          final isFav = _favoriteIds.contains(char.id);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            leading: Hero(
              tag: 'char-${char.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  char.image,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 56,
                    height: 56,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
            ),
            title: Text(
              char.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(char.status),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${char.status} - ${char.species}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                color: isFav ? Colors.redAccent : Colors.grey,
              ),
              onPressed: () => _toggleFavorite(char),
              tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
            ),
            onTap: () async {
              // Navigasi ke DetailScreen
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(character: char),
                ),
              );
              // Segarkan status favorit saat kembali dari DetailScreen
              final favs = await FavoriteService.getFavorites();
              if (mounted) {
                setState(() {
                  _favoriteIds = favs.map((e) => e.id).toSet();
                });
              }
            },
          );
        },
      ),
    );
  }
}
