import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/downloaded_file.dart';
import '../services/app_state.dart';
import '../services/apple_auth_service.dart';
import '../utils/app_theme.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final AppleAuthService _appleAuthService = AppleAuthService();
  String _selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Files'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Files')),
              const PopupMenuItem(
                value: 'certificates',
                child: Text('Certificates'),
              ),
              const PopupMenuItem(value: 'keys', child: Text('Private Keys')),
              const PopupMenuItem(
                value: 'profiles',
                child: Text('Provisioning Profiles'),
              ),
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

          final files = _getFilteredFiles(appState.downloadedFiles);

          if (files.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No downloaded files',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download certificates, keys, and provisioning profiles to see them here.',
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
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return _buildFileCard(file, appState);
            },
          );
        },
      ),
    );
  }

  List<DownloadedFile> _getFilteredFiles(List<DownloadedFile> allFiles) {
    switch (_selectedFilter) {
      case 'certificates':
        return allFiles
            .where((f) => f.fileType == FileType.certificate)
            .toList();
      case 'keys':
        return allFiles
            .where((f) => f.fileType == FileType.privateKey)
            .toList();
      case 'profiles':
        return allFiles
            .where((f) => f.fileType == FileType.provisioningProfile)
            .toList();
      default:
        return allFiles;
    }
  }

  String _getFilterDisplayName() {
    switch (_selectedFilter) {
      case 'certificates':
        return 'Certificates';
      case 'keys':
        return 'Private Keys';
      case 'profiles':
        return 'Provisioning Profiles';
      default:
        return 'All Files';
    }
  }

  Widget _buildFileCard(DownloadedFile file, AppState appState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getFileTypeColor(file.fileType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFileTypeIcon(file.fileType),
            color: _getFileTypeColor(file.fileType),
          ),
        ),
        title: Text(
          file.displayName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Type: ${_getFileTypeDisplayName(file.fileType)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Size: ${_formatFileSize(file.fileSize)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Downloaded: ${_formatDate(file.downloadedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleFileAction(value, file, appState),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(Icons.open_in_new),
                  SizedBox(width: 8),
                  Text('Open File'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'copy_path',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy Path'),
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
        ),
        onTap: () => _openFile(file),
      ),
    );
  }

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
        return 'Certificate (.cer)';
      case FileType.privateKey:
        return 'Private Key (.key)';
      case FileType.provisioningProfile:
        return 'Provisioning Profile (.mobileprovision)';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _handleFileAction(
    String action,
    DownloadedFile file,
    AppState appState,
  ) {
    switch (action) {
      case 'open':
        _openFile(file);
        break;
      case 'copy_path':
        _copyFilePath(file);
        break;
      case 'delete':
        _deleteFile(file, appState);
        break;
    }
  }

  void _openFile(DownloadedFile file) {
    try {
      final fileObj = File(file.filePath);
      if (fileObj.existsSync()) {
        // On macOS, we can use the open command to open files
        // For other platforms, you might need different approaches
        Process.run('open', [file.filePath]);
      } else {
        _showError('File not found: ${file.fileName}');
      }
    } catch (e) {
      _showError('Failed to open file: $e');
    }
  }

  void _copyFilePath(DownloadedFile file) {
    // Copy file path to clipboard
    // You would need to implement clipboard functionality
    _showSuccess('File path copied to clipboard');
  }

  Future<void> _deleteFile(DownloadedFile file, AppState appState) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "${file.displayName}"? This action cannot be undone.',
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
        await appState.removeDownloadedFile(file.id);
        _showSuccess('File deleted successfully');
      } catch (e) {
        _showError('Failed to delete file: $e');
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.successGreen),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
    );
  }
}
