import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/notes_model.dart';
import 'package:flutter_application_1/screens/note_details_screen.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final bool isListView;
  final Function()? onDelete;
  final Function()? onTogglePin;

  const NoteCard({
    required this.note,
    required this.isListView,
    required this.onDelete,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              onTogglePin?.call();
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.isPinned ? 'Unpin' : 'Pin',
          ),
          SlidableAction(
            onPressed: (_) {
              onDelete?.call();
            },
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: note.isPinned ? 4 : 1,
        color: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              note.isPinned
                  ? BorderSide(color: Colors.amber, width: 2)
                  : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteDetailsScreen(note: note),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(isListView ? 10 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: isListView ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned)
                      Icon(Icons.push_pin, color: Colors.amberAccent, size: 18),
                  ],
                ),
                if (!isListView) ...[
                  SizedBox(height: 4),
                  Text(
                    note.content,
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                Text(
                  note.content,
                  style: TextStyle(fontSize: 14, color: Colors.blueGrey[700]),
                  maxLines: isListView ? 1 : 4,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                if (note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children:
                        note.tags.take(isListView ? 1 : 3).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(color: Colors.blueAccent),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      dateFormat.format(note.updatedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
