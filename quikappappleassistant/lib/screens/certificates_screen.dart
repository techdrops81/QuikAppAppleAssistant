import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/certificate.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCertificateDialog(context),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appState.certificates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No certificates found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first certificate to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCertificateDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Certificate'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appState.certificates.length,
            itemBuilder: (context, index) {
              final certificate = appState.certificates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getCertificateColor(certificate.type),
                    child: Icon(
                      _getCertificateIcon(certificate.type),
                      color: Colors.white,
                    ),
                  ),
                  title: Text(certificate.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${certificate.type.name.toUpperCase()}'),
                      if (certificate.serialNumber != null)
                        Text('Serial: ${certificate.serialNumber}'),
                      if (certificate.expiryDate != null)
                        Text(
                          'Expires: ${certificate.expiryDate!.toString().split(' ')[0]}',
                        ),
                      Text(
                        'Status: ${certificate.isActive ? "Active" : "Inactive"}',
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
                        _showEditCertificateDialog(context, certificate);
                      } else if (value == 'download') {
                        _downloadCertificate(context, certificate);
                      } else if (value == 'delete') {
                        _showDeleteCertificateDialog(context, certificate);
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

  Color _getCertificateColor(CertificateType type) {
    switch (type) {
      case CertificateType.development:
        return Colors.blue;
      case CertificateType.distribution:
        return Colors.green;
      case CertificateType.push:
        return Colors.orange;
    }
  }

  IconData _getCertificateIcon(CertificateType type) {
    switch (type) {
      case CertificateType.development:
        return Icons.developer_mode;
      case CertificateType.distribution:
        return Icons.cloud_upload;
      case CertificateType.push:
        return Icons.notifications;
    }
  }

  void _showAddCertificateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCertificateDialog(),
    );
  }

  void _showEditCertificateDialog(
    BuildContext context,
    Certificate certificate,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditCertificateDialog(certificate: certificate),
    );
  }

  void _downloadCertificate(BuildContext context, Certificate certificate) {
    // TODO: Implement certificate download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality coming soon')),
    );
  }

  void _showDeleteCertificateDialog(
    BuildContext context,
    Certificate certificate,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text('Are you sure you want to delete "${certificate.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteCertificate(certificate.id!);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddCertificateDialog extends StatefulWidget {
  const AddCertificateDialog({super.key});

  @override
  State<AddCertificateDialog> createState() => _AddCertificateDialogState();
}

class _AddCertificateDialogState extends State<AddCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CertificateType _selectedType = CertificateType.development;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Certificate'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Certificate Name',
                hintText: 'Enter certificate name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter certificate name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CertificateType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Certificate Type'),
              items: CertificateType.values.map((type) {
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
              final certificate = Certificate(
                name: _nameController.text,
                type: _selectedType,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              context.read<AppState>().addCertificate(certificate);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class EditCertificateDialog extends StatefulWidget {
  final Certificate certificate;

  const EditCertificateDialog({super.key, required this.certificate});

  @override
  State<EditCertificateDialog> createState() => _EditCertificateDialogState();
}

class _EditCertificateDialogState extends State<EditCertificateDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CertificateType _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.certificate.name);
    _selectedType = widget.certificate.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Certificate'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Certificate Name',
                hintText: 'Enter certificate name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter certificate name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<CertificateType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Certificate Type'),
              items: CertificateType.values.map((type) {
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
              final updatedCertificate = widget.certificate.copyWith(
                name: _nameController.text,
                type: _selectedType,
                updatedAt: DateTime.now(),
              );
              context.read<AppState>().updateCertificate(updatedCertificate);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}
