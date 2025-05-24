import 'package:flutter/material.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/consultation/consulation_page.dart';
import '../presentation/pages/card_selection/card_selection_page.dart';
import '../presentation/pages/result/result_page.dart';
import '../presentation/pages/history/history_page.dart';
import '../presentation/pages/settings/settings_page.dart';

  enum TransitionType {
    fade,
    slide,
    scale,
  }

class Routes {
  static const String initial = '/';
  
  static const String consultation = '/consultation';
  
  static const String cardSelection = '/card-selection';
  
  static const String result = '/result';
  
  static const String history = '/history';
  
  static const String settings = '/settings';
  
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // initial: (context) => const HomePage(),
      consultation: (context) => const ConsultationPage(),
      cardSelection: (context) => const CardSelectionPage(),
      result: (context) => const ResultPage(),
      history: (context) => const HistoryPage(),
      settings: (context) => const SettingsPage(),
    };
  }
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.consultation:
        return _buildTransitionRoute(
          const ConsultationPage(),
          settings,
          TransitionType.slide,
        );
      case Routes.cardSelection:
        return _buildTransitionRoute(
          const CardSelectionPage(),
          settings,
          TransitionType.fade,
        );
      case Routes.result:
        return _buildTransitionRoute(
          const ResultPage(),
          settings,
          TransitionType.fade,
        );
      case Routes.history:
        return _buildTransitionRoute(
          const HistoryPage(),
          settings,
          TransitionType.slide,
        );
      case Routes.settings:
        return _buildTransitionRoute(
          const SettingsPage(),
          settings,
          TransitionType.slide,
        );
      default:
        return _buildTransitionRoute(
          const HomePage(),
          settings,
          TransitionType.fade,
        );
    }
  }
  
  
  static PageRouteBuilder _buildTransitionRoute(
    Widget page,
    RouteSettings settings,
    TransitionType type,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return page;
      },
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        switch (type) {
          case TransitionType.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case TransitionType.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case TransitionType.scale:
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: child,
            );
          default:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
        }
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}