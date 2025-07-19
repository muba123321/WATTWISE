// import 'package:flutter/material.dart';

// class EnergyTipsCard extends StatefulWidget {
//   final List<String> tips;
//   final int initialTipIndex;
//   final bool autoRotate;
//   final Duration rotationDuration;

//   const EnergyTipsCard({
//     super.key,
//     required this.tips,
//     this.initialTipIndex = 0,
//     this.autoRotate = true,
//     this.rotationDuration = const Duration(seconds: 10),
//   });

//   @override
//   EnergyTipsCardState createState() => EnergyTipsCardState();
// }

// class EnergyTipsCardState extends State<EnergyTipsCard> {
//   late int _currentTipIndex;
//   late PageController _pageController;

//   @override
//   void initState() {
//     super.initState();
//     _currentTipIndex = widget.initialTipIndex;
//     _pageController = PageController(initialPage: _currentTipIndex);

//     if (widget.autoRotate && widget.tips.length > 1) {
//       Future.delayed(widget.rotationDuration, _rotateTip);
//     }
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _rotateTip() {
//     if (!mounted) return;

//     setState(() {
//       _currentTipIndex = (_currentTipIndex + 1) % widget.tips.length;
//       _pageController.animateToPage(
//         _currentTipIndex,
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOut,
//       );
//     });

//     Future.delayed(widget.rotationDuration, _rotateTip);
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _currentTipIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.tips.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Icon(
//                   Icons.lightbulb,
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Energy Saving Tip',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const Spacer(),
//                 if (widget.tips.length > 1)
//                   Row(
//                     children: List.generate(
//                       widget.tips.length,
//                       (index) => Container(
//                         width: 8,
//                         height: 8,
//                         margin: const EdgeInsets.symmetric(horizontal: 2),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: index == _currentTipIndex
//                               ? Theme.of(context).primaryColor
//                               : Colors.grey.shade300,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Tips content
//             SizedBox(
//               height: 100,
//               child: PageView.builder(
//                 controller: _pageController,
//                 itemCount: widget.tips.length,
//                 onPageChanged: _onPageChanged,
//                 physics: const BouncingScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   return _buildTipContent(widget.tips[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTipContent(String tip) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           tip,
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         const Spacer(),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             if (widget.tips.length > 1)
//               Text(
//                 'Swipe for more tips',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//           ],
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

class EnergyTipsCard extends StatefulWidget {
  final List<String> tips;
  final int initialTipIndex;
  final bool autoRotate;
  final Duration rotationDuration;

  const EnergyTipsCard({
    super.key,
    required this.tips,
    this.initialTipIndex = 0,
    this.autoRotate = true,
    this.rotationDuration = const Duration(seconds: 10),
  });

  @override
  State<EnergyTipsCard> createState() => _EnergyTipsCardState();
}

class _EnergyTipsCardState extends State<EnergyTipsCard> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTipIndex;
    _pageController = PageController(initialPage: _currentIndex);

    if (widget.autoRotate && widget.tips.length > 1) {
      Future.delayed(widget.rotationDuration, _rotateTip);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _rotateTip() {
    if (!mounted) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.tips.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });

    Future.delayed(widget.rotationDuration, _rotateTip);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tips.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildPageView(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(Icons.lightbulb, color: primary),
        const SizedBox(width: 8),
        Text(
          'Energy Saving Tip',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (widget.tips.length > 1) _buildDots(context),
      ],
    );
  }

  Widget _buildDots(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactive = Theme.of(context).colorScheme.onSurface.withOpacity(0.3);

    return Row(
      children: List.generate(
        widget.tips.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentIndex ? primary : inactive,
          ),
        ),
      ),
    );
  }

  Widget _buildPageView(BuildContext context) {
    return SizedBox(
      height: 100,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.tips.length,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return _buildTipContent(context, widget.tips[index]);
        },
      ),
    );
  }

  Widget _buildTipContent(BuildContext context, String tip) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tip,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        if (widget.tips.length > 1)
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'Swipe for more tips',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
