import 'package:flutter/material.dart';
import 'package:flutter_app/services/services.dart';
import 'package:flutter_app/models/models.dart';

class AllWaterEntriesScreen extends StatefulWidget {
  const AllWaterEntriesScreen({super.key});

  @override
  State<AllWaterEntriesScreen> createState() => _AllWaterEntriesScreenState();
}

class _AllWaterEntriesScreenState extends State<AllWaterEntriesScreen> {
  final NutritionService _nutritionService = NutritionService();
  List<PostWaterIntakeResponseModel> _allWaterEntries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllWaterEntries();
  }

  Future<void> _loadAllWaterEntries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final waterResult = await _nutritionService.getWaterEntries();
      setState(() {
        _allWaterEntries = waterResult.waterEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteWaterEntry(PostWaterIntakeResponseModel waterEntry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Water Entry'),
        content: Text('Are you sure you want to delete this ${waterEntry.volumeMl}ml water entry?'),
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
        await _nutritionService.deleteWaterEntry(waterEntry.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Water entry (${waterEntry.volumeMl}ml) deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadAllWaterEntries(); // Refresh the list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete water entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editWaterEntry(PostWaterIntakeResponseModel waterEntry) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => EditWaterEntryScreen(waterEntry: waterEntry)),
    );

    if (result == true) {
      _loadAllWaterEntries(); // Refresh the list if water entry was updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Water Entries'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAllWaterEntries),
        ],
      ),
      body: RefreshIndicator(onRefresh: _loadAllWaterEntries, child: _buildBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add-water',
          ).then((_) => _loadAllWaterEntries());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load water entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllWaterEntries,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_allWaterEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No water entries logged yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add-water',
                ).then((_) => _loadAllWaterEntries());
              },
              child: const Text('Add Your First Water Entry'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allWaterEntries.length,
      itemBuilder: (context, index) {
        final waterEntry = _allWaterEntries[index];
        return _buildWaterEntryCard(waterEntry);
      },
    );
  }

  Widget _buildWaterEntryCard(PostWaterIntakeResponseModel waterEntry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: const Icon(Icons.water_drop, color: Colors.blue),
        ),
        title: Text(
          '${waterEntry.volumeMl.toStringAsFixed(0)} ml',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${(waterEntry.volumeMl / 1000).toStringAsFixed(2)} liters',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDateTime(waterEntry.timestamp),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editWaterEntry(waterEntry);
            } else if (value == 'delete') {
              _deleteWaterEntry(waterEntry);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(entryDate).inDays;

    String dateStr;
    if (difference == 0) {
      dateStr = 'Today';
    } else if (difference == 1) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }
}

class EditWaterEntryScreen extends StatefulWidget {
  final PostWaterIntakeResponseModel waterEntry;

  const EditWaterEntryScreen({super.key, required this.waterEntry});

  @override
  State<EditWaterEntryScreen> createState() => _EditWaterEntryScreenState();
}

class _EditWaterEntryScreenState extends State<EditWaterEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final NutritionService _nutritionService = NutritionService();

  late TextEditingController _volumeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(
      text: widget.waterEntry.volumeMl.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  Future<void> _updateWaterEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedWaterEntry = PostWaterIntakeRequestModel(
        amount: int.parse(_volumeController.text),
      );

      await _nutritionService.updateWaterEntry(widget.waterEntry.id, updatedWaterEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Water entry updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update water entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Water Entry'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateWaterEntry,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Edit Water Intake',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _volumeController,
              decoration: const InputDecoration(
                labelText: 'Volume',
                border: OutlineInputBorder(),
                suffixText: 'ml',
                helperText: 'Enter the amount of water in milliliters',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter volume';
                }
                final volume = int.tryParse(value);
                if (volume == null || volume <= 0) {
                  return 'Please enter a valid volume greater than 0';
                }
                if (volume > 10000) {
                  return 'Volume seems too large. Please check the value.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick amounts:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [250, 500, 750, 1000].map((amount) {
                      return ActionChip(
                        label: Text('${amount}ml'),
                        onPressed: () {
                          _volumeController.text = amount.toString();
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateWaterEntry,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Update Water Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
