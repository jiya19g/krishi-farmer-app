import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class SchemesCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> schemes;
  final double height;
  final Color primaryColor;

  const SchemesCarousel({
    Key? key,
    required this.schemes,
    this.height = 200, // Slightly taller for better visuals
    this.primaryColor = const Color(0xFF367838),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: schemes.length,
      options: CarouselOptions(
        height: height,
        aspectRatio: 2.0,
        viewportFraction: 0.85,
        initialPage: 0,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: true,
      ),
      itemBuilder: (context, index, realIndex) {
        return _buildSchemeCard(context, index);
      },
    );
  }

  Widget _buildSchemeCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showOptions(context, index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.agriculture,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        schemes[index]['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Implemented: ${schemes[index]['date']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'View Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.agriculture,
                    color: primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      schemes[index]['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 10),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.link,
                    color: primaryColor,
                  ),
                ),
                title: const Text('Visit Official Website'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _launchUrl(schemes[index]['link'], context),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: primaryColor,
                  ),
                ),
                title: const Text('View PDF Document'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _launchUrl(schemes[index]['pdf'], context),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: primaryColor),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    Navigator.pop(context);
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
}