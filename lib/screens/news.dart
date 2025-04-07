import 'package:flutter/material.dart';
import 'package:farmer_app/services/news_service.dart';

class NewsTab extends StatefulWidget {
  const NewsTab({Key? key}) : super(key: key);

  @override
  State<NewsTab> createState() => _NewsTabState();
}

class _NewsTabState extends State<NewsTab> {
  final NewsService _newsService = NewsService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _newsItems = [];
  bool _isLoading = true;
  String _error = '';
  String _currentQuery = 'agriculture OR farming OR crops';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    try {
      final news = await _newsService.fetchNews(query: _currentQuery);
      setState(() => _newsItems = news);
    } catch (e) {
      setState(() => _error = 'Failed to load news. Pull down to refresh.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() => _currentQuery = query);
      await _loadNews();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadNews,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search agriculture news...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _handleSearch,
                ),
              ),
              onSubmitted: (value) => _handleSearch(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error))
                    : _newsItems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No news articles found',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: _newsItems.map((item) => _buildNewsItem(item)).toList(),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(Map<String, dynamic> newsItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _newsService.launchArticle(newsItem['url']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                newsItem['imageUrl'] ?? '',
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.article, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    newsItem['title'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    newsItem['description'],
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _newsService.formatPublishedAt(newsItem['publishedAt']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        newsItem['sourceName'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}