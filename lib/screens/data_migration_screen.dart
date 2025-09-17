import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:khelset/services/data_migration_service.dart';
import 'package:khelset/services/data_cleanup_service.dart';
import 'package:khelset/theme/app_theme.dart';

class DataMigrationScreen extends StatefulWidget {
  const DataMigrationScreen({super.key});

  @override
  State<DataMigrationScreen> createState() => _DataMigrationScreenState();
}

class _DataMigrationScreenState extends State<DataMigrationScreen> {
  Map<String, dynamic>? _verificationResult;
  Map<String, dynamic>? _consistencyResult;
  bool _isLoading = false;
  String? _lastOperationResult;

  @override
  void initState() {
    super.initState();
    _verifyData();
    _checkConsistency();
  }

  Future<void> _verifyData() async {
    setState(() => _isLoading = true);
    try {
      final result = await DataMigrationService.verifyMigration();
      setState(() {
        _verificationResult = result;
      });
    } catch (e) {
      setState(() {
        _lastOperationResult = 'Verification failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkConsistency() async {
    try {
      final result = await DataCleanupService.verifyTeamFieldConsistency();
      setState(() {
        _consistencyResult = result;
      });
    } catch (e) {
      if (kDebugMode) print('Consistency check failed: $e');
    }
  }

  Future<void> _fixFieldInconsistency() async {
    final confirmed = await _showConfirmationDialog(
      'Fix Field Inconsistency',
      'This will standardize all teams to use the "players" field and remove any "playerIds" fields. This is recommended for React admin app compatibility.',
    );
    
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await DataCleanupService.fixTeamFieldInconsistency();
      setState(() {
        _lastOperationResult = result['success'] 
            ? 'Field inconsistency fixed successfully!\n'
              'Teams fixed: ${result['teamsFixed']}\n'
              'Players recovered: ${result['playersRecovered']}\n'
              'Errors: ${result['errors'].length}'
            : 'Fix failed: ${result['error']}';
      });
      await _verifyData();
      await _checkConsistency();
    } catch (e) {
      setState(() {
        _lastOperationResult = 'Fix failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fixEmptyPlayerIds() async {
    final confirmed = await _showConfirmationDialog(
      'Fix Empty PlayerIds',
      'This will populate empty playerIds arrays with actual player IDs from the players collection. This fixes React app compatibility.',
    );
    
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await DataCleanupService.fixEmptyPlayerIds();
      setState(() {
        _lastOperationResult = result['success'] 
            ? 'Empty playerIds fixed successfully!\n'
              'Teams fixed: ${result['teamsFixed']}\n'
              'Players found: ${result['playersFound']}\n'
              'Errors: ${result['errors'].length}'
            : 'Fix failed: ${result['error']}';
      });
      await _verifyData();
      await _checkConsistency();
    } catch (e) {
      setState(() {
        _lastOperationResult = 'Fix failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _runMigration() async {
    final confirmed = await _showConfirmationDialog(
      'Run Migration',
      'This will migrate teams from embedded players to separate players collection. This action can be rolled back if needed.',
    );
    
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await DataMigrationService.migrateTeamsToSeparatePlayersCollection();
      setState(() {
        _lastOperationResult = result['success'] 
            ? 'Migration completed successfully!\n'
              'Teams processed: ${result['teamsProcessed']}\n'
              'Players created: ${result['playersCreated']}\n'
              'Errors: ${result['errors'].length}'
            : 'Migration failed: ${result['error']}';
      });
      await _verifyData();
    } catch (e) {
      setState(() {
        _lastOperationResult = 'Migration failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rollbackMigration() async {
    final confirmed = await _showConfirmationDialog(
      'Rollback Migration',
      'This will restore the embedded players structure and delete separate player documents. Are you sure?',
    );
    
    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final result = await DataMigrationService.rollbackMigration();
      setState(() {
        _lastOperationResult = result['success'] 
            ? 'Rollback completed successfully!\n'
              'Teams processed: ${result['teamsProcessed']}\n'
              'Players deleted: ${result['playersDeleted']}\n'
              'Errors: ${result['errors'].length}'
            : 'Rollback failed: ${result['error']}';
      });
      await _verifyData();
    } catch (e) {
      setState(() {
        _lastOperationResult = 'Rollback failed: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text(title, style: const TextStyle(color: fontColor)),
        content: Text(content, style: const TextStyle(color: subFontColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Data Migration'),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Field Consistency Check',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor),
                          ),
                          const SizedBox(height: 12),
                          if (_consistencyResult != null) ...[
                            _buildStatusRow('Total Teams', _consistencyResult!['totalTeams'].toString()),
                            _buildStatusRow('Teams with "players" field', _consistencyResult!['teamsWithPlayers'].toString()),
                            _buildStatusRow('Teams with "playerIds" field', _consistencyResult!['teamsWithPlayerIds'].toString()),
                            _buildStatusRow('Teams with both fields', _consistencyResult!['teamsWithBothFields'].toString()),
                            _buildStatusRow('Teams with empty players', _consistencyResult!['teamsWithEmptyPlayers'].toString()),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: _consistencyResult!['isConsistent'] ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _consistencyResult!['isConsistent'] 
                                    ? 'Fields Consistent ✓' 
                                    : 'Field Inconsistency Detected ⚠️',
                                style: TextStyle(
                                  color: _consistencyResult!['isConsistent'] ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Data State',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: primaryColor),
                          ),
                          const SizedBox(height: 12),
                          if (_verificationResult != null) ...[
                            _buildStatusRow('Total Teams', _verificationResult!['totalTeams'].toString()),
                            _buildStatusRow('Total Players', _verificationResult!['totalPlayers'].toString()),
                            _buildStatusRow('Teams with Embedded Players', _verificationResult!['teamsWithEmbeddedPlayers'].toString()),
                            _buildStatusRow('Teams with Player IDs', _verificationResult!['teamsWithPlayerIds'].toString()),
                            _buildStatusRow('Teams with Both Structures', _verificationResult!['teamsWithBothStructures'].toString()),
                            _buildStatusRow('Orphaned Players', _verificationResult!['orphanedPlayers'].toString()),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: _verificationResult!['migrationComplete'] ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _verificationResult!['migrationComplete'] 
                                    ? 'Migration Complete ✓' 
                                    : 'Migration Needed',
                                style: TextStyle(
                                  color: _verificationResult!['migrationComplete'] ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Fix Inconsistency Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _consistencyResult != null && 
                                 !_consistencyResult!['isConsistent']
                          ? _fixFieldInconsistency
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Fix Field Inconsistency'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Fix Empty PlayerIds Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _fixEmptyPlayerIds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Fix Empty PlayerIds (React Compatibility)'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _verifyData();
                            _checkConsistency();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          child: const Text('Refresh Status'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _verificationResult != null && 
                                   _verificationResult!['teamsWithEmbeddedPlayers'] > 0
                              ? _runMigration
                              : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Run Migration'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _verificationResult != null && 
                                   _verificationResult!['teamsWithPlayerIds'] > 0
                              ? _rollbackMigration
                              : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Rollback'),
                        ),
                      ),
                    ],
                  ),
                  if (_lastOperationResult != null) ...[
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Operation Result',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: primaryColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _lastOperationResult!,
                              style: const TextStyle(color: fontColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: fontColor)),
          Text(value, style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
