// lib/widgets/responsive_wrapper.dart
import 'package:flutter/material.dart';
import '../core/utils/responsive_utils.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool constrainWidth;
  final EdgeInsets? customPadding;
  
  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.constrainWidth = true,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    
    // Apply responsive padding
    final padding = customPadding ?? ResponsiveUtils.getResponsivePadding(context);
    content = Padding(
      padding: padding,
      child: content,
    );
    
    // Constrain width for large screens
    if (constrainWidth && !ResponsiveUtils.isMobile(context)) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth,
          ),
          child: content,
        ),
      );
    }
    
    return content;
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    int columns;
    
    if (ResponsiveUtils.isMobile(context)) {
      columns = mobileColumns ?? 1;
    } else if (ResponsiveUtils.isTablet(context)) {
      columns = tabletColumns ?? 2;
    } else {
      columns = desktopColumns ?? 3;
    }
    
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        final childWidth = (MediaQuery.of(context).size.width - 
            (columns - 1) * spacing) / columns;
        
        return SizedBox(
          width: ResponsiveUtils.isMobile(context) ? null : childWidth,
          child: child,
        );
      }).toList(),
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? elevation;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUtils.isMobile(context) 
            ? double.infinity 
            : ResponsiveUtils.maxCardWidth,
      ),
      child: Card(
        elevation: elevation ?? 2,
        child: Padding(
          padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
          child: child,
        ),
      ),
    );
  }
}
