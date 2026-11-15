import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/favorite_service.dart';
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
        content: Text('${deletedChar.name} dihapus dari favorit'),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'BATAL',
          textColor: Colors.white,
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
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.teal),
      );
    }

    if (_favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border_rounded,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Karakter Favorit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Karakter yang kamu tandai dengan ikon hati akan muncul di sini. Coba tambahkan karakter favorit dari Home!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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

        return Dismissible(
          key: Key('fav-${char.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Hapus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: ClipRRect(
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
              trailing: const Icon(Icons.swipe_left_rounded, color: Colors.grey, size: 20),
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
            ),
          ),
        );
      },
    );
  }
}
