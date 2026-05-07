import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_contracts_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_listings_page.dart';
import '../../features/admin/presentation/pages/admin_reports_page.dart';
import '../../features/admin/presentation/pages/admin_users_page.dart';
import '../../features/admin_users/presentation/pages/admin_user_form_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/role_onboarding_page.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/providers/auth_status_provider.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/conversations_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/landlord_dashboard_page.dart';
import '../../features/listing/presentation/pages/create_listing_page.dart';
import '../../features/listing/presentation/pages/edit_listing_page.dart';
import '../../features/listing/presentation/pages/listing_analytics_page.dart';
import '../../features/listing/presentation/pages/my_properties_page.dart';
import '../../features/listing/presentation/pages/property_management_dossier_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/management/tenant_contract_page.dart';
import '../../features/profile/presentation/pages/management/tenant_documents_page.dart';
import '../../features/profile/presentation/pages/management/tenant_rent_history_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/tenants_page.dart';
import '../../features/property/presentation/pages/photo_gallery_page.dart';
import '../../features/property/presentation/pages/property_detail_page.dart';
import '../../features/proposal/presentation/pages/contract_page.dart';
import '../../features/proposal/presentation/pages/make_proposal_page.dart';
import '../../features/schedule/presentation/pages/schedule_visit_page.dart';
import '../../features/search/presentation/pages/map_search_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/search/presentation/providers/search_filters_provider.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/support/presentation/pages/support_ticket_page.dart';
import '../../features/visits/presentation/pages/edit_visit_page.dart';
import '../../features/visits/presentation/pages/landlord_visits_page.dart';
import '../../features/visits/presentation/pages/my_visits_page.dart';
import '../../features/visits/presentation/pages/visit_detail_page.dart';

// Navigator keys for each shell branch.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _searchNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _favoritesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'favorites');
final _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final _profileNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profile');
final _myPropertiesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'my-properties');

/// Paths allowed for users without an authenticated session.
const _publicPaths = <String>{
  '/splash',
  '/onboarding',
  '/login',
  '/register',
  '/forgot-password',
};

/// Provider for GoRouter configuration.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final status = ref.read(authStatusProvider);
      final location = state.matchedLocation;
      final isPublic = _publicPaths.any(location.startsWith);

      // Don't redirect until the splash has resolved the session.
      if (status == AuthStatus.unknown) return null;

      if (status == AuthStatus.unauthenticated && !isPublic) {
        return '/login';
      }
      return null;
    },
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
      GoRoute(
        path: '/onboarding/role',
        builder: (_, _) => const RoleOnboardingPage(),
      ),

      // Legacy redirect for moved properties route
      GoRoute(
        path: '/profile/my-properties',
        redirect: (_, __) => '/my-properties',
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
                builder: (_, _) => const _HomeBranch(),
              ),
            ],
          ),

          // Branch 1: Search
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) {
                  final params = state.uri.queryParameters;
                  final initialFilters = params.isEmpty
                      ? null
                      : SearchFilters.fromQueryParams(params);
                  // Deep link do bot WhatsApp chega com query params
                  // (state, city, maxPrice). Sem params, usa filtros
                  // persistidos do usuário.
                  return _SearchBranch(initialFilters: initialFilters);
                },
                routes: [
                  GoRoute(
                    path: 'map',
                    builder: (_, _) => const MapSearchPage(),
                  ),
                  GoRoute(
                    path: 'documents',
                    builder: (_, state) => TenantDocumentsPage(
                      tenantName: state.uri.queryParameters['name'] ?? 'Inquilino',
                    ),
                  ),
                  GoRoute(
                    path: 'rent-history',
                    builder: (_, state) => TenantRentHistoryPage(
                      tenantName: state.uri.queryParameters['name'] ?? 'Inquilino',
                    ),
                  ),
                  GoRoute(
                    path: 'contract',
                    builder: (_, state) => TenantContractPage(
                      tenantName:
                          state.uri.queryParameters['name'] ?? 'Inquilino',
                      propertyId: state.uri.queryParameters['propertyId'],
                      tenantId: state.uri.queryParameters['tenantId'],
                    ),
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
                    path: 'my-visits',
                    builder: (_, _) => const MyVisitsPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (_, state) => VisitDetailPage(
                          visitId: state.pathParameters['id']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (_, state) => EditVisitPage(
                              visitId: state.pathParameters['id']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'landlord-visits',
                    builder: (_, _) => const LandlordVisitsPage(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 5: My Properties (Landlord specific top-level)
          StatefulShellBranch(
            navigatorKey: _myPropertiesNavigatorKey,
            routes: [
              GoRoute(
                path: '/my-properties',
                builder: (_, _) => const MyPropertiesPage(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'create',
                    builder: (_, _) => const CreateListingPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: ':id/analytics',
                    builder: (_, state) => ListingAnalyticsPage(
                      propertyId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: ':id/edit',
                    builder: (_, state) => EditListingPage(
                      propertyId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/management-dossier',
        builder: (_, _) => const PropertyManagementDossierPage(),
      ),

      // Alias no root para a página de visitas do landlord. A rota aninhada
      // `/profile/landlord-visits` (dentro da branch 4) continua funcionando
      // a partir do menu do perfil, mas não é acessível via `context.push`
      // a partir de outras branches do shell (ex.: a dashboard no branch 0)
      // no go_router 17 — por isso expomos uma rota top-level equivalente
      // que roda em cima do shell (mesmo padrão do /management-dossier).
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/landlord-visits',
        builder: (_, _) => const LandlordVisitsPage(),
      ),

      // Tela de suporte acessada pelo menu "Suporte" no perfil. No root
      // navigator (mesmo padrão do /management-dossier) pra abrir full-
      // screen em cima do shell, com botão de voltar nativo.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/support',
        builder: (_, _) => const SupportTicketPage(),
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
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const AdminUserFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (_, state) => AdminUserFormPage(
                  userId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: 'listings',
            builder: (_, _) => const AdminListingsPage(),
          ),
          GoRoute(
            path: 'contracts',
            builder: (_, _) => const AdminContractsPage(),
          ),
          GoRoute(
            path: 'reports',
            builder: (_, _) => const AdminReportsPage(),
          ),
        ],
      ),
    ],
  );
});

/// Escolhe qual página renderizar em `/home` com base no papel do usuário.
/// `LandlordDashboardPage` para LANDLORD; `HomePage` para TENANT e estados
/// transitórios. Extraído pra fora do builder da GoRoute para reagir
/// corretamente quando o role muda (ex: logo após `_syncBackendIdentity`).
class _HomeBranch extends ConsumerWidget {
  const _HomeBranch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isOwner = authState.maybeWhen(
      authenticated: (user) => user.isOwner,
      orElse: () => false,
    );
    if (kDebugMode) {
      debugPrint('[router] /home → isOwner=$isOwner');
    }
    return isOwner ? const LandlordDashboardPage() : const HomePage();
  }
}

/// Escolhe entre `SearchPage` (TENANT) e `TenantsPage` (LANDLORD).
class _SearchBranch extends ConsumerWidget {
  const _SearchBranch({this.initialFilters});

  final SearchFilters? initialFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner = ref.watch(authNotifierProvider).maybeWhen(
          authenticated: (user) => user.isOwner,
          orElse: () => false,
        );
    if (isOwner) return const TenantsPage();
    return SearchPage(initialFilters: initialFilters);
  }
}
