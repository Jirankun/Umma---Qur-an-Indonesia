import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../services/ai_content_service.dart';

class QuoteCard extends StatefulWidget {
  final bool isDark;

  const QuoteCard({super.key, required this.isDark});

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  Map<String, String> _currentQuote = const {'text': '', 'author': ''};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  Future<void> _loadQuote() async {
    try {
      final quote = await AiContentService().getDailyQuote();
      if (mounted) {
        setState(() {
          _currentQuote = quote;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _currentQuote['text'] ?? '';
    final author = _currentQuote['author'] ?? '';

    if (text.isEmpty && !_isLoading) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [AppColors.surfaceDark, AppColors.quoteDark]
                : [AppColors.primaryLight, AppColors.primarySurfaceLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.captions_bubble_fill,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(width: 8),
                      const CupertinoActivityIndicator(radius: 6),
                    ],
                  ],
                ),
                Text(
                  'Hari ${DateTime.now().day}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const CupertinoActivityIndicator()
            else ...[
              Text(
                '"$text"',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: widget.isDark
                      ? CupertinoColors.white
                      : AppColors.textLight,
                ),
              ),
              if (author.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 2,
                      height: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '— $author',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? CupertinoColors.systemGrey
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
