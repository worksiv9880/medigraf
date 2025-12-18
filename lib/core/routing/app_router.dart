import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/pages/files_page.dart';
import '../../presentation/pages/participants_page.dart';
import '../../presentation/pages/calendar_page.dart';
import '../../presentation/pages/charts_page.dart';
import '../../presentation/pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Список вкладок нижней навигации (порядок важен!)
  const tabs = [
    '/calendar',
    '/files',
    '/charts',
    '/participants',
  ];

  return GoRouter(
    initialLocation: '/calendar',
    routes: [
      // Основной Shell с нижней навигацией
      ShellRoute(
        builder: (context, state, child) {
          // ← Здесь state, а не router!
          // Определяем текущий индекс вкладки по пути (state.uri.path)
          final location = state.uri.path;
          int currentIndex = tabs.indexWhere((tab) => location.startsWith(tab));
          if (currentIndex == -1) currentIndex = 0; // fallback

          return Scaffold(
            body: child, // сюда подставляется страница из вложенных GoRoute
            bottomNavigationBar: BottomNavigationBar(
              type:
                  BottomNavigationBarType.fixed, // обязательно при ≥4 вкладках
              currentIndex: currentIndex,
              onTap: (index) {
                // Используем GoRouter.of(context).go() для навигации
                context.go(tabs[index]);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Календарь',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.folder),
                  label: 'Документы',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Графики',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Участники',
                ),
              ],
            ),
          );
        },
        routes: [
          // Эти 4 маршрута будут внутри Shell (с нижней панелью)
          GoRoute(
            path: '/calendar',
            name: 'calendar',
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: '/files',
            name: 'files',
            builder: (context, state) => const FilesPage(),
          ),
          GoRoute(
            path: '/charts',
            name: 'charts',
            builder: (context, state) => const ChartsPage(),
          ),
          GoRoute(
            path: '/participants',
            name: 'participants',
            builder: (context, state) => const ParticipantsPage(),
          ),
        ],
      ),

      // Этот маршрут ВНЕ Shell — у него НЕ будет нижней навигации
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
});
