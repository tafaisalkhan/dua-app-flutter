import 'package:flutter/material.dart';
import 'dua.dart';
import 'prophet_duas_page.dart';
import 'ad_banner.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F7A5A),
        foregroundColor: Colors.white,
        title: const Text(
          'Favorite Duas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AdBanner(position: 'Top Ad'),
            Expanded(
              child: ValueListenableBuilder<Set<int>>(
                valueListenable: favoriteDuaIndexes,
                builder: (context, favorites, _) {
                  if (favorites.isEmpty) {
                    return const Center(
                      child: Text(
                        'No favorite duas yet.\nTap the heart icon on any dua to add it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  final favoriteAyas = <Aya>[];
                  for (final prophet in prophets) {
                    for (final aya in prophet.allAyas) {
                      if (favorites.contains(aya.index)) {
                        favoriteAyas.add(aya);
                      }
                    }
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteAyas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final aya = favoriteAyas[index];
                      final prophet = prophets.firstWhere(
                        (p) => p.allAyas.contains(aya),
                      );

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Color(0xFFE8DED0)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE7F4EE),
                            foregroundColor: const Color(0xFF1F7A5A),
                            child: Text('${aya.index}'),
                          ),
                          title: Text(
                            prophet.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${aya.chapterName} (${aya.chapterNo}:${aya.ayaNo})',
                            style: const TextStyle(color: Color(0xFF888888)),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProphetDuasPage(prophet: prophet),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const AdBanner(position: 'Bottom Ad'),
          ],
        ),
      ),
    );
  }
}
