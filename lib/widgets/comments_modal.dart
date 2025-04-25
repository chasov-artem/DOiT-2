import 'package:flutter/material.dart';
import 'package:gluestack_ui/gluestack_ui.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class CommentsModal extends StatefulWidget {
  final int postId;

  const CommentsModal({
    super.key,
    required this.postId,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = ApiService().getComments(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GSHeading(
              text: 'Коментарі до поста #${widget.postId}',
              size: GSHeadingSizes.$lg,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: GSSpinner(),
                  );
                }
                if (snapshot.hasError) {
                  return GSText(
                    text: 'Помилка завантаження коментарів',
                    style: GSStyle(
                      textStyle: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final comments = snapshot.data!;
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GSText(
                              text: comment.name,
                              style: GSStyle(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Divider(),
                            GSText(text: comment.body),
                            const SizedBox(height: 8),
                            GSText(
                              text: comment.email,
                              style: GSStyle(
                                textStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Закрити'),
            ),
          ],
        ),
      ),
    );
  }
}
