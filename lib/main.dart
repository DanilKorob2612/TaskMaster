import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:shared_preferences/shared_preferences.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:intl/intl.dart';

import 'package:table_calendar/table_calendar.dart';
import 'firebase_options.dart';


void main() async {
  initBase();
  final prefs = await SharedPreferences.getInstance();
  checkUserId();
  runApp(TaskMasterApp(preferences: prefs));
  
}


Future<void> checkUserId() async{ 
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("user_id") == null) {
        generateAndSaveUserId();
    }
    else {UserID = prefs.getString("user_id")!;}
}


// ignore: non_constant_identifier_names
String UserID = '';


Future<void> generateAndSaveUserId() async {
  // Генерация случайного ID
  String userId = DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
  // Получение экземпляра SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Сохранение ID в SharedPreferences
  await prefs.setString('user_id', userId);
  UserID = userId;
}



Future<void> initBase() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
}



class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key, required this.preferences});
//Тема
    final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Task Master",
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        primarySwatch: Colors.yellow,
        dividerColor: Colors.white,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.black,
        ),
        listTileTheme: ListTileThemeData(iconColor: Colors.grey[600]),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          labelSmall: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      routes: {
        '/': (context) =>  const EventListScreen(),
        '/calendar': (context) => const CalendarPage(),
        '/AddEvent' : (context) => const AddEventScreen(),
      },
    );
  }
}


List allEventsList = [];
List allDocsList = [];

List todayEvents =[];
List docsList = [];
List eventsList = [];

Future<void> getAllEvents() async {
    allEventsList = [];
     await FirebaseFirestore.instance.collection("Events").get().then((event) {
        for (var doc in event.docs) {
            Map event = doc.data();
            allEventsList.add(event);
            allDocsList.add(doc.id);
     }});

}


void getEventsForDay(dynamic focusedDay) { //focusedDay = YYYY.MM.DD
            eventsListOnDay = [];
            eventsList.clear();
            selectedyear = null;
            selectedmonth = null;
            selectedday = null;
            var date = focusedDay.toString();
             selectedyear = int.parse(date[0] + date[1] + date[2] + date[3]); 
             selectedmonth = int.parse(date[5] + date[6]);
             selectedday = int.parse(date[8] + date[9]);
             for (var e in allEventsList) {
               if((e["year"] == selectedyear) &&
                (e["month"] == selectedmonth) &&
                (e["day"] == selectedday) &&
                 (int.parse(UserID) == int.parse(e["id"]))) {
                 eventsListOnDay.add(e);}}}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
   Widget build(BuildContext context, ) {
   final theme = Theme.of(context);
   DateTime now = DateTime.now();
   String formattedDate = DateFormat('dd.MM.yyyy').format(now); // Форматируем дату
   int selectedIndex = 0;
   Future<void> onItemTapped(int index) async{
     selectedIndex = index;
     if (selectedIndex == 1){
        await getAllEvents();


      Navigator.of(context).pushNamed('/calendar');}
     if (selectedIndex == 0){ 
        await getAllEvents();
        getEventsForDay(DateFormat("yyyy.MM,dd").format(now));
       
      Navigator.of(context).pushNamed('/');}
     }
   return Scaffold(
    

     appBar: AppBar(
       title: Text("Список задач на сегодня $formattedDate"),
       centerTitle: true,
     ),
     bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "задачи на сегодня"),
            BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: "календарь"),
            ],
        currentIndex: selectedIndex,
        unselectedItemColor: Colors.grey[600],
        selectedItemColor: Colors.grey[600],
        onTap: onItemTapped,
     ),
      body: ListView.separated(
         itemCount: eventsListOnDay.length,
         separatorBuilder: (context, index) => const Divider(),
         itemBuilder: (context, i) {
           return ListTile(
             leading: const Icon(Icons.task),
             title: Text(
               eventsListOnDay[i]["label"],
               style: theme.textTheme.bodyMedium,
             ),
             subtitle: Text(
"${eventsListOnDay[i]["hour"].toString()}:${eventsListOnDay[i]["minute"].toString()} - ${eventsListOnDay[i]["description"]}",
               style: theme.textTheme.labelSmall,
             ),
           );
           },
         ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add', 
            onPressed:() {
              Navigator.of(context).pushNamed('/AddEvent');},
            child: const Icon(Icons.add),
          ),  
      
      );
    }
}
 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   List eventsListOnDay = [];
   List docsListOnDay = [];
   dynamic selectedyear;
   
   dynamic selectedmonth;
   
   dynamic selectedday;
   
   class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

     @override
     
     State<CalendarPage> createState() => _CalendarPageState();
   }

   class _CalendarPageState extends State<CalendarPage> {
      late final ValueNotifier<List<Event>> _selectedEvents;
     DateTime _focusedDay = DateTime.now();
     DateTime? _selectedDay;

      @override
      void initState() {
        super.initState();
        _selectedDay = _focusedDay;
        _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
      }
      
      


      List<Event> _getEventsForDay(DateTime day) {
        
        return [];
      }

     void _onDaySelected(DateTime selectedDay,  DateTime focusedDay) {
       if (!isSameDay(_selectedDay, selectedDay)) {
         setState(()  {
           _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            getEventsForDay(focusedDay);
         });
          _selectedEvents.value = _getEventsForDay(selectedDay);
       }
     }
    int _selectedIndex = 1;
  Future<void> _onItemTapped(int index) async {
      _selectedIndex = index;
      if (_selectedIndex == 0){Navigator.of(context).pushNamed('/');
      if (_selectedIndex == 1){
        eventsListOnDay.clear();
        Navigator.of(context).pushNamed('/calendar');
      }
      }
  }


     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Календарь'),
            centerTitle: true,
         ),
         body: Column(
           children: [
             TableCalendar<Event>(
               firstDay: DateTime.utc(2020, 1, 1),
               lastDay: DateTime.utc(2030, 12, 31),
               focusedDay: _focusedDay,
               selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
               onDaySelected: _onDaySelected,
              
               eventLoader: (day) => _getEventsForDay(day),
             ),
             const SizedBox(height: 8.0),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                 valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: eventsListOnDay.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          title: Text("${eventsListOnDay[i]["label"]} - ${eventsListOnDay[i]["hour"]}:${eventsListOnDay[i]["minute"]} - ${eventsListOnDay[i]["description"]}"),
                        );
                    },
                     );
                },
                ),
              ),
           ],
         ),
         bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"),
            BottomNavigationBarItem(
            icon: Icon(Icons.update),
            label: "update"),
            ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.grey[600],
        selectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
      ),
       );
     }
   }

   class Event {
     final String title;

     Event(this.title);
   }




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
  }
