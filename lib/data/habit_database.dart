//reference our box
import 'package:hive/hive.dart';
import '../datetime/dart_time.dart';

final _mybox = Hive.box("Habit_Database");
class HabitDatabase{
  List todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  //create initial default data
void createDefaultData(){
  todaysHabitList = [
    ["Run", false],
    ["Read", false]
  ];
  _mybox.put("START_DATE", todaysDateFormatted());
}

  void loadData(){
  //if it's a new day, get habit list from database
    if(_mybox.get(todaysDateFormatted())== null){
      todaysHabitList = _mybox.get("CURRENT_HABIT_LIST");
      //set  all habit completed to false since it's a new day
      for (int i=0; i< todaysHabitList.length; i++){
        todaysHabitList[i][1] = false;
      }
    }
    //if it's not a new day, load today list
    else{
      todaysHabitList = _mybox.get(todaysDateFormatted());
    }
  }

  void updateDatabase(){
  //update today entry
    print("todaysHabitList");
    print(todaysHabitList);
  _mybox.put(todaysDateFormatted(),todaysHabitList);
  //update universal habit list in case it changed (new habit, edit, update habit, delete habit)
  _mybox.put("CURRENT_HABIT_LIST",todaysHabitList);
  //calculate habit complete percentages for each day
    calculateHabitPercentages();
    //load heat map
    loadHeatMap();
  }

  void calculateHabitPercentages(){
  int countCompleted = 0;
  for (int i=0; i < todaysHabitList.length; i++){
    if (todaysHabitList[i][1] == true){
      countCompleted++;
    }
  }
  String percent = todaysHabitList.isEmpty
      ? '0.0'
      : (countCompleted / todaysHabitList.length).toStringAsFixed(1);

  //key : "PERCENTAGE_SUMMARY_yyyymmdd"
    //value : string of 1dp number between 0.0-1.0 inclusive
    _mybox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatMap(){
  DateTime startDate = createDateTimeObject(_mybox.get("START_DATE"));

  //count the number of days to load
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    //go from start date to today and add each percentage tothe dataset
    //PERCENTAGE_SUMMARY_yyyymmdd" will be the key in the database
  for (int i=0; i < daysInBetween + 1; i++){
    String yyyymmdd = convertDateTimeToString(startDate.add(Duration(days: i)),);

    double strengthAsPercent = double.parse(_mybox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",);

    //split the datetime up like below so it doesn't worry hours/min/sec etc

    //year
    int year = startDate.add(Duration(days: i)).year;
    //month
    int month = startDate.add(Duration(days: i)).month;
    //day
    int day = startDate.add(Duration(days: i)).day;

    final percentForEachDay = <DateTime, int>{
      DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
    };

    heatMapDataSet.addEntries(percentForEachDay.entries);
    print(heatMapDataSet);
  }
  }
}