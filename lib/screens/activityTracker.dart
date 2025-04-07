import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:farmer_app/services/activity_service.dart';

class ActivityTrackerScreen extends StatefulWidget {
  const ActivityTrackerScreen({Key? key}) : super(key: key);

  @override
  State<ActivityTrackerScreen> createState() => _ActivityTrackerScreenState();
}

class _ActivityTrackerScreenState extends State<ActivityTrackerScreen> {
  final ActivityService _activityService = ActivityService();
  final _formKey = GlobalKey<FormState>();
  bool _showForm = false;
  bool _isSaving = false;
  int? _editingIndex;

  // Controllers
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _selectedDate;
  bool _wantsReminder = true;
  String _selectedTag = 'Harvest';

  final List<String> _tags = [
    'Harvest',
    'Planting',
    'Fertilizing',
    'Irrigation',
    'Market',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateController.text = DateFormat('MMM d, yyyy - hh:mm a').format(_selectedDate!);
        });
      }
    }
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final activityId = await _activityService.addActivity(
        title: _titleController.text,
        date: _selectedDate!,
        tag: _selectedTag,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        wantsReminder: _wantsReminder,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_wantsReminder 
            ? 'Activity saved! SMS scheduled' 
            : 'Activity saved'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved activity but SMS failed: ${e.toString()}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      
      _resetForm();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _dateController.clear();
    _phoneController.clear();
    if (mounted) {
      setState(() {
        _selectedDate = null;
        _selectedTag = 'Harvest';
        _wantsReminder = true;
        _showForm = false;
        _editingIndex = null;
      });
    }
  }

  Future<void> _deleteActivity(String id) async {
    try {
      await _activityService.deleteActivity(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity deleted'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Tracker'),
        actions: [
          IconButton(
            icon: Icon(_showForm ? Icons.close : Icons.add),
            onPressed: () => setState(() => _showForm = !_showForm),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showForm) _buildActivityForm(),
            if (!_showForm) _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  final status = data['status'] ?? 'unknown';
  final smsStatus = data['smsStatus'] ?? 'none';
  final date = (data['date'] as Timestamp).toDate();
  final isPastDue = date.isBefore(DateTime.now());

  // Determine status to display
  String displayStatus;
  Color statusColor;
  IconData statusIcon;

  if (status == 'scheduled') {
    if (isPastDue) {
      displayStatus = 'Sent';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else {
      displayStatus = 'Scheduled';
      statusColor = Colors.blue;
      statusIcon = Icons.schedule;
    }
  } else if (status == 'sent') {
    displayStatus = 'Sent';
    statusColor = Colors.green;
    statusIcon = Icons.check_circle;
  } else if (status == 'active') {
    displayStatus = 'Active';
    statusColor = Colors.green;
    statusIcon = Icons.check_circle;
  } else if (status == 'failed') {
    displayStatus = 'Failed';
    statusColor = Colors.red;
    statusIcon = Icons.error_outline;
  } else {
    displayStatus = 'Unknown';
    statusColor = Colors.grey;
    statusIcon = Icons.help_outline;
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: ListTile(
      leading: Icon(statusIcon, color: statusColor),
      title: Text(data['title'] ?? 'No Title'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('MMM d, yyyy - hh:mm a').format(date)),
          const SizedBox(height: 4),
          Chip(
            label: Text(displayStatus),
            backgroundColor: statusColor,
            labelStyle: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => _deleteActivity(doc.id),
      ),
    ),
  );
}
  Widget _buildActivityForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTag,
                decoration: InputDecoration(
                  labelText: 'Activity Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                items: _tags.map((tag) => DropdownMenuItem(
                  value: tag,
                  child: Text(tag),
                )).toList(),
                onChanged: (value) => setState(() => _selectedTag = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date & Time',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () => _selectDate(context),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone (optional)',
                  hintText: 'Uses profile phone if empty',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Send SMS Reminder'),
                value: _wantsReminder,
                onChanged: _isSaving ? null : (value) => setState(() => _wantsReminder = value),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveActivity,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save Activity'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _activityService.getActivities(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Error loading activities',
                  style: TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = snapshot.data?.docs ?? [];
        
        if (activities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 48,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No activities yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add one',
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...activities.map((doc) => _buildActivityCard(doc)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}