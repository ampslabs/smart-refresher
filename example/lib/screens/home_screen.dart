import 'package:flutter/material.dart';

import '../app_router.dart';
import '../main.dart';

class IndicatorEntry {
  const IndicatorEntry({
    required this.name,
    required this.tagline,
    required this.icon,
    required this.route,
  });

  final String name;
  final String tagline;
  final IconData icon;
  final String route;
}

const List<IndicatorEntry> _headers = <IndicatorEntry>[
  IndicatorEntry(
    name: 'ClassicHeader',
    tagline: 'Arrow + text, works everywhere',
    icon: Icons.arrow_downward_rounded,
    route: AppRoutes.classicHeader,
  ),
  IndicatorEntry(
    name: 'Material3Header',
    tagline: 'Floating M3 circular spinner',
    icon: Icons.radio_button_checked_rounded,
    route: AppRoutes.material3Header,
  ),
  IndicatorEntry(
    name: 'iOS17Header',
    tagline: 'Native spoke wheel, haptic aware',
    icon: Icons.blur_circular_rounded,
    route: AppRoutes.ios17Header,
  ),
];

const List<IndicatorEntry> _footers = <IndicatorEntry>[
  IndicatorEntry(
    name: 'ClassicFooter',
    tagline: 'Text + spinner load more',
    icon: Icons.expand_more_rounded,
    route: AppRoutes.classicFooter,
  ),
  IndicatorEntry(
    name: 'SkeletonFooter',
    tagline: 'Preview next rows as they load',
    icon: Icons.view_agenda_rounded,
    route: AppRoutes.skeletonFooter,
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('smart_refresher'),
        actions: const <Widget>[ThemeModeToggle()],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[scheme.surfaceContainerLowest, scheme.surface],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            _IntroCard(scheme: scheme),
            const SizedBox(height: 20.0),
            _SectionCard(
              title: 'HEADERS',
              entries: _headers,
              actionLabel: 'Compare All Headers →',
              actionRoute: AppRoutes.headerCompare,
            ),
            const SizedBox(height: 16.0),
            _SectionCard(
              title: 'FOOTERS',
              entries: _footers,
              actionLabel: 'Compare All Footers →',
              actionRoute: AppRoutes.footerCompare,
            ),
            const SizedBox(height: 16.0),
            _SectionCard(
              title: 'THEMING',
              entries: const <IndicatorEntry>[
                IndicatorEntry(
                  name: 'Live Theme Switcher',
                  tagline: 'Trace color resolution in real time',
                  icon: Icons.palette_outlined,
                  route: AppRoutes.theming,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.0),
        gradient: LinearGradient(
          colors: <Color>[scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: Text(
        'Modern pull-to-refresh headers, polished load-more footers, '
        'and live theming previews in one catalog app.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.entries,
    this.actionLabel,
    this.actionRoute,
  });

  final String title;
  final List<IndicatorEntry> entries;
  final String? actionLabel;
  final String? actionRoute;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12.0),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: entries
                  .map((IndicatorEntry entry) => _IndicatorCard(entry: entry))
                  .toList(),
            ),
            if (actionLabel != null && actionRoute != null) ...<Widget>[
              const SizedBox(height: 12.0),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pushNamed(actionRoute!),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(actionLabel!, textAlign: TextAlign.center),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({required this.entry});

  final IndicatorEntry entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 2.0,
      borderRadius: BorderRadius.circular(16.0),
      color: scheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () => Navigator.of(context).pushNamed(entry.route),
        child: SizedBox(
          width: 180.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(entry.icon, color: scheme.primary),
                const SizedBox(height: 12.0),
                Text(
                  entry.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6.0),
                Text(
                  entry.tagline,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
