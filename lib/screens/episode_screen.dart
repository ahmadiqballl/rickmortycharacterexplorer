import 'package:flutter/material.dart';
import '../models/episode_model.dart';
import '../services/api_service.dart';
import '../theme/rick_morty_theme.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  List<Episode> _episodes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEpisodes();
  }

  Future<void> _fetchEpisodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getEpisodes();
      if (mounted) {
        setState(() {
          _episodes = list;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: RickMortyColors.portalGreen),
            SizedBox(height: 16),
            Text(
              'Memuat database episode...',
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
              const Icon(Icons.videocam_off_rounded, size: 64, color: RickMortyColors.dangerLaser),
              const SizedBox(height: 12),
              const Text(
                'Transmisi Episode Terganggu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: RickMortyColors.dangerLaser),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: RickMortyColors.textDim),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchEpisodes,
                icon: const Icon(Icons.refresh),
                label: const Text('COBA LAGI'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchEpisodes,
      color: RickMortyColors.portalGreen,
      backgroundColor: RickMortyColors.cardDark,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: _episodes.length,
        itemBuilder: (context, index) {
          final ep = _episodes[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: RickMortyColors.portalGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: RickMortyColors.portalGreen.withValues(alpha: 0.4)),
                    ),
                    child: Center(
                      child: Text(
                        '#${ep.id}',
                        style: const TextStyle(
                          color: RickMortyColors.portalGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
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
                          ep.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: RickMortyColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: RickMortyColors.textDim,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              ep.airDate,
                              style: const TextStyle(
                                color: RickMortyColors.textDim,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (ep.episodeCode.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: RickMortyColors.surfaceDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: RickMortyColors.borderGlow),
                      ),
                      child: Text(
                        ep.episodeCode,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: RickMortyColors.rickHairCyan,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
