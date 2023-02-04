import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/month_summary.dart';
import 'package:hive/hive.dart';
import '../components/my_alert_box.dart';
import '../components/my_fab.dart';
import '../data/habit_database.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HabitDatabase db = HabitDatabase();
  final _mybox = Hive.box("Habit_database");

  @override
  void initState(){
    if (_mybox.get("CURRENT_HABIT_LIST") == null){
      print(_mybox.get("CURRENT_HABIT_LIST"));
      db.createDefaultData();
    } else{
      db.loadData();
    }

    db.updateDatabase();
    super.initState();
  }

  void checkBoxTapped(bool? value, int index){
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  final _newHabitController = TextEditingController();
  void createNewHabits(){
    showDialog(
        context: context,
        builder: (context){
          return MyAlertBox(
            controller: _newHabitController,
            onSave: saveNewHabit,
            onCancel: cancelDialogBox,
            hintext: 'Enter Habit name',
          );
        });
  }
  void saveNewHabit(){
    setState(() {
      db.todaysHabitList.add([_newHabitController.text, false]);
    });
    _newHabitController.clear();
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void cancelDialogBox(){
    _newHabitController.clear();
    Navigator.of(context).pop();
  }

  void openHabitSettings(int index){
    showDialog(
        context: context,
        builder: (context){
          return MyAlertBox(
              controller: _newHabitController,
              onSave: (){
                saveExistingHabit(index);
              },
              onCancel: cancelDialogBox,
            hintext: db.todaysHabitList[index][0],
          );
        }
    );
  }

  void saveExistingHabit(int index){
    setState(() {
      db.todaysHabitList[index][0] = _newHabitController.text;
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void deleteHabit(int index){
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabits),
      body: ListView(
        children: [
          MonthlySummary(datasets: db.heatMapDataSet, startDate: _mybox.get("START_DATE")),
          ListView.builder(
            shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: db.todaysHabitList.length,
              itemBuilder: (context, index){
                return HabitTile(
                  habitName: db.todaysHabitList[index][0],
                  habitCompleted: db.todaysHabitList[index][1],
                  onChanged: (value){
                    checkBoxTapped(value, index);
                  },
                  settingsTapped: (context ) {
                    openHabitSettings(index);
                  },
                  deleteTapped: (context ) {
                    deleteHabit(index);
                  },
                );
              }
          )
        ],
      ),
    );
  }
}