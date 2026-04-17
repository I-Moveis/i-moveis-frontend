import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_contracts_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_listings_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/listing/presentation/pages/create_listing_page.dart';
import '../../features/listing/presentation/pages/listing_analytics_page.dart';
import '../../features/listing/presentation/pages/my_properties_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/property/presentation/pages/photo_gallery_page.dart';
import '../../features/property/presentation/pages/property_detail_page.dart';
import '../../features/proposal/presentation/pages/contract_page.dart';
import '../../features/proposal/presentation/pages/make_proposal_page.dart';
import '../../features/schedule/presentation/pages/schedule_visit_page.dart';
import '../../features/search/presentation/pages/map_search_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

// Navigator keys for each shell branch.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'favorites');
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Provider for GoRouter configuration.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // ── Auth flow ────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordPage(),
      ),

      // ── Main shell (bottom nav) ──────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShellPage(
          navigationShell: navigationShell,
        ),
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, _) => const HomePage(),
              ),
            ],
          ),

          // Branch 1: Search
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (_, _) => const SearchPage(),
                routes: [
                  GoRoute(
                    path: 'map',
                    builder: (_, _) => const MapSearchPage(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Favorites
          StatefulShellBranch(
            navigatorKey: _favoritesNavigatorKey,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (_, _) => const FavoritesPage(),
              ),
            ],
          ),

          // Branch 3: Chat
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                builder: (_, _) => const ConversationsPage(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, _) => const ProfilePage(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (_, _) => const EditProfilePage(),
                  ),
                  GoRoute(
                    path: 'settings',
                    builder: (_, _) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: 'my-properties',
                    builder: (_, _) => const MyPropertiesPage(),
                    routes: [
                      GoRoute(
                        path: 'create',
                        builder: (_, _) => const CreateListingPage(),
                      ),
                      GoRoute(
                        path: 'analytics',
                        builder: (_, _) => const ListingAnalyticsPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Chat detail (full screen, outside shell) ──────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/chat/:conversationId',
        builder: (_, state) => ChatPage(
          conversationId: state.pathParameters['conversationId']!,
        ),
      ),

      // ── Property detail (full screen, outside shell) ─────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/property/:id',
        builder: (_, state) => PropertyDetailPage(
          propertyId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'photos',
            builder: (_, state) => PhotoGalleryPage(
              propertyId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'schedule',
            builder: (_, state) => ScheduleVisitPage(
              propertyId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'proposal',
            builder: (_, state) => MakeProposalPage(
              propertyId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'contract',
            builder: (_, state) => ContractPage(
              propertyId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),

      // ── Admin routes ─────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/admin',
        builder: (_, _) => const AdminDashboardPage(),
        routes: [
          GoRoute(
            path: 'users',
            builder: (_, _) => const AdminUsersPage(),
          ),
          GoRoute(
            path: 'listings',
            builder: (_, _) => const AdminListingsPage(),
          ),
          GoRoute(
            path: 'contracts',
            builder: (_, _) => const AdminContractsPage(),
          ),
        ],
      ),
    ],
  );

});
