import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final int visiblePageCount;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.visiblePageCount = 5,
  }) : super(key: key);

  List<int> _getVisiblePages() {
    if (totalPages <= visiblePageCount) {
      return List.generate(totalPages, (index) => index + 1);
    }

    final halfVisible = visiblePageCount ~/ 2;
    int start = currentPage - halfVisible;
    int end = currentPage + halfVisible;

    if (start < 1) {
      start = 1;
      end = visiblePageCount;
    } else if (end > totalPages) {
      start = totalPages - visiblePageCount + 1;
      end = totalPages;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final visiblePages = _getVisiblePages();
    final showFirstEllipsis = visiblePages.isNotEmpty && visiblePages.first > 1;
    final showLastEllipsis = visiblePages.isNotEmpty && visiblePages.last < totalPages;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavigationButton(
            icon: Icons.keyboard_double_arrow_left,
            onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
            tooltip: 'First page',
          ),
          const SizedBox(width: 8),
          _buildNavigationButton(
            icon: Icons.keyboard_arrow_left,
            onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            tooltip: 'Previous page',
          ),
          const SizedBox(width: 16),
          if (showFirstEllipsis) ...[
            _buildPageButton(1),
            if (visiblePages.first > 2) _buildEllipsis(),
          ],
          ...visiblePages.map((page) => _buildPageButton(page)),
          if (showLastEllipsis) ...[
            if (visiblePages.last < totalPages - 1) _buildEllipsis(),
            _buildPageButton(totalPages),
          ],
          const SizedBox(width: 16),
          _buildNavigationButton(
            icon: Icons.keyboard_arrow_right,
            onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            tooltip: 'Next page',
          ),
          const SizedBox(width: 8),
          _buildNavigationButton(
            icon: Icons.keyboard_double_arrow_right,
            onPressed: currentPage < totalPages ? () => onPageChanged(totalPages) : null,
            tooltip: 'Last page',
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: onPressed != null ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: onPressed != null ? Colors.grey.shade300 : Colors.grey.shade200,
              ),
              boxShadow: onPressed != null
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 20,
              color: onPressed != null ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Builder(
        builder: (BuildContext context) {
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isActive ? null : () => onPageChanged(page),
              child: Container(
                constraints: const BoxConstraints(minWidth: 40),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isActive ? Theme.of(context).primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$page',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey.shade700,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEllipsis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Text(
          '...',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}