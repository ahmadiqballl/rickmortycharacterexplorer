import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/favorite_service.dart';
import '../theme/rick_morty_theme.dart';

class DetailScreen extends StatefulWidget {
  final Character character;

  const DetailScreen({super.key, required this.character});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool _isFavorite = false;
  bool _isLoadingFav = true;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoriteService.isFavorite(widget.character.id);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
        _isLoadingFav = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final newStatus = await FavoriteService.toggleFavorite(widget.character);
    if (!mounted) return;

    setState(() {
      _isFavorite = newStatus;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? '💚 ${widget.character.name} ditambahkan ke favorit!'
              : '💔 ${widget.character.name} dihapus dari favorit!',
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

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: RickMortyColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: RickMortyColors.borderGlow),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: RickMortyColors.portalGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: RickMortyColors.portalGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.0,
                    color: RickMortyColors.textDim,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: RickMortyColors.textWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final char = widget.character;
    final statusColor = _getStatusColor(char.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(char.name.toUpperCase()),
        actions: [
          if (_isLoadingFav)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: RickMortyColors.portalGreen),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? RickMortyColors.dangerLaser : RickMortyColors.portalGreen,
                size: 26,
              ),
              onPressed: _toggleFavorite,
              tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar Karakter dengan Neon Border Frame
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: RickMortyColors.portalGreen.withValues(alpha: 0.5), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: RickMortyColors.portalGreen.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Hero(
                  tag: 'char-${char.id}',
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Image.network(
                      char.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: RickMortyColors.cardDark,
                        child: const Icon(Icons.broken_image, size: 80, color: RickMortyColors.textDim),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama & Status Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          char.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: RickMortyColors.textWhite,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                            Text(
                              char.status.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 0.8,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'SPESIFIKASI SUBJEK',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: RickMortyColors.rickHairCyan,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoTile(Icons.category_outlined, 'Spesies', char.species),
                  if (char.type.isNotEmpty)
                    _buildInfoTile(Icons.fingerprint, 'Tipe Sub-spesies', char.type),
                  _buildInfoTile(Icons.transgender, 'Gender', char.gender),
                  _buildInfoTile(Icons.public, 'Origin (Asal)', char.originName),
                  _buildInfoTile(Icons.location_on_outlined, 'Location Terakhir', char.locationName),
                  const SizedBox(height: 24),
                  // Tombol Favorite Lebar di Bawah
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingFav ? null : _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.white : const Color(0xFF0A140E),
                      ),
                      label: Text(
                        _isFavorite ? 'HAPUS DARI FAVORIT' : 'SIMPAN KE FAVORIT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: _isFavorite ? Colors.white : const Color(0xFF0A140E),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFavorite ? RickMortyColors.dangerLaser : RickMortyColors.portalGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
