import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/profile.dart';

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddProfileDialog(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appState.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No profiles found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first provisioning profile to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddProfileDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Profile'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.profiles.length,
            itemBuilder: (context, index) {
              final profile = appState.profiles[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getProfileColor(profile.type),
                    child: Icon(
                      _getProfileIcon(profile.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(profile.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${profile.type.name.toUpperCase()}'),
                      Text('App ID: ${profile.appId}'),
                      if (profile.uuid != null) Text('UUID: ${profile.uuid}'),
                      if (profile.expiryDate != null)
                        Text(
                          'Expires: ${profile.expiryDate!.toString().split(' ')[0]}',
                        ),
                      Text(
                        'Status: ${profile.isActive ? "Active" : "Inactive"}',
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
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
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditProfileDialog(context, profile);
                      } else if (value == 'download') {
                        _downloadProfile(context, profile);
                      } else if (value == 'delete') {
                        _showDeleteProfileDialog(context, profile);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getProfileColor(ProfileType type) {
    switch (type) {
      case ProfileType.development:
        return Colors.blue;
      case ProfileType.adhoc:
        return Colors.orange;
      case ProfileType.appstore:
        return Colors.green;
      case ProfileType.enterprise:
        return Colors.purple;
    }
  }

  IconData _getProfileIcon(ProfileType type) {
    switch (type) {
      case ProfileType.development:
        return Icons.developer_mode;
      case ProfileType.adhoc:
        return Icons.devices;
      case ProfileType.appstore:
        return Icons.store;
      case ProfileType.enterprise:
        return Icons.business;
    }
  }

  void _showAddProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddProfileDialog(),
    );
  }

  void _showEditProfileDialog(BuildContext context, Profile profile) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(profile: profile),
    );
  }

  void _downloadProfile(BuildContext context, Profile profile) {
    // TODO: Implement profile download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
  }

  void _showDeleteProfileDialog(BuildContext context, Profile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteProfile(profile.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddProfileDialog extends StatefulWidget {
  const AddProfileDialog({super.key});

  @override
  State<AddProfileDialog> createState() => _AddProfileDialogState();
}

class _AddProfileDialogState extends State<AddProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _appIdController = TextEditingController();
  ProfileType _selectedType = ProfileType.development;

  @override
  void dispose() {
    _nameController.dispose();
    _appIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                hintText: 'Enter profile name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter profile name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID',
                hintText: 'Enter app identifier',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter app ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProfileType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Profile Type'),
              items: ProfileType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final profile = Profile(
                name: _nameController.text,
                type: _selectedType,
                appId: _appIdController.text,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<AppState>().addProfile(profile);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final Profile profile;

  const EditProfileDialog({super.key, required this.profile});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _appIdController;
  late ProfileType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _appIdController = TextEditingController(text: widget.profile.appId);
    _selectedType = widget.profile.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _appIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Profile Name',
                hintText: 'Enter profile name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter profile name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID',
                hintText: 'Enter app identifier',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter app ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProfileType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Profile Type'),
              items: ProfileType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedProfile = widget.profile.copyWith(
                name: _nameController.text,
                type: _selectedType,
                appId: _appIdController.text,
                updatedAt: DateTime.now(),
              );
              context.read<AppState>().updateProfile(updatedProfile);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
