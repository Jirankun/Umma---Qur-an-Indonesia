import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../utils/date_helper.dart';

class ToolGrid extends StatelessWidget {
  final bool isDark;
  final Function(String) onToolTap;

  const ToolGrid({super.key, required this.isDark, required this.onToolTap});

  List<_ToolItem> get _tools {
    final base = <_ToolItem>[
      _ToolItem(
        icon: CupertinoIcons.book_fill,
        label: AppStrings.homeToolQuran,
        color: AppColors.toolIndigo,
        route: '/quran',
      ),
      _ToolItem(
        icon: CupertinoIcons.heart_fill,
        label: AppStrings.homeToolDoa,
        color: AppColors.error,
        route: '/doa',
      ),
      _ToolItem(
        icon: CupertinoIcons.doc_text_fill,
        label: AppStrings.homeToolHadits,
        color: AppColors.accent,
        route: '/hadits',
      ),
      _ToolItem(
        icon: CupertinoIcons.doc_text_fill,
        label: AppStrings.homeToolFiqih,
        color: AppColors.warning,
        route: '/fiqih',
      ),
      _ToolItem(
        icon: CupertinoIcons.circle_fill,
        label: AppStrings.homeToolTasbih,
        color: AppColors.toolPurple,
        route: '/tasbih',
      ),
      _ToolItem(
        icon: CupertinoIcons.compass_fill,
        label: AppStrings.homeToolKiblat,
        color: AppColors.toolTeal,
        route: '/kompas',
      ),
      _ToolItem(
        icon: CupertinoIcons.chat_bubble_text_fill,
        label: AppStrings.homeToolMuslimAi,
        color: AppColors.toolIndigo,
        route: '/muslim-ai',
      ),
      _ToolItem(
        icon: CupertinoIcons.sportscourt_fill,
        label: AppStrings.homeToolTracker,
        color: AppColors.toolOrange,
        route: '/tracker',
      ),
      _ToolItem(
        icon: CupertinoIcons.pencil_ellipsis_rectangle,
        label: AppStrings.homeToolJurnal,
        color: AppColors.toolCyan,
        route: '/jurnal',
      ),
      _ToolItem(
        icon: CupertinoIcons.drop_fill,
        label: AppStrings.homeToolHaidTracker,
        color: AppColors.toolPink,
        route: '/haid',
      ),
    ];

    // Zakat hanya muncul di akhir Ramadhan
    if (DateHelper.isEndOfRamadhan(DateTime.now())) {
      base.insert(
        4,
        _ToolItem(
          icon: CupertinoIcons.money_dollar_circle_fill,
          label: AppStrings.homeToolZakat,
          color: AppColors.zakat,
          route: '/zakat',
        ),
      );
    }

    return base;
  }

  @override
  Widget build(BuildContext context) {
    final tools = _tools;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              AppStrings.homeFiturIbadah,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: AppColors.cupertinoSystemGrey,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return GestureDetector(
                onTap: () => onToolTap(tool.route),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.cupertinoSystemGrey6,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: tool.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(tool.icon, size: 20, color: tool.color),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tool.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.cupertinoWhite
                              : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _ToolItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}
