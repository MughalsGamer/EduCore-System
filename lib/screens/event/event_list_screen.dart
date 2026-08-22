import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import 'add_edit_event_screen.dart';

const _purple = Color(0xFF534AB7);
const _purpleLight = Color(0xFFF0EFFE);

class EventListScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showFAB;

  /// Wide-screen dashboard is is callback se right panel me
  /// Add/Edit event form khol sakta hai.
  final void Function(EventModel? existingEvent)? onAddOrEdit;

  const EventListScreen({
    super.key,
    this.showAppBar = true,
    this.showFAB = true,
    this.onAddOrEdit,
  });

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  String? _expandedEventId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().listenToEvents();
    });
  }

  void _toggleExpand(String id) {
    setState(() {
      _expandedEventId = (_expandedEventId == id) ? null : id;
    });
  }

  void _openAddEvent() {
    if (widget.onAddOrEdit != null) {
      widget.onAddOrEdit!(null);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditEventScreen(
            onSaved: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  void _openEditEvent(EventModel event) {
    if (widget.onAddOrEdit != null) {
      widget.onAddOrEdit!(event);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddEditEventScreen(
            existingEvent: event,
            onSaved: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDelete(EventModel event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Event Delete Karein?'),
        content: Text(
            '"${event.title}" ko delete karna chahte hain? Ye action wapis nahi ho sakta.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<EventProvider>().deleteEvent(event.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event delete ho gaya')),
        );
      }
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _statusChip(EventModel event) {
    final active = event.isActive && !event.isExpired;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEAF3DE) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        active ? 'Active' : 'Expired',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: active ? const Color(0xFF3B6D11) : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _eventCard(EventModel event) {
    final isExpanded = _expandedEventId == event.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? _purple.withOpacity(0.4) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleExpand(event.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.event_rounded,
                        color: _purple, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 11, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(_formatDate(event.date),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _statusChip(event),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    event.description.isEmpty
                        ? 'Koi description nahi di gayi.'
                        : event.description,
                    style: const TextStyle(fontSize: 12.5, color: Colors.black87, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => _openEditEvent(event),
                        icon: const Icon(Icons.edit_rounded, size: 15),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: _purple,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => _confirmDelete(event),
                        icon: const Icon(Icons.delete_outline_rounded, size: 15),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.events.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: _purple),
            ),
          );
        }

        if (provider.events.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 40, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Text('Koi event nahi hai',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('Naya event add karne ke liye + button dabayein',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: provider.events.length,
          itemBuilder: (context, index) => _eventCard(provider.events[index]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (!widget.showAppBar) {
      return widget.showFAB
          ? Stack(
        children: [
          body,
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              backgroundColor: _purple,
              onPressed: _openAddEvent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      )
          : body;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: body,
      floatingActionButton: widget.showFAB
          ? FloatingActionButton(
        backgroundColor: _purple,
        onPressed: _openAddEvent,
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}