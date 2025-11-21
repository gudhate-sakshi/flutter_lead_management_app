import 'package:flutter/material.dart';
import '/data/models/lead_model.dart';
import '/presentation/widgets/lead_card.dart';

class StaggeredLeadCard extends StatefulWidget {
  final Lead lead;
  final int index;

  const StaggeredLeadCard({
    super.key,
    required this.lead,
    required this.index,
  });

  @override
  State<StaggeredLeadCard> createState() => _StaggeredLeadCardState();
}

class _StaggeredLeadCardState extends State<StaggeredLeadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    
    final int delay = 150 + (widget.index * 50);

    
    _animation = Tween<Offset>(
      begin: const Offset(0.0, 0.5), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay / 1000.0,
        1.0,
        curve: Curves.easeOutCubic,
      ),
    ));

    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(
        delay / 1000.0, 
        1.0,
        curve: Curves.easeOut,
      ),
    ));


    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _animation,
            child: LeadCard(
              lead: widget.lead,
              index: widget.index, 
            ),
          ),
        );
      },
    );
  }
}