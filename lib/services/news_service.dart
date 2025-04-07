import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  static final String _apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
  static const String _baseUrl = 'https://gnews.io/api/v4';
  static const String _defaultQuery = 'agriculture OR farming OR crops';

  Future<List<Map<String, dynamic>>> fetchNews({String query = _defaultQuery}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}&lang=en&country=in&max=10&apikey=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        
        return articles.map((article) {
          return {
            'title': article['title'] ?? 'No title',
            'description': article['description'] ?? 'No description',
            'imageUrl': article['image'] ?? 'assets/images/default_news.jpg',
            'url': article['url'],
            'publishedAt': article['publishedAt'],
            'sourceName': article['source']['name'] ?? 'Unknown source',
            'cachedAt': DateTime.now().toIso8601String(),
          };
        }).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  Future<void> launchArticle(String url) async {
  // Ensure URL has https:// prefix
  String formattedUrl = url;
  if (!formattedUrl.startsWith('http')) {
    formattedUrl = 'https://$formattedUrl';
  }

  try {
    if (await canLaunchUrl(Uri.parse(formattedUrl))) {
      await launchUrl(
        Uri.parse(formattedUrl),
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank', // For web platforms
      );
    } else {
      // Fallback to opening in browser if direct launch fails
      await launchUrl(
        Uri.parse('https://$formattedUrl'),
        mode: LaunchMode.externalApplication,
      );
    }
  } catch (e) {
    throw 'Could not launch $formattedUrl. Error: $e';
  }
}

  String formatPublishedAt(String? publishedAt) {
    if (publishedAt == null) return 'Just now';
    
    final dateTime = DateTime.tryParse(publishedAt);
    if (dateTime == null) return 'Just now';
    
    return DateFormat('MMM d, y • h:mm a').format(dateTime);
  }
}