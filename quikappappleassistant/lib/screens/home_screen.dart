import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/app_theme.dart';
import '../models/downloaded_file.dart';
import 'apps_screen.dart';
import 'certificates_screen.dart';
import 'profiles_screen.dart';
import 'downloads_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const AppsScreen(),
    const CertificatesScreen(),
    const ProfilesScreen(),
    const DownloadsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.apps),
                selectedIcon: Icon(Icons.apps),
                label: Text('Apps'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.security),
                selectedIcon: Icon(Icons.security),
                label: Text('Certificates'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assignment),
                selectedIcon: Icon(Icons.assignment),
                label: Text('Profiles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.download),
                selectedIcon: Icon(Icons.download),
                label: Text('Downloads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),

          // Main Content
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              // Account Menu
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleAccountAction(value, context, appState),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'account',
                    child: Row(
                      children: [
                        const Icon(Icons.account_circle),
                        const SizedBox(width: 8),
                        Text(appState.currentAccountDisplayName),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        child: Text(
                          appState.currentAccountDisplayName.isNotEmpty
                              ? appState.currentAccountDisplayName[0]
                                    .toUpperCase()
                              : 'A',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(appState.currentAccountDisplayName),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back!',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You are signed in as ${appState.currentAccountDisplayName}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Stats
                Text(
                  'Quick Stats',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Stats Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      'Apps',
                      appState.apps.length.toString(),
                      Icons.apps,
                      AppTheme.primaryBlue,
                      () => _navigateToTab(context, 1),
                    ),
                    _buildStatCard(
                      context,
                      'Certificates',
                      appState.certificates.length.toString(),
                      Icons.security,
                      AppTheme.successGreen,
                      () => _navigateToTab(context, 2),
                    ),
                    _buildStatCard(
                      context,
                      'Profiles',
                      appState.profiles.length.toString(),
                      Icons.assignment,
                      AppTheme.warningOrange,
                      () => _navigateToTab(context, 3),
                    ),
                    _buildStatCard(
                      context,
                      'Downloads',
                      appState.downloadedFiles.length.toString(),
                      Icons.download,
                      AppTheme.errorRed,
                      () => _navigateToTab(context, 4),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Recent Activity
                Text(
                  'Recent Downloads',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Recent Downloads List
                if (appState.downloadedFiles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.download_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No downloads yet',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Download certificates, keys, and provisioning profiles to see them here.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: appState.downloadedFiles.take(5).length,
                      itemBuilder: (context, index) {
                        final file = appState.downloadedFiles[index];
                        return ListTile(
                          leading: Icon(
                            _getFileTypeIcon(file.fileType),
                            color: _getFileTypeColor(file.fileType),
                          ),
                          title: Text(
                            file.displayName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          subtitle: Text(
                            '${_getFileTypeDisplayName(file.fileType)} • ${_formatDate(file.downloadedAt)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: Text(
                            _formatFileSize(file.fileSize),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // This would need to be implemented to navigate to specific tabs
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to tab $index'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleAccountAction(
    String action,
    BuildContext context,
    AppState appState,
  ) {
    switch (action) {
      case 'account':
        // Show account details
        break;
      case 'signout':
        _showSignOutDialog(context, appState);
        break;
    }
  }

  Future<void> _showSignOutDialog(
    BuildContext context,
    AppState appState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: Text(
          'Are you sure you want to sign out from ${appState.currentAccountDisplayName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (appState.currentAppleAccount != null) {
          await appState.signOutAppleAccount(appState.currentAppleAccount!.id);
        }
        Navigator.of(context).pushReplacementNamed('/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  // Helper methods for file display
  Color _getFileTypeColor(FileType fileType) {
    switch (fileType) {
      case FileType.certificate:
        return AppTheme.successGreen;
      case FileType.privateKey:
        return AppTheme.warningOrange;
      case FileType.provisioningProfile:
        return AppTheme.primaryBlue;
    }
  }

  IconData _getFileTypeIcon(FileType fileType) {
    switch (fileType) {
      case FileType.certificate:
        return Icons.security;
      case FileType.privateKey:
        return Icons.vpn_key;
      case FileType.provisioningProfile:
        return Icons.assignment;
    }
  }

  String _getFileTypeDisplayName(FileType fileType) {
    switch (fileType) {
      case FileType.certificate:
        return 'Certificate';
      case FileType.privateKey:
        return 'Private Key';
      case FileType.provisioningProfile:
        return 'Provisioning Profile';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
