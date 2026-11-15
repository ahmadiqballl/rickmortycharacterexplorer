import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/favorite_service.dart';
import '../theme/rick_morty_theme.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final VoidCallback? onFavoriteChanged;

  const FavoriteScreen({super.key, this.onFavoriteChanged});

  @override
  State<FavoriteScreen> createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  List<Character> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() => _isLoading = true);
    final list = await FavoriteService.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Character char) async {
    final deletedChar = char;
    await FavoriteService.removeFavorite(char.id);

    setState(() {
      _favorites.removeWhere((item) => item.id == char.id);
    });

    widget.onFavoriteChanged?.call();

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('💔 ${deletedChar.name} telah dieliminasi dari Favorit'),
        backgroundColor: RickMortyColors.cardDark,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: RickMortyColors.portalGreen,
          onPressed: () async {
            await FavoriteService.toggleFavorite(deletedChar);
            loadFavorites();
            widget.onFavoriteChanged?.call();
          },
        ),
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
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: RickMortyColors.portalGreen),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: RickMortyColors.cardDark,
                  border: Border.all(color: RickMortyColors.borderGlow, width: 2),
                ),
                child: const Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: RickMortyColors.dangerLaser,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'TIDAK ADA SPESIMEN FAVORIT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: RickMortyColors.textWhite,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tandai karakter yang kamu sukai dengan ikon hati di tab Characters untuk menyimpannya di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: RickMortyColors.textDim, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final char = _favorites[index];
        final statusColor = _getStatusColor(char.status);

        return Dismissible(
          key: Key('fav-${char.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: RickMortyColors.dangerLaser,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
                SizedBox(width: 8),
                Text(
                  'HAPUS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (direction) {
            _removeFavorite(char);
          },
          child: Card(
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
                loadFavorites();
                widget.onFavoriteChanged?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
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
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: RickMortyColors.surfaceDark,
                            child: const Icon(Icons.person, color: RickMortyColors.textDim),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
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
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.swipe_left_rounded,
                        color: RickMortyColors.dangerLaser,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
