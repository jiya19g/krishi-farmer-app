import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportTab extends StatefulWidget {
  const SupportTab({Key? key}) : super(key: key);

  @override
  State<SupportTab> createState() => _SupportTabState();
}

class _SupportTabState extends State<SupportTab> {
  final List<SupportItem> _allSupportItems = [
    SupportItem(
      icon: Icons.emergency,
      title: 'Agriculture Crisis Line',
      subtitle: '24/7 government support for farming emergencies',
      color: Colors.red,
      contact: 'tel:18001234567',
      tags: ['Drought', 'Crop Failure', 'Animal Disease'],
      details: {
        'Availability': '24/7',
        'Languages': 'Hindi, English, Regional',
        'Response Time': 'Immediate',
      },
    ),
    SupportItem(
      icon: Icons.local_police,
      title: 'Rural Police Assistance',
      subtitle: 'Special police unit for farming communities',
      color: Colors.blue,
      contact: 'tel:1800110001',
      tags: ['Theft', 'Land Dispute', 'Security'],
      details: {
        'Availability': '24/7',
        'Response Time': 'Within 30 minutes',
        'Coverage': 'All rural districts',
      },
    ),
    SupportItem(
      icon: Icons.health_and_safety,
      title: 'Farmer Mental Health',
      subtitle: 'Confidential counseling in regional languages',
      color: Colors.green,
      contact: 'tel:18007891234',
      tags: ['Stress', 'Depression', 'Family Support'],
      details: {
        'Languages': '10+ regional languages',
        'Confidentiality': '100% private',
        'Counselors': 'Trained specialists',
      },
    ),
    SupportItem(
      icon: Icons.medical_services,
      title: 'Mobile Medical Unit',
      subtitle: 'Free health checkups in rural areas',
      color: Colors.teal,
      contact: 'tel:18005551234',
      tags: ['Checkup Schedule', 'Vaccinations', 'First Aid'],
      details: {
        'Services': 'Basic checkups, Vaccinations',
        'Schedule': 'Weekly village visits',
        'Cost': 'Completely free',
      },
    ),
    SupportItem(
      icon: Icons.gavel,
      title: 'Legal Aid Center',
      subtitle: 'Free legal assistance for farmers',
      color: Colors.purple,
      contact: 'tel:18004567890',
      tags: ['Land Rights', 'Loan Issues', 'Contract Disputes'],
      details: {
        'Services': 'Legal advice, Document review',
        'Languages': 'Local languages available',
        'Cost': 'Free for farmers',
      },
    ),
    SupportItem(
      icon: Icons.account_balance,
      title: 'Loan & Subsidy Helpdesk',
      subtitle: 'Government scheme assistance',
      color: Colors.orange,
      contact: 'tel:18003334444',
      tags: ['MSP', 'Subsidies', 'Loan Waivers'],
      details: {
        'Schemes': 'All central & state schemes',
        'Assistance': 'Application help',
        'Languages': 'Bilingual support',
      },
    ),
  ];

  List<SupportItem> _filteredSupportItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredSupportItems = _allSupportItems;
    _searchController.addListener(_filterSupportItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSupportItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSupportItems = _allSupportItems.where((item) {
        return item.title.toLowerCase().contains(query) ||
            item.subtitle.toLowerCase().contains(query) ||
            item.tags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    });
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse(phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search support services...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        Expanded(
          child: _filteredSupportItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No support services found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _filteredSupportItems.map((item) => _buildSupportCard(item)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildSupportCard(SupportItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showSupportDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: item.color.withOpacity(0.1),
                          labelStyle: TextStyle(color: item.color),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.call, color: item.color),
                    label: Text(
                      'Call Now',
                      style: TextStyle(color: item.color),
                    ),
                    onPressed: () => _launchPhoneCall(item.contact),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    icon: Icon(Icons.info, color: item.color),
                    label: Text(
                      'Details',
                      style: TextStyle(color: item.color),
                    ),
                    onPressed: () => _showSupportDetails(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSupportDetails(SupportItem item) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title and subtitle
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              
              // Service details
              const Text(
                'Service Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...item.details.entries.map((entry) => _buildDetailRow(entry.key, entry.value)),
              
              const SizedBox(height: 20),
              
              // Tags section
              const Text(
                'Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          backgroundColor: item.color.withOpacity(0.1),
                          labelStyle: TextStyle(color: item.color),
                        ))
                    .toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Call button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: item.color,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _launchPhoneCall(item.contact);
                  },
                  child: const Text(
                    'CALL SUPPORT NOW',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              // Close button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Helper widget for detail rows
Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    ),
  );
}
}

class SupportItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String contact;
  final List<String> tags;
  final Map<String, String> details;

  const SupportItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.contact,
    required this.tags,
    required this.details,
  });
}