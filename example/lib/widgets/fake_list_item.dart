import 'package:flutter/material.dart';

class FakeListItem extends StatelessWidget {
  const FakeListItem({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final int subtitleLines = 1 + (index % 3);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: <Widget>[
            _FakeAvatar(index: index),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Item #$index', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 4.0),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
                    'Integer eleifend ultricies justo.',
                    maxLines: subtitleLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  _FakeMeta(index: index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeAvatar extends StatelessWidget {
  const _FakeAvatar({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: <Color>[scheme.primaryContainer, scheme.secondaryContainer],
        ),
      ),
      child: Center(
        child: Text(
          '${(index % 9) + 1}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _FakeMeta extends StatelessWidget {
  const _FakeMeta({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.onSurfaceVariant;
    return Wrap(
      spacing: 12.0,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _MetaPill(
          icon: Icons.schedule_rounded,
          label: '${(index % 5) + 1} min read',
          color: color,
        ),
        _MetaPill(
          icon: Icons.star_rounded,
          label: '${4.0 + (index % 7) / 10}',
          color: color,
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14.0, color: color),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
