// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/models.dart';

class JurnalDashboardScreen extends StatefulWidget {
  const JurnalDashboardScreen({super.key});

  @override
  State<JurnalDashboardScreen> createState() => _JurnalDashboardScreenState();
}

class _JurnalDashboardScreenState extends State<JurnalDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadJournals();
    });
  }

  static const List<Map<String, dynamic>> _categories = [
    {
      'id': 'daily',
      'title': 'Refleksi Harian',
      'emoji': '📝',
      'color': AppColors.primary,
    },
    {
      'id': 'syukur',
      'title': 'Catatan Syukur',
      'emoji': '💚',
      'color': AppColors.accent,
    },
    {
      'id': 'ikhlaskan',
      'title': 'Ruang Ikhlas',
      'emoji': '🕊️',
      'color': AppColors.error,
    },
    {
      'id': 'bebas',
      'title': 'Catatan Bebas',
      'emoji': '✏️',
      'color': AppColors.warning,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<JournalProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.jurnalBgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.pencil_ellipsis_rectangle,
              size: 18,
              color: AppColors.toolCyan,
            ),
            SizedBox(width: 8),
            Text(AppStrings.jurnalRefleksi),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.jurnalKosong,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.entries.length} entri tersimpan',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Categories
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final cat = _categories[index];
                  return GestureDetector(
                    onTap: () => _writeJournal(context, cat['id'] as String),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.textLight
                              : CupertinoColors.systemGrey6,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (cat['color'] as Color).withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                cat['emoji'] as String,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['title'] as String,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? CupertinoColors.white
                                        : AppColors.textLight,
                                  ),
                                ),
                                Text(
                                  AppStrings.jurnalBuatBaru,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? CupertinoColors.systemGrey
                                        : CupertinoColors.systemGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 14,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _categories.length),
              ),
            ),
            // Recent entries
            if (provider.entries.isNotEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'ENTRI TERBARU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = provider.entries[index];
                      final cat = _categories.firstWhere(
                        (c) => c['id'] == entry.category,
                        orElse: () => _categories[0],
                      );
                      return GestureDetector(
                        onTap: () => _showEntry(context, entry, isDark),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.textLight
                                  : CupertinoColors.systemGrey6,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                cat['emoji'] as String,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.title.isNotEmpty
                                          ? entry.title
                                          : AppStrings.jurnalTanpaJudul,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? CupertinoColors.white
                                            : AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: provider.entries.length > 5
                        ? 5
                        : provider.entries.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _writeJournal(BuildContext context, String category, {JournalEntry? existingEntry}) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _JournalWriteSheet(
        category: category,
        existingEntry: existingEntry,
      ),
    );
  }

  void _showEntry(BuildContext context, JournalEntry entry, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            height: 460,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : CupertinoColors.systemBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.title.isNotEmpty ? entry.title : AppStrings.jurnalTanpaJudul,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? CupertinoColors.white
                                : AppColors.textLight,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              Future.delayed(
                                const Duration(milliseconds: 100),
                                () => _writeJournal(
                                  context,
                                  entry.category,
                                  existingEntry: entry,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.pencil,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              showCupertinoDialog(
                                context: context,
                                builder: (dialogCtx) => CupertinoAlertDialog(
                                  title: Text(AppStrings.jurnalHapusCatatan),
                                  content: Text(
                                    AppStrings.jurnalYakinHapus,
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      isDefaultAction: true,
                                      child: Text(AppStrings.cancel),
                                      onPressed: () => Navigator.pop(dialogCtx),
                                    ),
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      child: Text(AppStrings.delete),
                                      onPressed: () {
                                        final journal = context.read<JournalProvider>();
                                        Navigator.pop(dialogCtx);
                                        Navigator.pop(ctx);
                                        journal.deleteJournal(entry.id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                CupertinoIcons.trash,
                                size: 16,
                                color: CupertinoColors.systemRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        entry.content,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark
                              ? CupertinoColors.white
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${entry.createdAt.hour.toString().padLeft(2, '0')}:${entry.createdAt.minute.toString().padLeft(2, '0')} • ${entry.createdAt.day}/${entry.createdAt.month}/${entry.createdAt.year}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _JournalWriteSheet extends StatefulWidget {
  final String category;
  final JournalEntry? existingEntry;

  const _JournalWriteSheet({
    required this.category,
    this.existingEntry,
  });

  @override
  State<_JournalWriteSheet> createState() => _JournalWriteSheetState();
}

class _JournalWriteSheetState extends State<_JournalWriteSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final String _selectedMood = 'calm';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingEntry?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.existingEntry?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final isEditing = widget.existingEntry != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: 500,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Catatan' : 'Tulis Jurnal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      isEditing ? 'Perbarui' : 'Simpan',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onPressed: () {
                      if (_contentController.text.trim().isNotEmpty) {
                        final entry = JournalEntry(
                          id: isEditing
                              ? widget.existingEntry!.id
                              : DateTime.now().millisecondsSinceEpoch.toString(),
                          title: _titleController.text.isNotEmpty
                              ? _titleController.text
                              : 'Catatan ${widget.category}',
                          content: _contentController.text,
                          category: widget.category,
                          mood: widget.existingEntry?.mood ?? _selectedMood,
                          createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
                        );
                        context.read<JournalProvider>().saveJournal(entry);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoTextField(
                controller: _titleController,
                placeholder: 'Judul (opsional)',
                padding: const EdgeInsets.all(12),
                style: TextStyle(
                  color: isDark ? CupertinoColors.white : AppColors.textLight,
                  fontSize: 14,
                ),
                placeholderStyle: TextStyle(
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey2,
                  fontSize: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textLight
                      : CupertinoColors.tertiarySystemBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CupertinoTextField(
                  controller: _contentController,
                  placeholder: 'Tulis sesuatu...',
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  padding: const EdgeInsets.all(12),
                  style: TextStyle(
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                    fontSize: 14,
                  ),
                  placeholderStyle: TextStyle(
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2,
                    fontSize: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.tertiarySystemBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
