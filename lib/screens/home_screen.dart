import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';
import '../theme/rick_morty_theme.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onFavoriteChanged;

  const HomeScreen({super.key, this.onFavoriteChanged});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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

  Future<void> refreshFavorites() async {
    final favs = await FavoriteService.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteIds = favs.map((e) => e.id).toSet();
      });
    }
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

    widget.onFavoriteChanged?.call();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNowFav
              ? '💚 ${character.name} disimpan ke Favorit!'
              : '💔 ${character.name} dihapus dari Favorit!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: RickMortyColors.cardDark,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return RickMortyColors.statusAlive;
      case 'dead':
        return RickMortyColors.statusDead;
      default:
        return RickMortyColors.statusUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar (Bonus)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: RickMortyColors.textWhite),
            decoration: InputDecoration(
              hintText: 'Cari karakter (cth: Rick, Morty)...',
              prefixIcon: const Icon(Icons.search, color: RickMortyColors.portalGreen),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: RickMortyColors.textDim),
                      onPressed: () {
                        _searchController.clear();
                        _fetchCharacters();
                      },
                    )
                  : null,
            ),
            onSubmitted: (_) => _fetchCharacters(),
          ),
        ),

        // Filter Bar (All, Alive, Dead, Unknown)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: _statusFilters.map((status) {
              final isSelected = _selectedStatus == status;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(status),
                  selected: isSelected,
                  backgroundColor: RickMortyColors.cardDark,
                  selectedColor: RickMortyColors.portalGreen.withValues(alpha: 0.25),
                  checkmarkColor: RickMortyColors.portalGreen,
                  side: BorderSide(
                    color: isSelected ? RickMortyColors.portalGreen : RickMortyColors.borderGlow,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? RickMortyColors.portalGreen : RickMortyColors.textDim,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
            CircularProgressIndicator(color: RickMortyColors.portalGreen),
            SizedBox(height: 16),
            Text(
              'Menghubungkan ke Portal API...',
              style: TextStyle(color: RickMortyColors.portalGreen, fontWeight: FontWeight.bold),
            ),
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
              const Icon(Icons.sensors_off_rounded, size: 64, color: RickMortyColors.dangerLaser),
              const SizedBox(height: 12),
              const Text(
                'Gangguan Antar Dimensi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: RickMortyColors.dangerLaser,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: RickMortyColors.textDim),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchCharacters,
                icon: const Icon(Icons.refresh),
                label: const Text('COBA LAGI'),
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
            const Icon(Icons.search_off, size: 64, color: RickMortyColors.textDim),
            const SizedBox(height: 12),
            const Text(
              'Karakter tidak ditemukan di dimensi ini',
              style: TextStyle(fontSize: 16, color: RickMortyColors.textDim),
            ),
            const SizedBox(height: 10),
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
      color: RickMortyColors.portalGreen,
      backgroundColor: RickMortyColors.cardDark,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _characters.length,
        itemBuilder: (context, index) {
          final char = _characters[index];
          final isFav = _favoriteIds.contains(char.id);
          final statusColor = _getStatusColor(char.status);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(character: char),
                  ),
                );
                await refreshFavorites();
                widget.onFavoriteChanged?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Avatar Image with glowing border
                    Hero(
                      tag: 'char-${char.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            char.image,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: RickMortyColors.surfaceDark,
                              child: const Icon(Icons.person, color: RickMortyColors.textDim),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            char.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: RickMortyColors.textWhite,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: statusColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${char.status} - ${char.species}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: RickMortyColors.textDim,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Favorite Button
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? RickMortyColors.dangerLaser : RickMortyColors.textDim,
                        size: 24,
                      ),
                      onPressed: () => _toggleFavorite(char),
                      tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
