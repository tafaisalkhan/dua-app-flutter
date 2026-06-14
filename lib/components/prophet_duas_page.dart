import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dua.dart';
import 'ad_banner.dart';
import '../services/audio_service.dart';
import '../services/settings_service.dart';

class ProphetDuasPage extends StatefulWidget {
  const ProphetDuasPage({super.key, required this.prophet});

  final Prophet prophet;

  @override
  State<ProphetDuasPage> createState() => _ProphetDuasPageState();
}

class _ProphetDuasPageState extends State<ProphetDuasPage> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _controller.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    final page = _controller.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageChanged);
    _controller.dispose();
    super.dispose();
  }

  void _goToPrev() {
    if (_currentPage > 0) {
      _controller.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentPage < widget.prophet.allAyas.length - 1) {
      _controller.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ayas = widget.prophet.allAyas;
    final total = ayas.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F7A5A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AdBanner(position: 'Top Ad'),
            // Prophet name header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1F7A5A),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.prophet.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white),
                  ),
                  Text(
                    widget.prophet.arabicName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEAF8F2),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            // Page counter
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Dua ${_currentPage + 1} of $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888888),
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: ayas.isEmpty
                  ? const Center(
                      child: Text(
                        'No Duas found for this Prophet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : PageView.builder(
                      controller: _controller,
                      itemCount: ayas.length,
                      itemBuilder: (context, index) {
                        final aya = ayas[index];
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: DuaCard(aya: aya),
                        );
                      },
                    ),
            ),
            // Navigation controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE8DED0)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    color: _currentPage > 0 ? const Color(0xFF1F7A5A) : Colors.grey.shade400,
                    onPressed: _currentPage > 0 ? _goToPrev : null,
                  ),
                  Text(
                    widget.prophet.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F7A5A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    color: _currentPage < total - 1 ? const Color(0xFF1F7A5A) : Colors.grey.shade400,
                    onPressed: _currentPage < total - 1 ? _goToNext : null,
                  ),
                ],
              ),
            ),
            const AdBanner(position: 'Bottom Ad'),
          ],
        ),
      ),
    );
  }
}

class DuaCard extends StatelessWidget {
  const DuaCard({super.key, required this.aya});

  final Aya aya;

  Future<void> _copyDua(BuildContext context) async {
    final lang = SettingsService.selectedLanguage.value;
    final translation = SettingsService.getTranslation({
      'english': aya.english,
      'spanish': aya.spanish,
      'chinses': aya.chinese,
      'japanses': aya.japanese,
      'urdu': aya.urdu,
      'turkish': aya.turkish,
    }, lang);
    final text = '${aya.arabic}\n\n${SettingsService.languageNames[lang]}: $translation';
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dua copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _playAudio(BuildContext context) {
    if (aya.mp3FilePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No audio available for this dua'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    AudioService.play('audio/${aya.mp3FilePath}');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE8DED0)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chapter and verse header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${aya.chapterName.toUpperCase()} (${aya.chapterNo}:${aya.ayaNo})',
                  style: const TextStyle(
                    color: Color(0xFFC68B2C),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFE7F4EE),
                  child: Text(
                    '${aya.index}',
                    style: const TextStyle(
                      color: Color(0xFF1F7A5A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Arabic text section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF7EFE5)),
              ),
              child: Column(
                children: [
                  if (aya.bismial.isNotEmpty) ...[
                    Text(
                      aya.bismial,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F7A5A),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    aya.arabic,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Translations
            ValueListenableBuilder<String>(
              valueListenable: SettingsService.selectedLanguage,
              builder: (context, language, _) {
                final translation = SettingsService.getTranslation({
                  'english': aya.english,
                  'spanish': aya.spanish,
                  'chinses': aya.chinese,
                  'japanses': aya.japanese,
                  'urdu': aya.urdu,
                  'turkish': aya.turkish,
                }, language);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      SettingsService.languageNames[language] ?? language,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF1F7A5A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translation,
                      textAlign: language == 'urdu' ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: language == 'urdu' ? 15 : 14,
                        color: const Color(0xFF4A4A4A),
                        height: 1.5,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Actions row (Play, Copy, Favorite)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: AudioService.isPlaying,
                  builder: (context, playing, _) {
                    final isCurrent = playing && AudioService.currentPath == 'audio/${aya.mp3FilePath}';
                    return IconButton(
                      tooltip: isCurrent ? 'Stop audio' : 'Play audio',
                      icon: Icon(
                        isCurrent ? Icons.stop_circle_outlined : Icons.play_circle_filled_rounded,
                        color: const Color(0xFF1F7A5A),
                        size: 28,
                      ),
                      onPressed: () {
                        if (isCurrent) {
                          AudioService.stop();
                        } else {
                          _playAudio(context);
                        }
                      },
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Copy text',
                  icon: const Icon(Icons.copy_rounded, color: Colors.grey, size: 22),
                  onPressed: () => _copyDua(context),
                ),
                ValueListenableBuilder<Set<int>>(
                  valueListenable: favoriteDuaIndexes,
                  builder: (context, favorites, _) {
                    final isFavorite = favorites.contains(aya.index);
                    return IconButton(
                      tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.grey,
                        size: 22,
                      ),
                      onPressed: () {
                        final updated = Set<int>.of(favorites);
                        if (!updated.add(aya.index)) {
                          updated.remove(aya.index);
                        }
                        favoriteDuaIndexes.value = updated;
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
