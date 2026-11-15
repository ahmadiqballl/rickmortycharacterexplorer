import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/favorite_service.dart';

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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus
              ? '${widget.character.name} ditambahkan ke favorit!'
              : '${widget.character.name} dihapus dari favorit!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: newStatus ? Colors.green : Colors.redAccent,
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

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

    return Scaffold(
      appBar: AppBar(
        title: Text(char.name),
        actions: [
          if (_isLoadingFav)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.redAccent : null,
              ),
              onPressed: _toggleFavorite,
              tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gambar Karakter
            Hero(
              tag: 'char-${char.id}',
              child: AspectRatio(
                aspectRatio: 1.1,
                child: Image.network(
                  char.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(char.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getStatusColor(char.status),
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
                                color: _getStatusColor(char.status),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              char.status,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(char.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    'Informasi Karakter',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(Icons.category_outlined, 'Spesies', char.species),
                  if (char.type.isNotEmpty)
                    _buildInfoTile(Icons.fingerprint, 'Tipe Sub-spesies', char.type),
                  _buildInfoTile(Icons.transgender, 'Gender', char.gender),
                  _buildInfoTile(Icons.public, 'Origin (Asal)', char.originName),
                  _buildInfoTile(Icons.location_on_outlined, 'Location Terakhir', char.locationName),
                  const SizedBox(height: 30),
                  // Tombol Favorite Lebar di Bawah
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingFav ? null : _toggleFavorite,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isFavorite ? 'Hapus dari Daftar Favorit' : 'Tambahkan ke Favorit',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFavorite ? Colors.redAccent : Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
