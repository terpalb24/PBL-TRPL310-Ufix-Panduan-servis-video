import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ufix_mobile/services/auth_manager.dart';

class CommentsScreen extends StatefulWidget {
  final int? videoId;
  const CommentsScreen({Key? key, this.videoId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final List<Map<String, dynamic>> _comments = [];
  bool _loading = true;
  bool _error = false;
  final TextEditingController _controller = TextEditingController();

  // Track expanded comment ids
  final Set<int> _expandedComments = {};
  // Cached replies per comment id
  final Map<int, List<Map<String, dynamic>>> _replies = {};
  // Controllers for reply inputs per comment id
  final Map<int, TextEditingController> _replyControllers = {};
  // Track if replying to a specific reply: map commentId -> parentReplyId
  final Map<int, int?> _replyingTo = {};
  // Keep the name of the user we're replying to (per comment)
  final Map<int, String?> _replyingToName = {};
  // Track which reply controllers already have listeners attached
  final Set<int> _replyControllerListening = {};

  // Update this to match your backend host (emulator vs device)
  static const String _baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _replyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchComments() async {
    if (widget.videoId == null) {
      setState(() {
        _loading = false;
        _error = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final resp = await http.get(Uri.parse('$_baseUrl/api/comments/video/${widget.videoId}'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        setState(() {
          _comments.clear();
          if (data['comments'] is List) {
            for (var c in data['comments']) {
              _comments.add(Map<String, dynamic>.from(c));
            }
          }
          _loading = false;
        });
      } else {
        setState(() {
          _error = true;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = true;
        _loading = false;
      });
    }
  }

  Future<void> _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.videoId == null) return;

    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/comments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'isi': text,
          'idPengomentar': AuthManager.currentUser?.id,
          'idVideo': widget.videoId,
        }),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        _controller.clear();
        await _fetchComments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim komentar')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim komentar')));
    }
  }

  Future<void> _fetchReplies(int idKomentar) async {
    try {
      final resp = await http.get(Uri.parse('$_baseUrl/api/comments/$idKomentar/replies'));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final list = <Map<String, dynamic>>[];
        if (data['replies'] is List) {
          for (var r in data['replies']) {
            list.add(Map<String, dynamic>.from(r));
          }
        }
        setState(() {
          _replies[idKomentar] = list;
        });
      }
    } catch (e) {
      // ignore reply load errors for now
    }
  }

  Future<void> _postReply(int idKomentar) async {
    final controller = _ensureReplyController(idKomentar);
    final rawText = controller.text;
    if (rawText.trim().isEmpty) return;

    final parentReplyId = _replyingTo[idKomentar];
    final replyToName = _replyingToName[idKomentar];

    // If we're replying to a reply and the input starts with the prefilled '@Name',
    // strip that prefix so we don't send duplicate tags (backend/UI also shows @Name).
    String message = rawText.trim();
    if (parentReplyId != null && replyToName != null) {
      final prefix = '@$replyToName';
      if (message.startsWith(prefix)) {
        message = message.substring(prefix.length).trimLeft();
      }
    }
    if (message.isEmpty) {
      // avoid sending empty message after stripping prefix
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tulis balasan')));
      return;
    }

    try {
      final body = {'isi': message, 'idPengirim': AuthManager.currentUser?.id};
      if (parentReplyId != null) body['parentReplyId'] = parentReplyId;

      final resp = await http.post(
        Uri.parse('$_baseUrl/api/comments/$idKomentar/replies'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (resp.statusCode == 201 || resp.statusCode == 200) {
        controller.clear();
        // clear replying-to state when successfully posted
        setState(() {
          _replyingTo.remove(idKomentar);
          _replyingToName.remove(idKomentar);
        });
        await _fetchReplies(idKomentar);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim reply')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim reply')));
    }
  }

  TextEditingController _ensureReplyController(int id) {
    final controller = _replyControllers.putIfAbsent(id, () => TextEditingController());
    if (!_replyControllerListening.contains(id)) {
      controller.addListener(() {
        final name = _replyingToName[id];
        if (name != null) {
          final prefix = '@$name';
          if (!controller.text.startsWith(prefix)) {
            setState(() {
              _replyingTo.remove(id);
              _replyingToName.remove(id);
            });
          }
        }
      });
      _replyControllerListening.add(id);
    }
    return controller;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  String _formatDate(dynamic d) {
    if (d == null) return '';
    final s = d.toString();
    if (s.length >= 19) return s.substring(0, 19);
    return s;
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
        title: const Text('Comments', style: TextStyle(fontFamily: 'Jost')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Failed to load comments'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _fetchComments, child: const Text('Retry'))
                ]))
              : Column(
                  children: [
                    Expanded(
                      child: _comments.isEmpty
                          ? const Center(child: Text('No comments yet'))
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: _comments.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final c = _comments[index];
                                final id = _toInt(c['idKomentar']);
                                final isExpanded = _expandedComments.contains(id);

                                final currentUser = AuthManager.currentUser;
                                final currentUserIdStr = currentUser?.id?.toString();
                                final cIdPengomentar = c['idPengomentar']?.toString();
                                final cPengomentarId = c['pengomentarId']?.toString();
                                final shownPengomentarName = c['pengomentarName'] ??
                                    ((currentUser != null && (cIdPengomentar == currentUserIdStr || cPengomentarId == currentUserIdStr))
                                        ? currentUser.displayName
                                        : null) ??
                                    (cPengomentarId ?? cIdPengomentar ?? 'Guest');

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                            radius: 24,
                                            backgroundColor: Colors.grey.shade300,
                                            child: const Icon(Icons.person, size: 20, color: Colors.white),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      shownPengomentarName,
                                                      style: const TextStyle(fontWeight: FontWeight.w700),
                                                    ),
                                                    Text(
                                                      _formatDate(c['sentDate']),
                                                      style: const TextStyle(fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(c['isi'] ?? '', style: const TextStyle(fontSize: 16)),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        if (isExpanded) {
                                                          setState(() => _expandedComments.remove(id));
                                                        } else {
                                                          setState(() => _expandedComments.add(id));
                                                          _ensureReplyController(id);
                                                          await _fetchReplies(id);
                                                        }
                                                      },
                                                      child: Text(isExpanded ? 'Hide replies' : 'Reply'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    if (isExpanded)
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
                                          children: [
                                            if ((_replies[id] ?? []).isEmpty)
                                              const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 8),
                                                child: Text('No replies yet'),
                                              )
                                            else
                                              ...(_replies[id] ?? []).map((r) {
                                                final rIdPengirim = r['idPengirim']?.toString();
                                                final rPengirimId = r['pengirimId']?.toString();
                                                final shownPengirimName = r['pengirimName'] ??
                                                    ((currentUser != null && (rIdPengirim == currentUserIdStr || rPengirimId == currentUserIdStr))
                                                        ? currentUser.displayName
                                                        : null) ??
                                                    (rPengirimId ?? rIdPengirim ?? 'Guest');

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
                                                            Text(
                                                              shownPengirimName,
                                                              style: const TextStyle(fontWeight: FontWeight.w600),
                                                            ),
                                                            const SizedBox(height: 6),
                                                                  // If this reply is replying to another reply, show the target as @Name prefix
                                                                  Builder(builder: (_) {
                                                                    final replyToName = r['replyToName'] ?? r['replyToId']?.toString();
                                                                    final content = (replyToName != null) ? '@$replyToName ${r['isi'] ?? ''}' : (r['isi'] ?? '');
                                                                    return Text(content);
                                                                  }),
                                                                  const SizedBox(height: 6),
                                                                  Row(children: [
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        // set replying-to this specific reply and prefill input with @name
                                                                        final rid = _toInt(r['idReply']);
                                                                        final name = shownPengirimName;
                                                                        final controller = _ensureReplyController(id);
                                                                        setState(() {
                                                                          _replyingTo[id] = (rid > 0) ? rid : null;
                                                                          _replyingToName[id] = name;
                                                                        });
                                                                        controller.text = '@$name ';
                                                                        controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
                                                                      },
                                                                      child: const Text('Reply'),
                                                                    ),
                                                                  ]),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),

                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _ensureReplyController(id),
                                                    decoration: const InputDecoration(hintText: 'Tulis balasan...', border: OutlineInputBorder()),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFFFF7F00)),
                                                  onPressed: () => _postReply(id),
                                                  child: const Text('Kirim'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                decoration: const InputDecoration(hintText: 'Tulis komentar...', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0XFFFF7F00)),
                              onPressed: _postComment,
                              child: const Text('Kirim'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
