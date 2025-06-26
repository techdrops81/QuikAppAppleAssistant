import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/profile.dart';
import '../utils/app_theme.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provisioning Profiles'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Profiles')),
              const PopupMenuItem(
                value: 'development',
                child: Text('Development'),
              ),
              const PopupMenuItem(
                value: 'distribution',
                child: Text('Distribution'),
              ),
              const PopupMenuItem(value: 'active', child: Text('Active')),
              const PopupMenuItem(value: 'expired', child: Text('Expired')),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getFilterDisplayName()),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profiles = _getFilteredProfiles(appState.profiles);

          if (profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No profiles found',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create or import provisioning profiles to see them here.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _buildProfileCard(profile, appState);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProfileDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Profile> _getFilteredProfiles(List<Profile> allProfiles) {
    switch (_selectedFilter) {
      case 'development':
        return allProfiles
            .where((p) => p.type.toLowerCase().contains('development'))
            .toList();
      case 'distribution':
        return allProfiles
            .where((p) => p.type.toLowerCase().contains('distribution'))
            .toList();
      case 'active':
        return allProfiles
            .where((p) => p.status.toLowerCase() == 'active')
            .toList();
      case 'expired':
        return allProfiles
            .where(
              (p) =>
                  p.expirationDate != null &&
                  p.expirationDate!.isBefore(DateTime.now()),
            )
            .toList();
      default:
        return allProfiles;
    }
  }

  String _getFilterDisplayName() {
    switch (_selectedFilter) {
      case 'development':
        return 'Development';
      case 'distribution':
        return 'Distribution';
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      default:
        return 'All Profiles';
    }
  }

  Widget _buildProfileCard(Profile profile, AppState appState) {
    final isExpired =
        profile.expirationDate != null &&
        profile.expirationDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getProfileStatusColor(
              profile.status,
              isExpired,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description,
            color: _getProfileStatusColor(profile.status, isExpired),
          ),
        ),
        title: Text(
          profile.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Type: ${profile.type}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Status: ${profile.status}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (profile.appId != null)
              Text(
                'App ID: ${profile.appId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (profile.expirationDate != null)
              Text(
                'Expires: ${_formatDate(profile.expirationDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isExpired ? AppTheme.errorRed : null,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleProfileAction(value, profile, appState),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Download'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showProfileDetails(profile),
      ),
    );
  }

  Color _getProfileStatusColor(String status, bool isExpired) {
    if (isExpired) return AppTheme.errorRed;

    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningOrange;
      case 'expired':
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleProfileAction(String action, Profile profile, AppState appState) {
    switch (action) {
      case 'download':
        _downloadProfile(profile);
        break;
      case 'edit':
        _showEditProfileDialog(context, profile);
        break;
      case 'delete':
        _deleteProfile(profile, appState);
        break;
    }
  }

  void _downloadProfile(Profile profile) {
    // TODO: Implement profile download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${profile.name}...'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _showProfileDetails(Profile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(profile.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${profile.type}'),
            Text('Status: ${profile.status}'),
            Text('Team ID: ${profile.teamId}'),
            if (profile.appId != null) Text('App ID: ${profile.appId}'),
            if (profile.certificateIds != null)
              Text('Certificate IDs: ${profile.certificateIds}'),
            if (profile.expirationDate != null)
              Text('Expires: ${_formatDate(profile.expirationDate!)}'),
            Text('Created: ${_formatDate(profile.createdAt)}'),
            Text('Updated: ${_formatDate(profile.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProfile(Profile profile, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text(
          'Are you sure you want to delete "${profile.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await appState.removeProfile(profile.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile "${profile.name}" deleted successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete profile: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showAddProfileDialog(BuildContext context) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final teamIdController = TextEditingController();
    final appIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                hintText: 'Enter profile name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                hintText: 'e.g., Development, Distribution',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: teamIdController,
              decoration: const InputDecoration(
                labelText: 'Team ID',
                hintText: 'Enter team ID',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID (Optional)',
                hintText: 'Enter app ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  typeController.text.isNotEmpty &&
                  teamIdController.text.isNotEmpty) {
                final profile = Profile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: typeController.text,
                  status: 'Active',
                  teamId: teamIdController.text,
                  appId: appIdController.text.isNotEmpty
                      ? appIdController.text
                      : null,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                context.read<AppState>().addProfile(profile);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Profile "${profile.name}" added successfully',
                    ),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, Profile profile) {
    final nameController = TextEditingController(text: profile.name);
    final typeController = TextEditingController(text: profile.type);
    final teamIdController = TextEditingController(text: profile.teamId);
    final appIdController = TextEditingController(text: profile.appId ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                hintText: 'Enter profile name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(
                labelText: 'Type',
                hintText: 'e.g., Development, Distribution',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: teamIdController,
              decoration: const InputDecoration(
                labelText: 'Team ID',
                hintText: 'Enter team ID',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID (Optional)',
                hintText: 'Enter app ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  typeController.text.isNotEmpty &&
                  teamIdController.text.isNotEmpty) {
                final updatedProfile = profile.copyWith(
                  name: nameController.text,
                  type: typeController.text,
                  teamId: teamIdController.text,
                  appId: appIdController.text.isNotEmpty
                      ? appIdController.text
                      : null,
                  updatedAt: DateTime.now(),
                );

                context.read<AppState>().updateProfile(updatedProfile);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Profile "${updatedProfile.name}" updated successfully',
                    ),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
