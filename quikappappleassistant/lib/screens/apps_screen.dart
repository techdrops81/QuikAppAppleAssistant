import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/app_info.dart';

class AppsScreen extends StatelessWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAppDialog(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appState.apps.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.apps,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No apps found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first app to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAppDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add App'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.apps.length,
            itemBuilder: (context, index) {
              final app = appState.apps[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      app.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(app.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bundle ID: ${app.bundleId}'),
                      Text('Team ID: ${app.teamId}'),
                      if (app.description != null)
                        Text('Description: ${app.description}'),
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
                        _showEditAppDialog(context, app);
                      } else if (value == 'delete') {
                        _showDeleteAppDialog(context, app);
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

  void _showAddAppDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddAppDialog());
  }

  void _showEditAppDialog(BuildContext context, AppInfo app) {
    showDialog(
      context: context,
      builder: (context) => EditAppDialog(app: app),
    );
  }

  void _showDeleteAppDialog(BuildContext context, AppInfo app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete App'),
        content: Text('Are you sure you want to delete "${app.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteApp(app.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddAppDialog extends StatefulWidget {
  const AddAppDialog({super.key});

  @override
  State<AddAppDialog> createState() => _AddAppDialogState();
}

class _AddAppDialogState extends State<AddAppDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bundleIdController = TextEditingController();
  final _teamIdController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bundleIdController.dispose();
    _teamIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add App'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                hintText: 'Enter app name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter app name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bundleIdController,
              decoration: const InputDecoration(
                labelText: 'Bundle ID',
                hintText: 'com.example.app',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bundle ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teamIdController,
              decoration: const InputDecoration(
                labelText: 'Team ID',
                hintText: 'Enter team ID',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter team ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
              ),
              maxLines: 3,
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
              final app = AppInfo(
                name: _nameController.text,
                bundleId: _bundleIdController.text,
                teamId: _teamIdController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<AppState>().addApp(app);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class EditAppDialog extends StatefulWidget {
  final AppInfo app;

  const EditAppDialog({super.key, required this.app});

  @override
  State<EditAppDialog> createState() => _EditAppDialogState();
}

class _EditAppDialogState extends State<EditAppDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bundleIdController;
  late final TextEditingController _teamIdController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.app.name);
    _bundleIdController = TextEditingController(text: widget.app.bundleId);
    _teamIdController = TextEditingController(text: widget.app.teamId);
    _descriptionController = TextEditingController(
      text: widget.app.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bundleIdController.dispose();
    _teamIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit App'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'App Name',
                hintText: 'Enter app name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter app name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bundleIdController,
              decoration: const InputDecoration(
                labelText: 'Bundle ID',
                hintText: 'com.example.app',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter bundle ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teamIdController,
              decoration: const InputDecoration(
                labelText: 'Team ID',
                hintText: 'Enter team ID',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter team ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter description',
              ),
              maxLines: 3,
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
              final updatedApp = widget.app.copyWith(
                name: _nameController.text,
                bundleId: _bundleIdController.text,
                teamId: _teamIdController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                updatedAt: DateTime.now(),
              );
              context.read<AppState>().updateApp(updatedApp);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
