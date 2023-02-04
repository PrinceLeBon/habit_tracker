import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HabitTile extends StatelessWidget {
  final String habitName;
  final bool habitCompleted;
  final Function (bool?)? onChanged;
  final Function (BuildContext)? settingsTapped;
  final Function (BuildContext)? deleteTapped;

  const HabitTile({
    super.key,
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
    required this.settingsTapped,
    required this.deleteTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Slidable(
        endActionPane: ActionPane(
            motion: StretchMotion(),
            children: [
              SlidableAction(
                  onPressed: settingsTapped,
                backgroundColor: Colors.grey.shade800,
                icon: Icons.settings,
                  borderRadius: BorderRadius.circular(12)
              ),
              SlidableAction(
                  onPressed: deleteTapped,
                  backgroundColor: Colors.red.shade400,
                  icon: Icons.delete,
                  borderRadius: BorderRadius.circular(12)
              )
            ]
        ),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12)
            ),
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Checkbox(
                    value: habitCompleted,
                    onChanged: onChanged
                ),
                Text(habitName),
              ],
            ),
          )
      ),
    );
  }
}