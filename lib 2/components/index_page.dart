import 'package:flutter/material.dart';
import 'dua.dart';
import 'ad_banner.dart';
import 'prophet_duas_page.dart';
import '../services/audio_service.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AdBanner(position: 'Top Ad'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Dua Index',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ),
            const Expanded(child: DuaIndexList()),
            const AdBanner(position: 'Bottom Ad'),
          ],
        ),
      ),
    );
  }
}

class DuaIndexList extends StatelessWidget {
  const DuaIndexList({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: favoriteDuaIndexes,
      builder: (context, favorites, _) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: prophets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final prophet = prophets[index];
            final hasFavorite = prophet.allAyas.any((a) => favorites.contains(a.index));

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFE8DED0)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE7F4EE),
                  foregroundColor: const Color(0xFF1F7A5A),
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  prophet.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  prophet.arabicName,
                  style: const TextStyle(color: Color(0xFF888888)),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasFavorite)
                      const Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                      ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ProphetDuasPage(prophet: prophet),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
