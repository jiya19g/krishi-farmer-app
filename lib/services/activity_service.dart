import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _textBeeApiKey = dotenv.env['TEXTBEE_API_KEY'] ?? '';
final String _textBeeDeviceId = dotenv.env['TEXTBEE_DEVICE_ID'] ?? '';

  Future<String> addActivity({
    required String title,
    required DateTime date,
    required String tag,
    String? phone,
    required bool wantsReminder,
  }) async {
    DocumentReference? docRef;
    
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userPhone = phone ?? await _getUserPhone(user.uid);

      docRef = await _firestore.collection('activities').add({
        'userId': user.uid,
        'title': title,
        'date': date,
        'tag': tag,
        'phone': userPhone,
        'wantsReminder': wantsReminder,
        'status': wantsReminder ? 'scheduled' : 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (wantsReminder) {
        // Schedule status update when reminder time passes
        _scheduleStatusUpdate(docRef.id, date);
        
        try {
          await _scheduleTextBeeReminder(
            docRef.id,
            userPhone,
            title,
            date,
          );
        } catch (smsError) {
          // SMS scheduling failed but activity is saved
          await docRef.update({
            'smsStatus': 'failed',
            'error': smsError.toString(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      return docRef.id;
    } catch (e) {
      if (docRef != null) {
        await docRef.update({
          'status': 'failed',
          'error': e.toString(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      rethrow;
    }
  }

Future<void> _scheduleStatusUpdate(String activityId, DateTime reminderTime) async {
    final now = DateTime.now();
    final delay = reminderTime.difference(now);

    if (delay.isNegative) {
      // If reminder time already passed
      await _firestore.collection('activities').doc(activityId).update({
        'status': 'sent',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Schedule status update for when reminder time passes
      Future.delayed(delay, () async {
        final doc = await _firestore.collection('activities').doc(activityId).get();
        if (doc.exists && doc['status'] == 'scheduled') {
          await doc.reference.update({
            'status': 'sent',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    }
  }
  Future<void> _scheduleTextBeeReminder(
    String activityId,
    String phone,
    String title,
    DateTime date,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.textbee.dev/api/v1/gateway/devices/$_textBeeDeviceId/send-sms'),
        headers: {
          'x-api-key': _textBeeApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recipients': [phone],
          'message': '🔔 Reminder: $title\n⏰ ${DateFormat('MMM d, hh:mm a').format(date)}',
          'schedule': date.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 10));

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final smsBatchId = responseData['data']['smsBatchId'] ?? responseData['id'];
        await _firestore.collection('activities').doc(activityId).update({
          'textBeeId': smsBatchId,
          'status': 'scheduled',
          'smsStatus': 'queued',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Start monitoring SMS delivery status
        _monitorSmsDelivery(activityId, smsBatchId);
      } else {
        throw Exception('TextBee API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      await _firestore.collection('activities').doc(activityId).update({
        'status': 'active',
        'smsStatus': 'failed',
        'error': e.toString(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      throw Exception('SMS scheduling failed: $e');
    }
  }

  Future<void> _monitorSmsDelivery(String activityId, String smsBatchId) async {
    try {
      // Initial delay before first check
      await Future.delayed(const Duration(minutes: 1));
      
      final response = await http.get(
        Uri.parse('https://api.textbee.dev/api/v1/gateway/devices/$_textBeeDeviceId/messages/$smsBatchId'),
        headers: {'x-api-key': _textBeeApiKey},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final statusData = jsonDecode(response.body);
        final deliveryStatus = statusData['data']['status'] ?? statusData['status'];
        
        if (deliveryStatus == 'delivered') {
          await _firestore.collection('activities').doc(activityId).update({
            'status': 'sent',
            'smsStatus': 'delivered',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // If not delivered yet, check again later
          await Future.delayed(const Duration(minutes: 5));
          await _monitorSmsDelivery(activityId, smsBatchId);
        }
      }
    } catch (e) {
      print('SMS delivery monitoring error: $e');
      // Silently fail - we'll check status again when user views the activity
    }
  }

  Future<String> _getUserPhone(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) throw Exception('User document not found');
      return doc.get('phone') ?? '';
    } catch (e) {
      throw Exception('Failed to get user phone: $e');
    }
  }

  Stream<QuerySnapshot> getActivities() {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');
      
      return _firestore
          .collection('activities')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .snapshots()
          .handleError((error) {
            if (error.toString().contains('index')) {
              throw Exception(
                'Please wait while we set up the database. '
                'Restart the app if this persists.'
              );
            }
            throw Exception('Failed to load activities: ${error.toString()}');
          });
    } catch (e) {
      throw Exception('Failed to initialize activity stream: $e');
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _firestore.collection('activities').doc(activityId).delete();
    } catch (e) {
      throw Exception('Failed to delete activity: $e');
    }
  }

  Future<void> checkReminderStatus(String activityId) async {
    try {
      final doc = await _firestore.collection('activities').doc(activityId).get();
      if (!doc.exists) return;
      
      final textBeeId = doc.get('textBeeId');
      if (textBeeId != null) {
        await _monitorSmsDelivery(activityId, textBeeId);
      }
    } catch (e) {
      print('Error checking reminder status: $e');
    }
  }

  Future<void> retryFailedReminders() async {
    try {
      final failedActivities = await _firestore
          .collection('activities')
          .where('status', whereIn: ['failed', 'sms_failed'])
          .where('wantsReminder', isEqualTo: true)
          .get();

      for (final doc in failedActivities.docs) {
        final data = doc.data() as Map<String, dynamic>;
        try {
          await _scheduleTextBeeReminder(
            doc.id,
            data['phone'],
            data['title'],
            (data['date'] as Timestamp).toDate(),
          );
        } catch (e) {
          print('Failed to retry reminder ${doc.id}: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to retry reminders: $e');
    }
  }
}