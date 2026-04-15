import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home tab — featured sections, nearby properties, trending.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('i-Móveis', style: theme.textTheme.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () => context.go('/search'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 12),
                      Text(
                        'Onde você quer morar?',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _CategoryItem(icon: Icons.apartment, label: 'Apê'),
                  _CategoryItem(icon: Icons.house, label: 'Casa'),
                  _CategoryItem(icon: Icons.single_bed, label: 'Kitnet'),
                  _CategoryItem(icon: Icons.business, label: 'Studio'),
                  _CategoryItem(icon: Icons.pets, label: 'Pet friendly'),
                  _CategoryItem(icon: Icons.weekend, label: 'Mobiliado'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Perto de você',
              child: SizedBox(
                height: 200,
                child: Center(child: Text('Cards de imóveis próximos', style: theme.textTheme.bodyMedium)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Mais procurados',
              child: SizedBox(
                height: 200,
                child: Center(child: Text('Cards de imóveis trending', style: theme.textTheme.bodyMedium)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _Section(
              title: 'Exclusivos',
              child: SizedBox(
                height: 200,
                child: Center(child: Text('Cards de imóveis exclusivos', style: theme.textTheme.bodyMedium)),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
