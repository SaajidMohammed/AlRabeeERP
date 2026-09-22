import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../feedback/empty_state.dart';

class ErpTableColumn<T> {
  final String title;
  final Widget Function(T item) cellBuilder;
  final double? width;
  final int flex;
  final bool isNumeric;
  final int Function(T a, T b)? comparator;

  const ErpTableColumn({
    required this.title,
    required this.cellBuilder,
    this.width,
    this.flex = 1,
    this.isNumeric = false,
    this.comparator,
  });
}

class ErpDataTable<T> extends StatefulWidget {
  final List<T> items;
  final List<ErpTableColumn<T>> columns;
  final bool Function(T item, String query)? searchMatcher;
  final String searchPlaceholder;
  final Widget? trailingHeaderActions;
  final String emptyTitle;
  final String emptyDescription;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final void Function(T item)? onRowTap;
  final int rowsPerPage;

  const ErpDataTable({
    super.key,
    required this.items,
    required this.columns,
    this.searchMatcher,
    this.searchPlaceholder = 'Search records...',
    this.trailingHeaderActions,
    this.emptyTitle = 'No records found',
    this.emptyDescription = 'There are no records matching your criteria.',
    this.emptyActionLabel,
    this.onEmptyAction,
    this.onRowTap,
    this.rowsPerPage = 8,
  });

  @override
  State<ErpDataTable<T>> createState() => _ErpDataTableState<T>();
}

class _ErpDataTableState<T> extends State<ErpDataTable<T>> {
  String _searchQuery = '';
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items
    List<T> filtered = widget.items;
    if (_searchQuery.isNotEmpty && widget.searchMatcher != null) {
      filtered = filtered.where((item) => widget.searchMatcher!(item, _searchQuery.toLowerCase())).toList();
    }

    // Sort items
    if (_sortColumnIndex != null && _sortColumnIndex! < widget.columns.length) {
      final col = widget.columns[_sortColumnIndex!];
      if (col.comparator != null) {
        filtered = List<T>.from(filtered)
          ..sort((a, b) {
            final res = col.comparator!(a, b);
            return _sortAscending ? res : -res;
          });
      }
    }

    // Paginate
    final totalPages = (filtered.length / widget.rowsPerPage).ceil();
    final startIndex = _currentPage * widget.rowsPerPage;
    final endIndex = (startIndex + widget.rowsPerPage).clamp(0, filtered.length);
    final pageItems = (filtered.isNotEmpty && startIndex < filtered.length)
        ? filtered.sublist(startIndex, endIndex)
        : <T>[];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTokens.borderRadiusLg,
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: isDark ? [] : AppTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: LayoutBuilder(
              builder: (context, headerConstraints) {
                final isNarrow = headerConstraints.maxWidth < 600;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isNarrow ? headerConstraints.maxWidth : 320,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: widget.searchPlaceholder,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _currentPage = 0;
                          });
                        },
                      ),
                    ),
                    if (widget.trailingHeaderActions != null) widget.trailingHeaderActions!,
                  ],
                );
              },
            ),
          ),
          Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),

          // Table Content - Fully Scrollable Vertical & Horizontal
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: EmptyState(
                      title: widget.emptyTitle,
                      description: widget.emptyDescription,
                      actionLabel: widget.emptyActionLabel,
                      onAction: widget.onEmptyAction,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 800),
                        child: DataTable(
                          horizontalMargin: 20,
                          columnSpacing: 24,
                          headingRowHeight: 44,
                          dataRowMinHeight: 48,
                          dataRowMaxHeight: 54,
                          headingRowColor: WidgetStateProperty.all(
                            isDark ? AppColors.surfaceDark : const Color(0xFFF8FAFC),
                          ),
                          sortColumnIndex: _sortColumnIndex,
                          sortAscending: _sortAscending,
                          columns: widget.columns.map((col) {
                            return DataColumn(
                              numeric: col.isNumeric,
                              onSort: col.comparator != null
                                  ? (columnIndex, ascending) {
                                      setState(() {
                                        _sortColumnIndex = columnIndex;
                                        _sortAscending = ascending;
                                      });
                                    }
                                  : null,
                              label: Text(
                                col.title.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            );
                          }).toList(),
                          rows: pageItems.map((item) {
                            return DataRow(
                              onSelectChanged: widget.onRowTap != null ? (_) => widget.onRowTap!(item) : null,
                              cells: widget.columns.map((col) {
                                return DataCell(col.cellBuilder(item));
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),

          // Pagination Footer
          if (filtered.isNotEmpty) ...[
            Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: LayoutBuilder(
                builder: (context, footerConstraints) {
                  final isMobileFooter = footerConstraints.maxWidth < 450;
                  final textWidget = Text(
                    'Showing ${startIndex + 1}–$endIndex of ${filtered.length} items',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );

                  final controlsWidget = Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 18),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: _currentPage > 0
                            ? () => setState(() => _currentPage--)
                            : null,
                      ),
                      Text(
                        '${_currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 18),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: _currentPage < totalPages - 1
                            ? () => setState(() => _currentPage++)
                            : null,
                      ),
                    ],
                  );

                  if (isMobileFooter) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(child: textWidget),
                        const SizedBox(width: 8),
                        controlsWidget,
                      ],
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textWidget,
                      controlsWidget,
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
