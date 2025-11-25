import 'package:flutter/material.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final List<_Comment> _comments = List.generate(
    6,
    (i) => _Comment(
      name: 'Name',
      date: 'Date/Date/Date',
      text: 'Description of the comment will be put right here. This is some sample text to demonstrate line wrapping.',
      replies: List.generate(
        2,
        (r) => 'This is a reply #${r + 1} to the comment. It will be shown in an expanded white container.',
      ),
    ),
  );

  void _toggleExpand(int index) {
    setState(() {
      _comments[index].expanded = !_comments[index].expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF38587C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Comments on "Title"', style: TextStyle(fontFamily: 'Jost')),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _comments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final c = _comments[index];
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FF),
                  border: Border.all(color: const Color(0xFF38587C)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person, size: 28, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Kodchasan',
                                  ),
                                ),
                              ),
                              Text(
                                c.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            c.text,
                            style: const TextStyle(fontSize: 16, fontFamily: 'Inter'),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                c.expanded ? 'Show less' : 'Show more',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  color: Colors.black54,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _toggleExpand(index),
                                child: Icon(
                                  c.expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: 28,
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
              // Replies area (only visible when expanded)
              if (c.expanded)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: c.replies.map((r) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey.shade300,
                              child: const Icon(Icons.person, size: 18, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Name', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(r, style: const TextStyle()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Comment {
  final String name;
  final String date;
  final String text;
  final List<String> replies;
  bool expanded;

  _Comment({
    required this.name,
    required this.date,
    required this.text,
    required this.replies,
    this.expanded = false,
  });
}
