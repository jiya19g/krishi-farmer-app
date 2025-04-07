import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:farmer_app/services/firestore_service.dart';

class DiscussionsTab extends StatefulWidget {
  const DiscussionsTab({Key? key}) : super(key: key);

  @override
  State<DiscussionsTab> createState() => _DiscussionsTabState();
}

class _DiscussionsTabState extends State<DiscussionsTab> {
  final List<String> _categories = ['All', 'Crops', 'Weather', 'Market', 'Loans'];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _newDiscussionController = TextEditingController();
  String? _expandedDiscussionId;
  bool _isCreatingDiscussion = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterDiscussions);
  }

  void _filterDiscussions() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        if (currentUser != null && !_isCreatingDiscussion)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => setState(() => _isCreatingDiscussion = true),
              child: const Text('Start New Discussion'),
            ),
          ),
        if (_isCreatingDiscussion) _buildDiscussionCreationForm(firestoreService, currentUser!),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getDiscussions(
              category: _selectedCategory == 'All' ? null : _selectedCategory,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final discussions = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: discussions.length,
                itemBuilder: (context, index) {
                  return _buildDiscussionCard(
                    discussions[index],
                    firestoreService,
                    currentUser,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscussionCreationForm(FirestoreService firestoreService, User currentUser) {
    final dropdownCategories = _categories.where((cat) => cat != 'All').toList();
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory == 'All' ? dropdownCategories.first : _selectedCategory,
              items: dropdownCategories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newDiscussionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What would you like to discuss?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => setState(() => _isCreatingDiscussion = false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_newDiscussionController.text.isNotEmpty) {
                      try {
                        await firestoreService.createDiscussion(
                          content: _newDiscussionController.text,
                          category: _selectedCategory,
                          authorId: currentUser.uid,
                        );
                        _newDiscussionController.clear();
                        setState(() => _isCreatingDiscussion = false);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscussionCard(
    DocumentSnapshot discussionDoc,
    FirestoreService firestoreService,
    User? currentUser,
  ) {
    final discussion = discussionDoc.data() as Map<String, dynamic>;
    final isExpanded = _expandedDiscussionId == discussionDoc.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: firestoreService.getUserStream(discussion['authorId']),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.person)),
                    title: Text('Loading...'),
                  );
                }
                final user = userSnapshot.data!.data() as Map<String, dynamic>;
                return _buildUserHeader(user, discussion);
              },
            ),
            const SizedBox(height: 8),
            _buildDiscussionContent(discussion, isExpanded, discussionDoc.id),
            _buildDiscussionFooter(discussion, discussionDoc.id, firestoreService, currentUser),
            if (isExpanded) ...[
              const SizedBox(height: 12),
              _buildCommentsSection(discussionDoc.id, firestoreService),
              if (currentUser != null) _buildAddCommentField(discussionDoc.id, firestoreService, currentUser),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(Map<String, dynamic> user, Map<String, dynamic> discussion) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.green[200],
          child: Text(user['name']?[0] ?? '?'),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${_formatTimestamp(discussion['timestamp'])} • ${discussion['category']} • ${user['city'] ?? ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    
    final now = DateTime.now();
    final time = timestamp.toDate();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  Widget _buildDiscussionContent(Map<String, dynamic> discussion, bool isExpanded, String discussionId) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedDiscussionId = isExpanded ? null : discussionId;
        });
      },
      child: Text(
        discussion['content'],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildDiscussionFooter(
  Map<String, dynamic> discussion,
  String discussionId,
  FirestoreService firestoreService,
  User? currentUser,
) {
  return Row(
    children: [
      // Comment icon and count
      IconButton(
        icon: const Icon(Icons.comment),
        onPressed: () {
          setState(() {
            _expandedDiscussionId = _expandedDiscussionId == discussionId ? null : discussionId;
          });
        },
      ),
      Text('${discussion['commentCount'] ?? 0}'),
    ],
  );
}
  Widget _buildCommentsSection(String discussionId, FirestoreService firestoreService) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getComments(discussionId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading comments: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final comments = snapshot.data!.docs;

        if (comments.isEmpty) {
          return const Text('No comments yet', style: TextStyle(color: Colors.grey));
        }

        return Column(
          children: [
            const Divider(),
            ...comments.map((commentDoc) {
              final comment = commentDoc.data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: firestoreService.getUserData(comment['authorId']),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }
                  final user = userSnapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Text(user['name'][0]),
                    ),
                    title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(comment['content']),
                    trailing: Text(
                      _formatTimestamp(comment['timestamp']),
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildAddCommentField(
    String discussionId,
    FirestoreService firestoreService,
    User currentUser,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: _commentController,
        decoration: InputDecoration(
          hintText: 'Add a comment...',
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (_commentController.text.isNotEmpty) {
                try {
                  await firestoreService.addComment(
                    discussionId: discussionId,
                    content: _commentController.text,
                    authorId: currentUser.uid,
                  );
                  _commentController.clear();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search discussions...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'All';
                });
              },
            ),
          );
        },
      ),
    );
  }
}