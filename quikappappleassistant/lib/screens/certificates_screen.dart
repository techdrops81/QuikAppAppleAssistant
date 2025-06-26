import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/certificate.dart';
import '../utils/app_theme.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Certificates'),
              ),
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

          final certificates = _getFilteredCertificates(appState.certificates);

          if (certificates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No certificates found',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create or import certificates to see them here.',
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
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final certificate = certificates[index];
              return _buildCertificateCard(certificate, appState);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCertificateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Certificate> _getFilteredCertificates(
    List<Certificate> allCertificates,
  ) {
    switch (_selectedFilter) {
      case 'development':
        return allCertificates
            .where((c) => c.type.toLowerCase().contains('development'))
            .toList();
      case 'distribution':
        return allCertificates
            .where((c) => c.type.toLowerCase().contains('distribution'))
            .toList();
      case 'active':
        return allCertificates
            .where((c) => c.status.toLowerCase() == 'active')
            .toList();
      case 'expired':
        return allCertificates
            .where(
              (c) =>
                  c.expirationDate != null &&
                  c.expirationDate!.isBefore(DateTime.now()),
            )
            .toList();
      default:
        return allCertificates;
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
        return 'All Certificates';
    }
  }

  Widget _buildCertificateCard(Certificate certificate, AppState appState) {
    final isExpired =
        certificate.expirationDate != null &&
        certificate.expirationDate!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getCertificateStatusColor(
              certificate.status,
              isExpired,
            ).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.security,
            color: _getCertificateStatusColor(certificate.status, isExpired),
          ),
        ),
        title: Text(
          certificate.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Type: ${certificate.type}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Status: ${certificate.status}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (certificate.expirationDate != null)
              Text(
                'Expires: ${_formatDate(certificate.expirationDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isExpired ? AppTheme.errorRed : null,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) =>
              _handleCertificateAction(value, certificate, appState),
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
        onTap: () => _showCertificateDetails(certificate),
      ),
    );
  }

  Color _getCertificateStatusColor(String status, bool isExpired) {
    if (isExpired) return AppTheme.errorRed;

    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningOrange;
      case 'revoked':
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGray;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleCertificateAction(
    String action,
    Certificate certificate,
    AppState appState,
  ) {
    switch (action) {
      case 'download':
        _downloadCertificate(certificate);
        break;
      case 'edit':
        _showEditCertificateDialog(context, certificate);
        break;
      case 'delete':
        _deleteCertificate(certificate, appState);
        break;
    }
  }

  void _downloadCertificate(Certificate certificate) {
    // TODO: Implement certificate download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${certificate.name}...'),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }

  void _showCertificateDetails(Certificate certificate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(certificate.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${certificate.type}'),
            Text('Status: ${certificate.status}'),
            Text('Team ID: ${certificate.teamId}'),
            if (certificate.expirationDate != null)
              Text('Expires: ${_formatDate(certificate.expirationDate!)}'),
            Text('Created: ${_formatDate(certificate.createdAt)}'),
            Text('Updated: ${_formatDate(certificate.updatedAt)}'),
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

  Future<void> _deleteCertificate(
    Certificate certificate,
    AppState appState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content: Text(
          'Are you sure you want to delete "${certificate.name}"? This action cannot be undone.',
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
        await appState.removeCertificate(certificate.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Certificate "${certificate.name}" deleted successfully',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete certificate: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showAddCertificateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final typeController = TextEditingController();
    final teamIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Certificate Name',
                hintText: 'Enter certificate name',
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
                final certificate = Certificate(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  type: typeController.text,
                  status: 'Active',
                  teamId: teamIdController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                context.read<AppState>().addCertificate(certificate);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Certificate "${certificate.name}" added successfully',
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

  void _showEditCertificateDialog(
    BuildContext context,
    Certificate certificate,
  ) {
    final nameController = TextEditingController(text: certificate.name);
    final typeController = TextEditingController(text: certificate.type);
    final teamIdController = TextEditingController(text: certificate.teamId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Certificate Name',
                hintText: 'Enter certificate name',
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
                final updatedCertificate = certificate.copyWith(
                  name: nameController.text,
                  type: typeController.text,
                  teamId: teamIdController.text,
                  updatedAt: DateTime.now(),
                );

                context.read<AppState>().updateCertificate(updatedCertificate);
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Certificate "${updatedCertificate.name}" updated successfully',
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