class _AddEventScreenState extends State<AddEventScreen> {
  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Scaffold(
    appBar: AppBar(
      title: const Text("Добавить задачуц"),
      centerTitle: true,
    ),
    body: Container(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.00),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(
            onChanged: (text) {
              if (int.parse(text[0] + text[1]) < 31) {
                event["day"] = int.parse(text[0] + text[1]);
                answer_day = true;
                }
              if (int.parse( text[3] + text[4]) <= 12) {
                event["month"] = int.parse(text[3] + text[4]);
                answer_month = true;
              }
              if (int.parse( text[6] + text[7] + text[8] + text[9]) > 0) {
                event["year"] = int.parse(text[6] + text[7] + text[8] + text[9]);
                answer_year = true;
              }
              },
            controller: TextEditingController(),
            decoration: InputDecoration(labelText: "Введите дату(01:01:2030)",
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            )),
            keyboardType: TextInputType.datetime,
            maxLength: 10,
            ),
            TextField(
            onChanged: (text) {
            //event_start["time"] = text;
            if (int.parse(text[0] + text[1]) <= 24) {
              event["hour"] = int.parse(text[0] + text[1]);
              answer_hour = true;
            } 
            if (int.parse(text[3] + text[4]) < 24) {
              event["minute"] = int.parse(text[3] + text[4]);
              answer_minute = true;
            }
            },
              controller: TextEditingController(),
            decoration: InputDecoration(labelText: "Введите время(03:07)",
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),),
            keyboardType: TextInputType.datetime,
            maxLength: 5,
            ),
            TextField(
            onChanged: (text) {
              // ignore: unnecessary_cast
              event["label"] = text;
            },
            controller: TextEditingController(),
            decoration: InputDecoration(labelText: "Введите название события",
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),),
            keyboardType: TextInputType.text,
            maxLength: 20,
            ),
            TextField(
            onChanged: (text) {
              // ignore: unnecessary_cast
              event["description"] = text; },
              controller: TextEditingController(),
            decoration: InputDecoration(labelText: "Введите описание события",
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),),
            keyboardType: TextInputType.text,
            maxLength: 20,
            ), 
            ElevatedButton(
            onPressed: () async {try{
                await FirebaseFirestore.instance.collection('Events').add(event);
                answer_year = false;
                answer_month = false;
                answer_day = false;
                answer_hour = false;
                answer_minute = false; 
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed('/');
                }
                catch (e) { () {};}
                },
            style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.blue),),
            child: const Text("Создать"),
            )
          ],
        ) 
      ),
    );
  }
}

 // ignore: non_constant_identifier_names
 bool answer_year = false;
 // ignore: non_constant_identifier_names
 bool answer_month = false;
 // ignore: non_constant_identifier_names
 bool answer_day = false;
 // ignore: non_constant_identifier_names
 bool answer_hour = false;
 // ignore: non_constant_identifier_names
 bool answer_minute = false;


final event = {
    "id": UserID,
    "year": int,
    "month": int,
    "day": int,
    "hour":  int,
    "minute": int,
    "label": String,
    "description": String 
  };