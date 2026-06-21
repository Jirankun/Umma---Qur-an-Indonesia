import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/muslim_ai_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/hadits_provider.dart';
import '../../providers/quran_provider.dart';
import '../../models/hadits.dart';
import '../../data/doa_data.dart';
import '../../data/fiqih_data.dart';
import '../quran/surah_reader_screen.dart';
import '../doa/doa_home_screen.dart';
import '../hadits/hadits_home_screen.dart';
import '../fiqih/fiqih_home_screen.dart';
import '../zakat/zakat_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../tracker/tracker_screen.dart';
import '../jurnal/jurnal_dashboard_screen.dart';

class MuslimAiScreen extends StatefulWidget {
  const MuslimAiScreen({super.key});

  @override
  State<MuslimAiScreen> createState() => _MuslimAiScreenState();
}

class _MuslimAiScreenState extends State<MuslimAiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  static const List<Map<String, dynamic>> _modes = [
    {'id': 'ngobrol', 'label': 'Ngobrol', 'emoji': '💬'},
    {'id': 'doa', 'label': 'Cari Doa', 'emoji': '🤲'},
    {'id': 'surah', 'label': 'Cari Surah', 'emoji': '📖'},
    {'id': 'fiqih', 'label': 'Tanya Fiqih', 'emoji': '⚖️'},
    {'id': 'hadits', 'label': 'Cari Hadits', 'emoji': '📜'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MuslimAiProvider>().loadCooldown();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════
  //  AI MESSAGE RENDERER — parse markers
  // ═══════════════════════════════════════════════════════
  static final RegExp _bukaRegex = RegExp(r'\[Buka:(\w+)(?::([^\]]+))?\]');
  static final RegExp _cariRegex = RegExp(r'\[Cari:([^\]]+)\]');

  /// Regex untuk bold: **teks**
  static final RegExp _boldRegex = RegExp(r'\*\*(.+?)\*\*');

  /// Render teks dengan bold support (**...**) via RichText
  Widget _buildRichText(String text, bool isDark,
      {double fontSize = 14, double height = 1.4}) {
    final boldMatches = _boldRegex.allMatches(text).toList();

    if (boldMatches.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          height: height,
          color: isDark ? CupertinoColors.white : AppColors.textLight,
        ),
      );
    }

    final baseStyle = TextStyle(
      fontSize: fontSize,
      height: height,
      color: isDark ? CupertinoColors.white : AppColors.textLight,
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w800,
      color: isDark ? CupertinoColors.white : AppColors.textLight,
    );

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in boldMatches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: boldStyle,
      ));
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  /// Render AI message: teks biasa (dengan bold **...**) + tombol Buka + tombol Cari
  Widget _buildAiMessage(String text, bool isDark) {
    // Gabung semua marker: Buka dan Cari
    final bukaMatches = _bukaRegex.allMatches(text).toList();
    final cariMatches = _cariRegex.allMatches(text).toList();
    final allMatches = [...bukaMatches, ...cariMatches];
    // Sort by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    if (allMatches.isEmpty) {
      return _buildRichText(text, isDark);
    }

    final children = <Widget>[];
    int lastEnd = 0;

    for (final match in allMatches) {
      // Add text before this marker
      if (match.start > lastEnd) {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRichText(
              text.substring(lastEnd, match.start),
              isDark,
            ),
          ),
        );
      }

      if (match.group(0)!.startsWith('[Buka:')) {
        // ─── Buka button (navigasi internal) ───
        final screen = match.group(1) ?? '';
        final param = match.group(2);
        final label = _buttonLabel(screen);
        String buttonLabel = 'Buka $label';
        if (screen == 'hadits' && param != null) {
          final parts = param.split(':');
          if (parts.length > 1) {
            buttonLabel = 'Buka Hadits #${parts[1]}';
          }
        }
        children.add(
          _buildActionButton(
            label: buttonLabel,
            icon: CupertinoIcons.arrow_up_right_square,
            color: AppColors.toolIndigo,
            onTap: () => _navigateToScreen(screen, param),
          ),
        );
      } else {
        // ─── Cari button (Google Search via external browser) ───
        final query = match.group(1) ?? '';
        children.add(
          _buildActionButton(
            label: 'Cari di Google',
            icon: CupertinoIcons.search,
            color: AppColors.fiqihSholat,
            onTap: () => _openGoogleSearch(query),
          ),
        );
      }

      lastEnd = match.end;
    }

    // Add remaining text after last marker
    if (lastEnd < text.length) {
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildRichText(
            text.substring(lastEnd),
            isDark,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Build a styled action button (Buka / Cari)
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open Google Search in external browser
  Future<void> _openGoogleSearch(String query) async {
    final encoded = Uri.encodeComponent(query);
    final url = 'https://www.google.com/search?q=$encoded';
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _showToast('Tidak bisa membuka browser');
    }
  }

  /// Show a floating overlay toast
  void _showToast(String message) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.black,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) entry.remove();
    });
  }

  /// Mapping ID → judul kategori doa (eksplisit, hindari false match)
  static const Map<String, String> _doaCategoryIds = {
    'doa sehari hari': 'Doa Sehari-hari',
    'doa sholat': 'Doa Sholat',
    'doa puasa': 'Doa Puasa Ramadhan',
    'doa taubat': 'Doa Taubat & Istighfar',
    'doa perlindungan': 'Doa Perlindungan',
    'dzikir pagi': 'Dzikir Pagi & Petang',
    'doa orangtua': 'Doa untuk Orang Tua & Keluarga',
    'doa alam': 'Doa Alam & Perjalanan',
    'doa sakit': 'Doa Sakit & Meninggal',
    'asmaul husna': 'Asmaul Husna',
  };

  /// Human-readable label untuk tombol
  String _buttonLabel(String screen) {
    switch (screen) {
      case 'surah':
        return 'Surah';
      case 'doa':
        return 'Doa';
      case 'hadits':
        return 'Hadits';
      case 'fiqih':
        return 'Fiqih';
      case 'zakat':
        return 'Zakat';
      case 'tasbih':
        return 'Tasbih';
      case 'tracker':
        return 'Tracker';
      case 'jurnal':
        return 'Jurnal';
      case 'quran':
        return 'Ayat';
      default:
        return screen;
    }
  }

  /// Navigasi: pop Muslim AI → push target screen
  Future<void> _navigateToScreen(String screen, String? param) async {
    final navigator = Navigator.of(context);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    Widget target;
    switch (screen) {
      case 'quran':
        // [Buka:quran:SURAH:AYAH] — buka surah + scroll ke ayat + highlight kuning
        if (param != null && param.contains(':')) {
          final parts = param.split(':');
          final surahId = int.tryParse(parts[0]) ?? 1;
          final ayahNumber = int.tryParse(parts[1]);
          target = SurahReaderScreen(
            surahId: surahId,
            referenceAyahNumber: ayahNumber,
          );
        } else {
          final surahId = int.tryParse(param ?? '') ?? 1;
          target = SurahReaderScreen(surahId: surahId);
        }
        break;

      case 'surah':
        final surahId = int.tryParse(param ?? '') ?? 1;
        target = SurahReaderScreen(surahId: surahId);
        break;

      case 'doa':
        if (param != null && param.isNotEmpty) {
          // Mapping ID → judul kategori doa (eksplisit, hindari fuzzy match)
          final catTitle =
              _doaCategoryIds[param.replaceAll('-', ' ').toLowerCase()];
          if (catTitle != null) {
            final cat = doaCollections.cast<Map<String, dynamic>?>().firstWhere(
              (c) => (c?['title'] as String? ?? '') == catTitle,
              orElse: () => null,
            );
            if (cat != null) {
              final doas = cat['doas'] as List<Map<String, dynamic>>? ?? [];
              target = DoaListScreen(
                title: cat['title'] ?? '',
                emoji: cat['emoji'] ?? '🤲',
                doas: doas,
                isDark: isDark,
              );
              break;
            }
          }
        }
        target = const DoaHomeScreen();
        break;

      case 'hadits':
        if (param != null && param.isNotEmpty) {
          // Support [Buka:hadits:SLUG] atau [Buka:hadits:SLUG:NUMBER]
          final parts = param.split(':');
          final bookSlug = parts[0].toLowerCase();
          final highlightNumber = parts.length > 1 ? parts[1] : null;

          final provider = context.read<HaditsProvider>();
          final book = provider.books.cast<HaditsBook?>().firstWhere(
            (b) => b?.id.toLowerCase() == bookSlug,
            orElse: () => null,
          );
          if (book != null) {
            target = HaditsReaderScreen(
              book: book,
              isDark: isDark,
              highlightNumber: highlightNumber,
            );
            break;
          }
        }
        target = const HaditsHomeScreen();
        break;

      case 'fiqih':
        if (param != null && param.isNotEmpty) {
          // Cari topik fiqih berdasarkan ID
          final item = fiqihOfflineData
              .cast<Map<String, dynamic>?>()
              .firstWhere(
                (i) => i?['id']?.toString() == param,
                orElse: () => null,
              );
          if (item != null) {
            // Tampilkan detail fiqih langsung sebagai bottom sheet
            _showFiqihDetail(item, isDark);
            return; // Jangan pushReplacement, cukup show modal
          }
        }
        target = const FiqihHomeScreen();
        break;

      case 'zakat':
        target = const ZakatScreen();
        break;
      case 'tasbih':
        target = const TasbihScreen();
        break;
      case 'tracker':
        target = const TrackerScreen();
        break;
      case 'jurnal':
        target = const JurnalDashboardScreen();
        break;
      default:
        return;
    }

    // Stop audio Quran (jika sedang diputar) sebelum navigasi
    try {
      await context.read<QuranProvider>().stopAudio();
    } catch (_) {}

    // Push target screen di atas AI — back kembali ke AI
    navigator.push(CupertinoPageRoute(builder: (_) => target));
  }

  /// Tampilkan detail fiqih langsung di bottom sheet
  void _showFiqihDetail(Map<String, dynamic> item, bool isDark) {
    final catInfo = _fiqihCategoryInfo(item['category'] as String? ?? '');

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 500,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (catInfo['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${catInfo['emoji']} ${_capitalize(item['category'] as String? ?? '')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: catInfo['color'] as Color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 24,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                item['title'] as String? ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Container(
              height: 1,
              color: CupertinoColors.systemGrey5.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  item['content'] as String? ?? '',
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
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _fiqihCategoryInfo(String category) {
    const categories = {
      'thaharah': {'emoji': '💧', 'color': AppColors.fiqihThaharah},
      'sholat': {'emoji': '🕌', 'color': AppColors.fiqihSholat},
      'puasa': {'emoji': '🌙', 'color': AppColors.accent},
      'zakat': {'emoji': '💰', 'color': AppColors.warning},
      'haid': {'emoji': '🩸', 'color': AppColors.toolPink},
      'jenazah': {'emoji': '🤍', 'color': AppColors.textSubtle},
      'doa': {'emoji': '🤲', 'color': AppColors.fiqihDoa},
      'amalan': {'emoji': '✨', 'color': AppColors.toolCyan},
    };
    return categories[category.toLowerCase()] ??
        {'emoji': '📖', 'color': AppColors.textSubtle};
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<MuslimAiProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_text_fill,
              size: 18,
              color: AppColors.toolIndigo,
            ),
            SizedBox(width: 8),
            Text(AppStrings.aiTitle),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Mode selector
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : CupertinoColors.systemBackground,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.systemGrey6,
                  ),
                ),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _modes.length,
                itemBuilder: (context, index) {
                  final mode = _modes[index];
                  final isActive = provider.activeMode == mode['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () => provider.setMode(mode['id'] as String),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.toolIndigo.withValues(alpha: 0.15)
                              : CupertinoColors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mode['emoji'] as String),
                            const SizedBox(width: 4),
                            Text(
                              mode['label'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive
                                    ? AppColors.toolIndigo
                                    : (isDark
                                          ? CupertinoColors.systemGrey
                                          : CupertinoColors.systemGrey2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    provider.messages.length + (provider.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= provider.messages.length) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const CupertinoActivityIndicator(radius: 8),
                          const SizedBox(width: 8),
                          Text(
                            'Mengetik...',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final msg = provider.messages[index];
                  final isUser = msg.role == 'user';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isUser)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.toolIndigo.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              CupertinoIcons.sparkles,
                              size: 16,
                              color: AppColors.toolIndigo,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.toolIndigo
                                  : (isDark
                                        ? AppColors.surfaceDark
                                        : CupertinoColors.white),
                              borderRadius: BorderRadius.circular(16).copyWith(
                                bottomLeft: isUser
                                    ? null
                                    : const Radius.circular(4),
                                bottomRight: isUser
                                    ? const Radius.circular(4)
                                    : null,
                              ),
                              border: !isUser
                                  ? Border.all(
                                      color: isDark
                                          ? AppColors.textLight
                                          : CupertinoColors.systemGrey6,
                                    )
                                  : null,
                            ),
                            child: isUser
                                ? Text(
                                    msg.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: CupertinoColors.white,
                                    ),
                                  )
                                : _buildAiMessage(msg.text, isDark),
                          ),
                        ),
                        if (isUser) const SizedBox(width: 8),
                        if (isUser)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: (isDark
                                  ? AppColors.textLight
                                  : CupertinoColors.systemGrey5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              CupertinoIcons.person_fill,
                              size: 16,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : CupertinoColors.systemBackground,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.systemGrey6,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: 'Ketik pesan...',
                      padding: const EdgeInsets.all(14),
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
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SendButton(
                    canSend: provider.canSend,
                    cooldownProgress: provider.cooldownProgress,
                    isLoading: provider.isLoading,
                    totalCooldownSeconds: provider.cooldownSeconds,
                    onSend: () {
                      final text = _controller.text;
                      if (text.trim().isNotEmpty) {
                        provider.sendMessage(text);
                        _controller.clear();
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (_scrollController.hasClients) {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
                        });
                      }
                    },
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

/// Send button dengan water-fill animation saat cooldown
class _SendButton extends StatelessWidget {
  final bool canSend;
  final double cooldownProgress;
  final bool isLoading;
  final int totalCooldownSeconds;
  final VoidCallback onSend;

  const _SendButton({
    required this.canSend,
    required this.cooldownProgress,
    required this.isLoading,
    this.totalCooldownSeconds = 1800,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = !canSend || isLoading;
    final double waterLevel = disabled ? cooldownProgress.clamp(0.0, 1.0) : 1.0;
    final bool showTimer = disabled && !isLoading;

    // Hitung sisa waktu berdasarkan totalCooldownSeconds
    String timerText = '';
    if (showTimer && cooldownProgress < 1.0) {
      final remaining = ((1.0 - cooldownProgress) * totalCooldownSeconds)
          .round();
      timerText = '${remaining}s';
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: disabled ? null : onSend,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: disabled
                ? CupertinoColors.systemGrey.withValues(alpha: 0.3)
                : AppColors.toolIndigo,
            border: Border.all(
              color: disabled
                  ? CupertinoColors.systemGrey.withValues(alpha: 0.2)
                  : AppColors.toolIndigo.withValues(alpha: 0.6),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Water fill background
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: (48 * waterLevel),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [AppColors.indigoLight, AppColors.toolIndigo],
                      ),
                    ),
                  ),
                ),
                // Wave effect pada water surface
                if (disabled && !isLoading)
                  Positioned(
                    bottom: (48 * waterLevel - 3).clamp(0.0, 48.0),
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      size: const Size(48, 6),
                      painter: _AnimatedWaterPainter(
                        waterLevel: waterLevel,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                      ),
                    ),
                  ),
                // Loading indicator
                if (isLoading)
                  const Center(
                    child: CupertinoActivityIndicator(
                      radius: 10,
                      color: CupertinoColors.white,
                    ),
                  ),
                // Arrow icon atau timer
                if (!isLoading)
                  Center(
                    child: showTimer
                        ? Text(
                            timerText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: waterLevel > 0.5
                                  ? CupertinoColors.white
                                  : CupertinoColors.systemGrey,
                            ),
                          )
                        : const Icon(
                            CupertinoIcons.arrow_up,
                            color: CupertinoColors.white,
                            size: 22,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated water painter — moving wave + expanding ripple circles
class _AnimatedWaterPainter extends CustomPainter {
  final double waterLevel;
  final int timestamp;

  _AnimatedWaterPainter({required this.waterLevel, required this.timestamp});

  @override
  void paint(Canvas canvas, Size size) {
    final phase = timestamp / 500.0;
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.indigoLight, AppColors.toolIndigo],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // ─── Moving sine wave ───
    final wavePath = Path();
    final waveAmplitude = 2.0;
    wavePath.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y =
          math.sin((x / size.width) * math.pi * 4 + phase) * waveAmplitude;
      wavePath.lineTo(x, y + 3);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.close();
    canvas.drawPath(wavePath, wavePaint);

    // ─── Expanding ripple circles ───
    final ripplePositions = [
      0.25, 0.5, 0.75, // posisi X relatif
    ];
    for (final posX in ripplePositions) {
      // Ripple expands and fades over 1.5s cycle
      final rippleProgress = (timestamp % 1500) / 1500.0;
      final rippleRadius = rippleProgress * size.width * 0.3;
      final rippleAlpha = ((1.0 - rippleProgress) * 120).round();

      if (rippleRadius > 1 && rippleAlpha > 0) {
        final ripplePaint = Paint()
          ..color =AppColors.indigoLight.withValues(alpha:  rippleAlpha / 255.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

        canvas.drawCircle(
          Offset(size.width * posX, 2),
          rippleRadius.clamp(1.0, size.width * 0.4),
          ripplePaint,
        );
      }
    }

    // Second set of ripples (offset phase)
    for (final posX in ripplePositions) {
      final rippleProgress = ((timestamp + 500) % 1500) / 1500.0;
      final rippleRadius = rippleProgress * size.width * 0.25;
      final rippleAlpha = ((1.0 - rippleProgress) * 80).round();

      if (rippleRadius > 1 && rippleAlpha > 0) {
        final ripplePaint2 = Paint()
          ..color =AppColors.indigoVeryLight.withValues(alpha: rippleAlpha / 255.0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

        canvas.drawCircle(
          Offset(size.width * posX, 2),
          rippleRadius.clamp(1.0, size.width * 0.4),
          ripplePaint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedWaterPainter oldDelegate) =>
      oldDelegate.timestamp != timestamp ||
      oldDelegate.waterLevel != waterLevel;
}
