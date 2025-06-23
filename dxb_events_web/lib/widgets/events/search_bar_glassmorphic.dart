import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:glassmorphism/glassmorphism.dart';

import '../../core/constants/app_colors.dart';

class SearchBarGlassmorphic extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;
  final bool isEnabled;

  const SearchBarGlassmorphic({
    super.key,
    required this.controller,
    this.hintText = 'Search events, categories, locations...',
    this.onClear,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<SearchBarGlassmorphic> createState() => _SearchBarGlassmorphicState();
}

class _SearchBarGlassmorphicState extends State<SearchBarGlassmorphic> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused 
              ? const Color(0xFFFF6B6B) 
              : Colors.grey.withOpacity(0.3),
          width: _isFocused ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused 
                ? const Color(0xFFFF6B6B).withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isFocused ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(
              LucideIcons.search,
              color: _isFocused 
                  ? const Color(0xFFFF6B6B)
                  : const Color(0xFF666666),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                enabled: widget.isEnabled,
                onChanged: widget.onChanged,
                style: GoogleFonts.inter(
                  color: const Color(0xFF333333),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onClear?.call();
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.x,
                    color: const Color(0xFFFF6B6B),
                    size: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 