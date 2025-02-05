//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';

var x = 400;
var db;
var isAdmin = false;
var isClassAdmin = false;
int classID = 0;

List<dynamic> months = [
  ['01', 'January'],
  ['02', 'Februaury'],
  ['03', 'March'],
  ['04', 'April'],
  ['05', 'May'],
  ['06', 'June'],
  ['07', 'July'],
  ['08', 'August'],
  ['09', 'September'],
  ['10', 'October'],
  ['11', 'November'],
  ['12', 'December']
];
List<dynamic> lstBirthdays = [];
List<dynamic> lstMembers = [];
List<dynamic> lstMeetings = [];

List<List<dynamic>> announcementsData = [];
List<List<dynamic>> familiesData = [];
List<List<dynamic>> studentsData = [];
List<List<dynamic>> teachersData = [];
List<List<dynamic>> classesData = [];
List<List<dynamic>> meetingsData = [];

Future<void> _readData() async {
  if (isAdmin) {
    studentsData = [];
    await db.collection('students').orderBy('s_id').get().then((collec) {
      for (var i in collec.docs) {
        studentsData.add([
          i.data()['s_id'],
          i.data()['class_id'],
          i.data()['full_name'],
          i.data()['dob'],
          i.data()['gender'],
          i.data()['phone_num'],
          i.data()['conf_fr'],
          i.data()['family_id'],
          i.data()['fr_church'],
          i.data()['job'],
          i.data()['member_type']
        ]);
      }
    });
    teachersData = [];
    await db.collection('teachers').orderBy('t_id').get().then((collec) {
      for (var i in collec.docs) {
        teachersData.add([
          i.data()['t_id'],
          i.data()['class_id'],
          i.data()['t_name'],
          i.data()['t_gen'],
          i.data()['t_job'],
          i.data()['t_email'],
          i.data()['t_num']
        ]);
      }
    });
    meetingsData = [];
    await db.collection('meetings').orderBy('m_id').get().then((collec) {
      for (var i in collec.docs) {
        meetingsData.add([
          i.data()['m_id'],
          i.data()['student_id'],
          i.data()['m_date'],
          i.data()['m_comments'],
          i.data()['m_fr'],
          i.data()['man_can_edit'],
          i.data()['ser_can_edit'],
          i.data()['is_family'],
          i.data()['teacher_id']
        ]);
      }
    });
    announcementsData = [];
    await db.collection('announcements').orderBy('a_id').get().then((collec) {
      for (var i in collec.docs) {
        announcementsData.add(
            [i.data()['a_id'], i.data()['a_content'], i.data()['is_admin']]);
      }
    });
    familiesData = [];
    await db.collection('families').orderBy('f_id').get().then((collec) {
      for (var i in collec.docs) {
        familiesData.add([
          i.data()['f_id'],
          i.data()['f_name'],
          i.data()['f_address'],
          i.data()['address_link']
        ]);
      }
    });
  } else if (isClassAdmin) {
    List<dynamic> lstStudents = [];
    List<dynamic> lstFamilies = [];
    studentsData = [];
    await db
        .collection('students')
        .where('class_id', isEqualTo: classID)
        .orderBy('s_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        studentsData.add([
          i.data()['s_id'],
          i.data()['class_id'],
          i.data()['full_name'],
          i.data()['dob'],
          i.data()['gender'],
          i.data()['phone_num'],
          i.data()['conf_fr'],
          i.data()['family_id'],
          i.data()['fr_church'],
          i.data()['job'],
          i.data()['member_type']
        ]);
        lstStudents.add(i.data()['s_id']);
        if (!(lstFamilies.contains(i.data()['family_id']))) {
          lstFamilies.add(i.data()['family_id']);
        }
      }
    });
    await db.collection('students').orderBy('s_id').get().then((collec) {
      for (var i in collec.docs) {
        if (lstFamilies.contains(i.data()['family_id']) &&
            !(lstStudents.contains(i.data()['s_id']))) {
          studentsData.add([
            i.data()['s_id'],
            i.data()['class_id'],
            i.data()['full_name'],
            i.data()['dob'],
            i.data()['gender'],
            i.data()['phone_num'],
            i.data()['conf_fr'],
            i.data()['family_id'],
            i.data()['fr_church'],
            i.data()['job'],
            i.data()['member_type']
          ]);
        }
      }
    });
    teachersData = [];
    await db
        .collection('teachers')
        .where('class_id', arrayContains: classID)
        .orderBy('t_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        teachersData.add([
          i.data()['t_id'],
          i.data()['class_id'],
          i.data()['t_name'],
          i.data()['t_gen'],
          i.data()['t_job'],
          i.data()['t_email'],
          i.data()['t_num']
        ]);
      }
    });
    meetingsData = [];
    await db
        .collection('meetings')
        .where('is_family', isEqualTo: false)
        .orderBy('m_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        if (lstStudents.contains(i.data()['student_id'])) {
          meetingsData.add([
            i.data()['m_id'],
            i.data()['student_id'],
            i.data()['m_date'],
            i.data()['m_comments'],
            i.data()['m_fr'],
            i.data()['man_can_edit'],
            i.data()['ser_can_edit'],
            i.data()['is_family'],
            i.data()['teacher_id']
          ]);
        }
      }
    });
    await db
        .collection('meetings')
        .where('is_family', isEqualTo: true)
        .orderBy('m_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        if (lstFamilies.contains(i.data()['student_id'])) {
          meetingsData.add([
            i.data()['m_id'],
            i.data()['student_id'],
            i.data()['m_date'],
            i.data()['m_comments'],
            i.data()['m_fr'],
            i.data()['man_can_edit'],
            i.data()['ser_can_edit'],
            i.data()['is_family'],
            i.data()['teacher_id']
          ]);
        }
      }
    });
    List<dynamic> lstAnnouncements = classesData
        .where((element) => element[0] == classID)
        .map((e) => e.last)
        .toList()[0];
    announcementsData = [];
    await db
        .collection('announcements')
        .where('a_id', whereIn: lstAnnouncements)
        .orderBy('a_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        announcementsData.add(
            [i.data()['a_id'], i.data()['a_contents'], i.data()['is_admin']]);
      }
    });
    familiesData = [];
    await db.collection('families').orderBy('f_id').get().then((collec) {
      for (var i in collec.docs) {
        if (lstFamilies.contains(i.data()['f_id'])) {
          familiesData.add([
            i.data()['f_id'],
            i.data()['f_name'],
            i.data()['f_address'],
            i.data()['address_link']
          ]);
        }
      }
    });
  } else {
    List<dynamic> lstStudents = [];
    List<dynamic> lstFamilies = [];
    studentsData = [];
    await db
        .collection('students')
        .where('class_id', isEqualTo: classID)
        .orderBy('s_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        studentsData.add([
          i.data()['s_id'],
          i.data()['class_id'],
          i.data()['full_name'],
          i.data()['dob'],
          i.data()['gender'],
          i.data()['phone_num'],
          i.data()['conf_fr'],
          i.data()['family_id'],
          i.data()['fr_church'],
          i.data()['job'],
          i.data()['member_type']
        ]);
        lstStudents.add(i.data()['s_id']);
        if (!(lstFamilies.contains(i.data()['family_id']))) {
          lstFamilies.add(i.data()['family_id']);
        }
      }
    });
    teachersData = [];
    await db
        .collection('teachers')
        .where('class_id', arrayContains: classID)
        .orderBy('t_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        teachersData.add([
          i.data()['t_id'],
          i.data()['class_id'],
          i.data()['t_name'],
          i.data()['t_gen'],
          i.data()['t_job'],
          i.data()['t_email'],
          i.data()['t_num']
        ]);
      }
    });
    meetingsData = [];
    await db
        .collection('meetings')
        .where('student_id', whereIn: lstStudents)
        .where('is_family', isEqualTo: false)
        .orderBy('m_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        meetingsData.add([
          i.data()['m_id'],
          i.data()['student_id'],
          i.data()['m_date'],
          i.data()['m_comments'],
          i.data()['m_fr'],
          i.data()['man_can_edit'],
          i.data()['ser_can_edit'],
          i.data()['is_family'],
          i.data()['teacher_id']
        ]);
      }
    });
    List<dynamic> lstAnnouncements = classesData
        .where((element) => element[0] == classID)
        .map((e) => e.last)
        .toList()[0];
    announcementsData = [];
    await db
        .collection('announcements')
        .where('a_id', whereIn: lstAnnouncements)
        .orderBy('a_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        announcementsData.add(
            [i.data()['a_id'], i.data()['a_content'], i.data()['is_admin']]);
      }
    });
    familiesData = [];
    await db
        .collection('families')
        .where('f_id', whereIn: lstFamilies)
        .orderBy('f_id')
        .get()
        .then((collec) {
      for (var i in collec.docs) {
        familiesData.add([
          i.data()['f_id'],
          i.data()['f_name'],
          i.data()['f_address'],
          i.data()['address_link']
        ]);
      }
    });
  }
}

Future<void> _readClasses() async {
  db = FirebaseFirestore.instance;
  await db.collection('classes').orderBy('c_id').get().then((collec) {
    for (var i in collec.docs) {
      classesData.add([
        i.data()['c_id'],
        i.data()['c_name'],
        i.data()['c_usr'],
        i.data()['c_man_pass'],
        i.data()['c_ser_pass'],
        i.data()['announcement_id']
      ]);
    }
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences storedClass = await SharedPreferences.getInstance();
  bool isStored = storedClass.containsKey('classID');
  if (!isStored) {
    await storedClass.setInt('classID', -1);
    await storedClass.setInt('classAdmin', 0);
  }
  var isLoggedIn = storedClass.getInt('classID');
  await _readClasses();
  if (isLoggedIn != -1) {
    if (isLoggedIn != -2) {
      var classExists = false;
      for (var x in classesData) {
        if (x[0] == isLoggedIn) {
          classExists = true;
          break;
        }
      }
      if (classExists) {
        classID = isLoggedIn!;
        if (storedClass.getInt('classAdmin') == 1) {
          isClassAdmin = true;
        }
        await _readData();
      } else {
        isLoggedIn = -1;
        await storedClass.setInt('classID', -1);
        await storedClass.setInt('classAdmin', 0);
      }
    } else {
      isAdmin = true;
      await _readData();
    }
  }
  runApp(isLoggedIn == -1 ? const MyAppLandingPage() : const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eftekad App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 84, 255, 106)),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'Dashboard'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int curIndex = 0;
  final List<Widget> screens = const [
    HomePage(title: '-'),
    FamiliesPage(title: '-'),
    MeetingsPage(title: '-'),
    ProfilePage(title: '-')
  ];

  void _onPageIconTap(int i) {
    setState(() {
      curIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[curIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.church_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_rounded),
            label: 'Families',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_rounded),
            label: 'Visits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Profile',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        iconSize: 25,
        currentIndex: curIndex,
        onTap: _onPageIconTap,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    lstBirthdays = [];
    super.initState();
  }

  Future<void> _onAddAnnouncementPress(BuildContext context) async {
    List<dynamic>? newTile =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddAnnouncementPage(title: '-');
    }));
    if (!context.mounted) {
      return;
    }
    if (newTile != null) {
      var newAnnouncement = <String, dynamic>{
        'a_id': announcementsData.last[0],
        'a_content': announcementsData.last[1],
        'is_admin': announcementsData.last[2],
      };
      await db.collection('announcements').add(newAnnouncement);
      if (isAdmin) {
        await db
            .collection('classes')
            .where('c_id', whereIn: newTile)
            .get()
            .then((value) {
          for (var i in value.docs) {
            i.reference.update({
              'announcement_id':
                  FieldValue.arrayUnion([announcementsData.last[0]]),
            });
          }
        });
      } else {
        await db
            .collection('classes')
            .where('c_id', isEqualTo: classID)
            .get()
            .then((value) {
          for (var i in value.docs) {
            i.reference.update({
              'announcement_id':
                  FieldValue.arrayUnion([announcementsData.last[0]]),
            });
          }
        });
      }
      setState(() {
        announcementsData;
        classesData;
      });
    }
  }

  Future<void> _onEditAnnouncementPress(BuildContext context, int index) async {
    List<dynamic>? editedAnnouncement =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditAnnouncementPage(title: '-', i: index);
    }));
    if (!context.mounted) {
      return;
    }
    if (editedAnnouncement != null) {
      await db
          .collection('announcements')
          .where('a_id', isEqualTo: announcementsData[index][0])
          .get()
          .then((value) {
        for (var i in value.docs) {
          i.reference.update({
            'a_content': announcementsData[index][1],
            'is_admin': announcementsData[index][2]
          });
        }
      });
      if (isAdmin) {
        await db.collection('classes').get().then((value) {
          for (var i in value.docs) {
            if (editedAnnouncement.contains(i.data()['c_id']) &&
                !(i
                    .data()['announcement_id']
                    .contains(announcementsData[index][0]))) {
              i.reference.update({
                'announcement_id':
                    FieldValue.arrayUnion([announcementsData[index][0]])
              });
            } else if (!(editedAnnouncement.contains(i.data()['c_id'])) &&
                i
                    .data()['announcement_id']
                    .contains(announcementsData[index][0])) {
              i.reference.update({
                'announcement_id':
                    FieldValue.arrayRemove([announcementsData[index][0]])
              });
            }
          }
        });
      }
      setState(() {
        announcementsData;
        classesData;
      });
    }
  }

  dynamic chosenMonth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dashboard'),
        toolbarHeight: 45,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(children: [
          // INSERT PHOTO HERE (CROSS / CHURCH LOGO)
          const Divider(thickness: 3),
          const Padding(
            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
            child: Text('Announcements',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcementsData.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromARGB(255, 45, 87, 255),
                            Color.fromARGB(255, 99, 146, 255)
                          ],
                        ),
                      ),
                      child: Column(children: [
                        Text(announcementsData[index][1]),
                        if (isAdmin ||
                            (isClassAdmin && !(announcementsData[index][2])))
                          Padding(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _onEditAnnouncementPress(
                                            context, index);
                                      },
                                      icon: const Icon(Icons.edit_rounded)),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Confirm Delete"),
                                              content: const Text(
                                                  "Are you sure you want to delete this item?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("Delete",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  onPressed: () async {
                                                    await db
                                                        .collection('classes')
                                                        .where(
                                                            'announcement_id',
                                                            arrayContains:
                                                                announcementsData[
                                                                    index][0])
                                                        .get()
                                                        .then((value) {
                                                      for (var i
                                                          in value.docs) {
                                                        i.reference.update({
                                                          'announcement_id':
                                                              FieldValue
                                                                  .arrayRemove([
                                                            announcementsData[
                                                                index][0]
                                                          ]),
                                                        });
                                                      }
                                                    });
                                                    await db
                                                        .collection(
                                                            'announcements')
                                                        .where('a_id',
                                                            isEqualTo:
                                                                announcementsData[
                                                                    index][0])
                                                        .get()
                                                        .then((value) {
                                                      for (var i
                                                          in value.docs) {
                                                        i.reference.delete();
                                                      }
                                                    });
                                                    setState(() {
                                                      for (var cl
                                                          in classesData) {
                                                        if (cl.last.contains(
                                                            announcementsData[
                                                                index][0])) {
                                                          cl.last.remove(
                                                              announcementsData[
                                                                  index][0]);
                                                        }
                                                      }
                                                      announcementsData
                                                          .removeAt(index);
                                                    });
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete_rounded)),
                                ],
                              ))
                      ])),
                ),
              );
            },
          ),
          const Divider(thickness: 3),
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              value: chosenMonth,
              hint: const Text('Select Month',
                  style: TextStyle(color: Colors.blue)),
              isExpanded: true,
              buttonStyleData: ButtonStyleData(
                width: MediaQuery.of(context).size.width * 17 / 32,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
              dropdownStyleData: DropdownStyleData(
                width: MediaQuery.of(context).size.width * 17 / 32,
                maxHeight: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[350],
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
                offset: const Offset(0, -2),
              ),
              items: months
                  .map((e) => DropdownMenuItem(
                      value: e[0],
                      alignment: Alignment.center,
                      child: Text(e[1],
                          style: const TextStyle(color: Colors.black))))
                  .toList(),
              onChanged: (selectedMonth) {
                setState(() {
                  chosenMonth = selectedMonth;
                  lstBirthdays = studentsData
                      .where((e) => e[3].substring(3, 5) == chosenMonth)
                      .map((e) => e)
                      .toList();
                });
              },
              style: const TextStyle(color: Colors.black),
              alignment: Alignment.center,
            ),
          ),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: lstBirthdays.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                      onPressed: () async {
                        lstMembers = [
                          studentsData
                              .firstWhere((e) => e[0] == lstBirthdays[index][0])
                        ];
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ViewStudentPage(title: '-', sIndex: 0);
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 80),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.black)),
                          elevation: 5),
                      child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            const Icon(Icons.cake_rounded,
                                color: Color.fromARGB(255, 130, 5, 59)),
                            Expanded(
                                child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lstBirthdays[index][2],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    '${lstBirthdays[index][3]} - ${lstBirthdays[index][5]}',
                                    style: const TextStyle(color: Colors.grey))
                              ],
                            ))
                          ]))),
                );
              })
        ]),
      )),
      floatingActionButton: (isAdmin || isClassAdmin)
          ? FloatingActionButton(
              onPressed: () {
                _onAddAnnouncementPress(context);
              },
              tooltip: 'Add Announcement',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class FamiliesPage extends StatefulWidget {
  const FamiliesPage({super.key, required this.title});
  final String title;
  @override
  State<FamiliesPage> createState() => _FamiliesPageState();
}

class _FamiliesPageState extends State<FamiliesPage> {
  @override
  void initState() {
    lstMembers = [];
    super.initState();
  }

  Future<void> _onAddFamilyPress(BuildContext context) async {
    int? newTile =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddFamilyPage(title: '-');
    }));
    if (!context.mounted) {
      return;
    }
    if (newTile != null) {
      var newFamily = <String, dynamic>{
        'f_id': familiesData.last[0],
        'f_name': familiesData.last[1],
        'f_address': familiesData.last[2],
        'address_link': familiesData.last[3],
      };
      await db.collection('families').add(newFamily);
      setState(() {
        familiesData;
      });
    }
  }

  Future<void> _onEditFamilyPress(BuildContext context, int index) async {
    int? editedTile =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditFamilyPage(title: '-', i: index);
    }));
    if (!context.mounted) {
      return;
    }
    if (editedTile != null) {
      int x = familiesData[index][0];
      await db
          .collection('families')
          .where('f_id', isEqualTo: x)
          .get()
          .then((value) {
        for (var i in value.docs) {
          i.reference.update({
            'f_id': x,
            'f_name': familiesData[index][1],
            'f_address': familiesData[index][2],
            'address_link': familiesData[index][3],
          });
        }
      });
      setState(() {
        familiesData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Families'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: ListView.builder(
            itemCount: familiesData.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    lstMembers = studentsData
                        .where((e) => e[7] == familiesData[index][0])
                        .toList();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return StudentsPage(title: '-', i: index);
                    }));
                  },
                  child: ListTile(
                    leading: const Icon(
                      Icons.group_rounded,
                      color: Color.fromARGB(255, 50, 205, 50),
                    ),
                    title: Text(familiesData[index][1]),
                    subtitle: Text(familiesData[index][2],
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: isAdmin
                        ? SizedBox(
                            width: 70,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: IconButton(
                                      onPressed: () {
                                        _onEditFamilyPress(context, index);
                                      },
                                      icon: const Icon(Icons.edit_rounded)),
                                ),
                                Expanded(
                                  child: IconButton(
                                      onPressed: () async {
                                        List<int> studentsInFamily = [];
                                        await db
                                            .collection('students')
                                            .where('family_id',
                                                isEqualTo: familiesData[index]
                                                    [0])
                                            .get()
                                            .then((value) {
                                          for (var i in value.docs) {
                                            studentsInFamily
                                                .add(i.data()['s_id']);
                                            i.reference.delete();
                                          }
                                        });
                                        await db
                                            .collection('meetings')
                                            .where('student_id',
                                                whereIn: studentsInFamily)
                                            .where('is_family',
                                                isEqualTo: false)
                                            .get()
                                            .then((value) {
                                          for (var i in value.docs) {
                                            i.reference.delete();
                                          }
                                        });
                                        await db
                                            .collection('meetings')
                                            .where('student_id',
                                                isEqualTo: familiesData[index]
                                                    [0])
                                            .where('is_family', isEqualTo: true)
                                            .get()
                                            .then((value) {
                                          for (var i in value.docs) {
                                            i.reference.delete();
                                          }
                                        });
                                        await db
                                            .collection('families')
                                            .where('f_id',
                                                isEqualTo: familiesData[index]
                                                    [0])
                                            .get()
                                            .then((value) {
                                          for (var i in value.docs) {
                                            i.reference.delete();
                                          }
                                        });
                                        setState(() {
                                          meetingsData.removeWhere((element) =>
                                              (studentsInFamily
                                                      .contains(element[1]) &&
                                                  !(element[7])));
                                          meetingsData.removeWhere((element) =>
                                              ((element[1] ==
                                                      familiesData[index][0]) &&
                                                  element[7]));
                                          studentsData.removeWhere((element) =>
                                              studentsInFamily
                                                  .contains(element[0]));
                                          familiesData.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.delete_rounded)),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ));
            }),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                _onAddFamilyPress(context);
              },
              tooltip: 'Add Family',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key, required this.title, required this.i});
  final String title;
  final int i;
  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  bool isValid = false;

  @override
  void initState() {
    super.initState();
    checkUrlValidity(familiesData[widget.i][3]);
  }

  Future<void> checkUrlValidity(String url) async {
    final Uri uri = Uri.tryParse(url) ?? Uri();
    if ((uri.scheme == 'http' || uri.scheme == 'https') &&
        await canLaunchUrl(uri)) {
      setState(() {
        isValid = true;
      });
    }
  }

  void openUrl() async {
    if (isValid) {
      final Uri uri = Uri.parse(familiesData[widget.i][3]);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _onAddStudentPress(BuildContext context, int famID) async {
    int? newTile =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddStudentPage(title: '-', i: famID);
    }));
    if (!context.mounted) {
      return;
    }
    if (newTile != null) {
      var newStudent = <String, dynamic>{
        's_id': studentsData.last[0],
        'class_id': studentsData.last[1],
        'full_name': studentsData.last[2],
        'dob': studentsData.last[3],
        'gender': studentsData.last[4],
        'phone_num': studentsData.last[5],
        'conf_fr': studentsData.last[6],
        'family_id': studentsData.last[7],
        'fr_church': studentsData.last[8],
        'job': studentsData.last[9],
        'member_type': studentsData.last[10],
      };
      await db.collection('students').add(newStudent);
      setState(() {
        studentsData;
      });
    }
  }

  Future<void> _onEditStudentPress(BuildContext context, int index) async {
    int? editedIndex =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditStudentPage(title: '-', i: index);
    }));
    if (!context.mounted) {
      return;
    }
    if (editedIndex != null) {
      int x = studentsData[editedIndex][0];
      await db
          .collection('students')
          .where('s_id', isEqualTo: x)
          .get()
          .then((value) {
        for (var i in value.docs) {
          i.reference.update({
            's_id': studentsData[editedIndex][0],
            'class_id': studentsData[editedIndex][1],
            'full_name': studentsData[editedIndex][2],
            'dob': studentsData[editedIndex][3],
            'gender': studentsData[editedIndex][4],
            'phone_num': studentsData[editedIndex][5],
            'conf_fr': studentsData[editedIndex][6],
            'father_id': studentsData[editedIndex][7],
            'fr_church': studentsData[editedIndex][8],
            'job': studentsData[editedIndex][9],
            'member_type': studentsData[editedIndex][10],
          });
        }
      });
      setState(() {
        studentsData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Family Details'),
        toolbarHeight: 45,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 152, 155, 148),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text('Family Name:  ',
                        style: TextStyle(color: Colors.blue, fontSize: 16)),
                    Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text('${familiesData[widget.i][1]}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16))))
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 152, 155, 148),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text('Address:  ',
                        style: TextStyle(color: Colors.blue, fontSize: 16)),
                    Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text('${familiesData[widget.i][2]}',
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16))))
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
            child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 152, 155, 148),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Text('Address Link:  ',
                        style: TextStyle(color: Colors.blue, fontSize: 16)),
                    Expanded(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: GestureDetector(
                                onTap: isValid ? openUrl : null,
                                child: Text('${familiesData[widget.i][3]}',
                                    style: TextStyle(
                                      color: isValid
                                          ? const Color.fromARGB(
                                              255, 58, 29, 108)
                                          : Colors.black,
                                      fontSize: 16,
                                      decoration: isValid
                                          ? TextDecoration.underline
                                          : TextDecoration.none,
                                    )))))
                  ],
                )),
          ),
          const SizedBox(height: 22),
          Expanded(
            child: ListView.builder(
                itemCount: lstMembers.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ViewStudentPage(title: '-', sIndex: index);
                        }));
                      },
                      child: ListTile(
                        leading: const Icon(
                          Icons.school_rounded,
                          color: Color.fromARGB(255, 50, 205, 50),
                        ),
                        title: Text(lstMembers[index][2]),
                        subtitle: Text(
                            '${lstMembers[index].last} - ${lstMembers[index][5]}'),
                        trailing: (isAdmin ||
                                (isClassAdmin &&
                                    (lstMembers[index][1] == classID)))
                            ? SizedBox(
                                width: 70,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                          onPressed: () {
                                            _onEditStudentPress(context, index);
                                          },
                                          icon: const Icon(Icons.edit_rounded)),
                                    ),
                                    Expanded(
                                      child: IconButton(
                                          onPressed: () async {
                                            await db
                                                .collection('students')
                                                .where('s_id',
                                                    isEqualTo: lstMembers[index]
                                                        [0])
                                                .get()
                                                .then((value) {
                                              for (var i in value.docs) {
                                                i.reference.delete();
                                              }
                                            });
                                            await db
                                                .collection('meetings')
                                                .where('student_id',
                                                    isEqualTo: lstMembers[index]
                                                        [0])
                                                .where('is_family',
                                                    isEqualTo: false)
                                                .get()
                                                .then((value) {
                                              for (var i in value.docs) {
                                                i.reference.delete();
                                              }
                                            });
                                            setState(() {
                                              meetingsData.removeWhere(
                                                  (element) => (element[1] ==
                                                          lstMembers[index]
                                                              [0] &&
                                                      !(element[7])));
                                              studentsData.removeWhere(
                                                  (element) =>
                                                      element[0] ==
                                                      lstMembers[index][0]);
                                              lstMembers.removeAt(index);
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.delete_rounded)),
                                    ),
                                  ],
                                ),
                              )
                            : null,
                      ));
                }),
          )
        ]),
      ),
      floatingActionButton: (isAdmin || isClassAdmin)
          ? FloatingActionButton(
              onPressed: () {
                _onAddStudentPress(context, familiesData[widget.i][0]);
              },
              tooltip: 'Add Student',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class MeetingsPage extends StatefulWidget {
  const MeetingsPage({super.key, required this.title});
  final String title;
  @override
  State<MeetingsPage> createState() => _MeetingsPageState();
}

class _MeetingsPageState extends State<MeetingsPage> {
  @override
  void initState() {
    lstMeetings = [];
    super.initState();
  }

  Future<void> _onAddMeetingPress(BuildContext context) async {
    int? newMeeting =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddMeetingPage(title: '-', fid: chosenFamily, sid: chosenStudent);
    }));
    if (!context.mounted) {
      return;
    }
    if (newMeeting != null) {
      var addToDatabase = <String, dynamic>{
        'm_id': meetingsData.last[0],
        'student_id': meetingsData.last[1],
        'm_date': meetingsData.last[2],
        'm_comments': meetingsData.last[3],
        'm_fr': meetingsData.last[4],
        'man_can_edit': meetingsData.last[5],
        'ser_can_edit': meetingsData.last[6],
        'is_family': meetingsData.last[7],
        'teacher_id': meetingsData.last[8],
      };
      await db.collection('meetings').add(addToDatabase);
      setState(() {
        meetingsData;
        lstMeetings;
      });
    }
  }

  Future<void> _onEditMeetingPress(BuildContext context, int index) async {
    int? editedMeeting =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditMeetingPage(title: '-', i: index);
    }));
    if (!context.mounted) {
      return;
    }
    if (editedMeeting != null) {
      await db
          .collection('meetings')
          .where('m_id', isEqualTo: meetingsData[editedMeeting][0])
          .get()
          .then((value) {
        for (var i in value.docs) {
          i.reference.update({
            'm_id': meetingsData[editedMeeting][0],
            'student_id': meetingsData[editedMeeting][1],
            'm_date': meetingsData[editedMeeting][2],
            'm_comments': meetingsData[editedMeeting][3],
            'm_fr': meetingsData[editedMeeting][4],
            'man_can_edit': meetingsData[editedMeeting][5],
            'ser_can_edit': meetingsData[editedMeeting][6],
            'is_family': meetingsData[editedMeeting][7],
            'teacher_id': meetingsData[editedMeeting][8],
          });
        }
      });
      setState(() {
        meetingsData;
        lstMeetings;
      });
    }
  }

  dynamic chosenFamily;
  dynamic chosenStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Meetings'),
        toolbarHeight: 45,
      ),
      body: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  value: chosenFamily,
                  hint: const Text('Select Family',
                      style: TextStyle(color: Colors.blue)),
                  isExpanded: true,
                  buttonStyleData: ButtonStyleData(
                    width: MediaQuery.of(context).size.width * 17 / 32,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
                  dropdownStyleData: DropdownStyleData(
                    width: MediaQuery.of(context).size.width * 17 / 32,
                    maxHeight: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    offset: const Offset(0, -2),
                  ),
                  items: familiesData
                      .map((e) => DropdownMenuItem(
                          value: e[0],
                          alignment: Alignment.center,
                          child: Text(e[1],
                              style: const TextStyle(color: Colors.black))))
                      .toList(),
                  onChanged: (selectedFamily) {
                    setState(() {
                      chosenFamily = selectedFamily;
                      chosenStudent = null;
                      lstMeetings = meetingsData
                          .where((e) => ((e[1] == chosenFamily) && e[7]))
                          .toList();
                      lstMeetings.sort((a, b) => b[2].compareTo(a[2]));
                    });
                  },
                  style: const TextStyle(color: Colors.black),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 5),
              DropdownButtonHideUnderline(
                child: DropdownButton2(
                  value: chosenStudent,
                  hint: const Text('Select Member',
                      style: TextStyle(color: Colors.blue)),
                  isExpanded: true,
                  buttonStyleData: ButtonStyleData(
                    width: MediaQuery.of(context).size.width * 17 / 32,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  iconStyleData: const IconStyleData(icon: SizedBox.shrink()),
                  dropdownStyleData: DropdownStyleData(
                    width: MediaQuery.of(context).size.width * 17 / 32,
                    maxHeight: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    offset: const Offset(0, -2),
                  ),
                  items: chosenFamily == null
                      ? []
                      : (isClassAdmin
                          ? studentsData
                              .where((ele) =>
                                  (ele[1] == classID) &&
                                  (ele[7] == chosenFamily))
                              .map((e) => DropdownMenuItem(
                                  value: e[0],
                                  alignment: Alignment.center,
                                  child: Text(e[2],
                                      style: const TextStyle(
                                          color: Colors.black))))
                              .toList()
                          : studentsData
                              .where((ele) => ele[7] == chosenFamily)
                              .map((e) => DropdownMenuItem(
                                  value: e[0],
                                  alignment: Alignment.center,
                                  child: Text(e[2],
                                      style: const TextStyle(
                                          color: Colors.black))))
                              .toList()),
                  onChanged: (selectedStudent) {
                    setState(() {
                      chosenStudent = selectedStudent;
                      lstMeetings = meetingsData
                          .where((e) => ((e[1] == chosenStudent) && !(e[7])))
                          .toList();
                      lstMeetings.sort((a, b) => b[2].compareTo(a[2]));
                    });
                  },
                  style: const TextStyle(color: Colors.black),
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 22),
              Expanded(
                  child: ListView.builder(
                      itemCount: lstMeetings.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                              onPressed: () async {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ViewMeetingPage(
                                      title: '-', mIndex: index);
                                }));
                              },
                              style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 80),
                                  backgroundColor: DateFormat("dd/MM/yyyy")
                                          .parse(lstMeetings[index][2])
                                          .isAfter(DateTime.now())
                                      ? const Color.fromARGB(255, 255, 246, 75)
                                      : const Color.fromARGB(255, 33, 33, 33),
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: const BorderSide(
                                          color: Colors.black)),
                                  elevation: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(lstMeetings[index][2],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(lstMeetings[index][3],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Colors.grey))
                                    ],
                                  )),
                                  if (isAdmin ||
                                      (isClassAdmin && lstMeetings[index][5]) ||
                                      (!isAdmin &&
                                          !isClassAdmin &&
                                          lstMeetings[index][6])) ...[
                                    IconButton(
                                        onPressed: () {
                                          _onEditMeetingPress(context, index);
                                        },
                                        icon: const Icon(Icons.edit_rounded,
                                            color: Colors.blue)),
                                    IconButton(
                                        onPressed: () async {
                                          meetingsData.removeWhere((element) =>
                                              element == lstMeetings[index]);
                                          await db
                                              .collection('meetings')
                                              .where('m_id',
                                                  isEqualTo: lstMeetings[index]
                                                      [0])
                                              .get()
                                              .then((value) {
                                            for (var i in value.docs) {
                                              i.reference.delete();
                                            }
                                          });
                                          setState(() {
                                            lstMeetings.removeAt(index);
                                          });
                                        },
                                        icon: const Icon(Icons.delete_rounded,
                                            color: Colors.red)),
                                  ],
                                ],
                              )),
                        );
                      }))
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onAddMeetingPress(context);
        },
        tooltip: 'Add Meeting',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});
  final String title;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void _onlogoutpress() {
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
      return const LoginPage(title: '-');
    }), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profile'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: const Color.fromARGB(255, 84, 255, 106),
                  side: const BorderSide(color: Colors.black),
                ),
                child:
                    const Text('LOGOUT', style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  SharedPreferences homePref =
                      await SharedPreferences.getInstance();
                  await homePref.setInt('classID', -1);
                  await homePref.setInt('classAdmin', 0);
                  isAdmin = false;
                  isClassAdmin = false;
                  _onlogoutpress();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Selection {
  int? selClassID;
  String? clName;
  Selection(this.selClassID, this.clName);
}

class AddAnnouncementPage extends StatefulWidget {
  const AddAnnouncementPage({super.key, required this.title});
  final String title;
  @override
  State<AddAnnouncementPage> createState() => _AddAnnouncementPageState();
}

class _AddAnnouncementPageState extends State<AddAnnouncementPage> {
  TextEditingController newAnnouncementController = TextEditingController();
  String newAnnouncement = '';
  List<dynamic> selectedClasses = [];
  bool? selectedAccessType;
  List<DropdownMenuItem> accessType = [
    const DropdownMenuItem(
        value: false,
        child: Text('Editable by class admin',
            style: TextStyle(color: Colors.black))),
    const DropdownMenuItem(
        value: true,
        child: Text('View only', style: TextStyle(color: Colors.black))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Announcement'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Announcement',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Announcement',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: newAnnouncementController,
                ),
              ),
              if (isAdmin) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: CustomDropdown.multiSelectSearch(
                    items: classesData
                        .map((e) => Selection(int.parse(e[0]), e[1]))
                        .toList(),
                    hintText: 'Select Classes',
                    onListChanged: (List<dynamic>? val) {
                      setState(() {
                        selectedClasses = [];
                        for (var x in val!) {
                          selectedClasses.add(x.selClassID);
                        }
                        if (selectedClasses.length > 1) {
                          accessType = [
                            const DropdownMenuItem(
                                value: true,
                                child: Text('View Only',
                                    style: TextStyle(color: Colors.black))),
                          ];
                          selectedAccessType = true;
                        } else {
                          accessType = [
                            const DropdownMenuItem(
                                value: false,
                                child: Text('Editable by class admin',
                                    style: TextStyle(color: Colors.black))),
                            const DropdownMenuItem(
                                value: true,
                                child: Text('View Only',
                                    style: TextStyle(color: Colors.black))),
                          ];
                          selectedAccessType = null;
                        }
                      });
                    },
                  ),
                ),
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Class Access Level',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: selectedAccessType,
                          items: accessType,
                          onChanged: (dynamic accessChosen) {
                            setState(() {
                              selectedAccessType = accessChosen!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    newAnnouncement = newAnnouncementController.text;
                    if (newAnnouncement != '') {
                      int lastIndex = -1;
                      await db
                          .collection('announcements')
                          .orderBy('a_id', descending: true)
                          .limit(1)
                          .get()
                          .then((collec) {
                        for (var i in collec.docs) {
                          lastIndex = i.data()['a_id'];
                          break;
                        }
                      });
                      if (isAdmin &&
                          selectedClasses.isNotEmpty &&
                          selectedAccessType != null) {
                        announcementsData.add([
                          lastIndex + 1,
                          newAnnouncement,
                          selectedAccessType
                        ]);
                        for (var x in classesData) {
                          if (selectedClasses.contains(x[0])) {
                            x.last.add(lastIndex + 1);
                          }
                        }
                        setState(() {
                          announcementsData;
                          classesData;
                        });
                        Navigator.pop(context, selectedClasses);
                      } else if (!isAdmin) {
                        announcementsData
                            .add([lastIndex + 1, newAnnouncement, false]);
                        classesData
                            .firstWhere((cl) => cl[0] == classID)
                            .last
                            .add(lastIndex + 1);
                        setState(() {
                          announcementsData;
                          classesData;
                        });
                        Navigator.pop(context, selectedClasses);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key, required this.title});
  final String title;
  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  TextEditingController familyNameController = TextEditingController();
  String familyName = '';
  TextEditingController addressController = TextEditingController();
  String address = '';
  TextEditingController addressLinkController = TextEditingController();
  String addressLink = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Family'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Family Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Family Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: familyNameController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Address',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: addressController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Address Link',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Link',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: addressLinkController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    familyName = familyNameController.text;
                    address = addressController.text;
                    addressLink = addressLinkController.text;
                    if (familyName != '' &&
                        address != '' &&
                        addressLink != '') {
                      int lastIndex = -1;
                      await db
                          .collection('families')
                          .orderBy('f_id', descending: true)
                          .limit(1)
                          .get()
                          .then((collec) {
                        for (var i in collec.docs) {
                          lastIndex = i.data()['f_id'];
                          break;
                        }
                      });
                      setState(() {
                        familiesData.add(
                            [lastIndex + 1, familyName, address, addressLink]);
                      });
                      Navigator.pop(context, 0);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key, required this.title, required this.i});
  final String title;
  final int i;
  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  TextEditingController studentNameController = TextEditingController();
  String studentName = '';
  TextEditingController studentNumController = TextEditingController();
  String studentNum = '';
  TextEditingController confessionFrController = TextEditingController();
  String confessionFr = '';
  TextEditingController frChurchController = TextEditingController();
  String frChurch = '';
  TextEditingController studentDoBController = TextEditingController();
  String studentDoB = '';
  TextEditingController jobController = TextEditingController();
  String job = '';
  String? studentGender;
  String? memType;
  String? studentClassID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add New Student'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Full Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: studentNameController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Number',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Phone Number',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: studentNumController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Father of Confession',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Fr. Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: confessionFrController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Father\'s Church',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Church Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: frChurchController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Select Date',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  readOnly: true,
                  controller: studentDoBController,
                  onTap: () async {
                    DateTime? chosenDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (chosenDate != null) {
                      setState(() {
                        studentDoBController.text =
                            DateFormat('dd/MM/yyyy').format(chosenDate);
                        studentDoB = studentDoBController.text;
                      });
                    }
                  },
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Gender',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: studentGender,
                        items: const [
                          DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female',
                                  style: TextStyle(color: Colors.black))),
                        ],
                        onChanged: (String? genderChosen) {
                          setState(() {
                            studentGender = genderChosen!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Job',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Job',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: jobController,
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Member Type',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: memType,
                        items: const [
                          DropdownMenuItem(
                              value: 'Father',
                              child: Text('Father',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Mother',
                              child: Text('Mother',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Son',
                              child: Text('Son',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Daughter',
                              child: Text('Daughter',
                                  style: TextStyle(color: Colors.black))),
                        ],
                        onChanged: (String? chosenType) {
                          setState(() {
                            memType = chosenType!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (isAdmin)
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Class ID',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: studentClassID,
                          items: classesData
                              .map((e) => DropdownMenuItem(
                                  value: '${e[0]}',
                                  child: Text(e[1],
                                      style: const TextStyle(
                                          color: Colors.black))))
                              .toList(),
                          onChanged: (String? chosenClassID) {
                            setState(() {
                              studentClassID = chosenClassID!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    studentName = studentNameController.text;
                    studentNum = studentNumController.text;
                    confessionFr = confessionFrController.text;
                    frChurch = frChurchController.text;
                    job = jobController.text;
                    if (studentName != '' &&
                        studentNum != '' &&
                        confessionFr != '' &&
                        frChurch != '' &&
                        memType != null &&
                        job != '' &&
                        studentDoB != '' &&
                        studentGender != null) {
                      int lastIndex = -1;
                      await db
                          .collection('students')
                          .orderBy('s_id', descending: true)
                          .limit(1)
                          .get()
                          .then((collec) {
                        for (var i in collec.docs) {
                          lastIndex = i.data()['s_id'];
                          break;
                        }
                      });
                      if (isAdmin && studentClassID != null) {
                        studentsData.add([
                          lastIndex + 1,
                          int.parse(studentClassID!),
                          studentName,
                          studentDoB,
                          studentGender,
                          int.parse(studentNum),
                          confessionFr,
                          widget.i,
                          frChurch,
                          job,
                          memType
                        ]);
                        lstMembers.add(studentsData.last);
                        setState(() {
                          studentsData;
                          lstMembers;
                        });
                        Navigator.pop(context, 0);
                      } else if (!isAdmin) {
                        studentsData.add([
                          lastIndex + 1,
                          classID,
                          studentName,
                          studentDoB,
                          studentGender,
                          int.parse(studentNum),
                          confessionFr,
                          widget.i,
                          frChurch,
                          job,
                          memType
                        ]);
                        lstMembers.add(studentsData.last);
                        setState(() {
                          studentsData;
                          lstMembers;
                        });
                        Navigator.pop(context, 0);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddMeetingPage extends StatefulWidget {
  const AddMeetingPage(
      {super.key, required this.title, required this.fid, required this.sid});
  final String title;
  final dynamic fid;
  final dynamic sid;
  @override
  State<AddMeetingPage> createState() => _AddMeetingPageState();
}

class _AddMeetingPageState extends State<AddMeetingPage> {
  @override
  void initState() {
    if (widget.fid != null) {
      famID = '${widget.fid}';
    }
    if (widget.sid != null) {
      studentID = '${widget.sid}';
    }
    super.initState();
  }

  String? famID;
  String? studentID;
  TextEditingController meetingFrController = TextEditingController();
  String meetingFr = '';
  TextEditingController meetingCommentsController = TextEditingController();
  String meetingComments = '';
  TextEditingController meetingDateController = TextEditingController();
  String meetingDate = '';
  bool? manAccessType;
  bool? serAccessType;
  List<DropdownMenuItem> accessType = [
    const DropdownMenuItem(
        value: false,
        child: Text('Editable', style: TextStyle(color: Colors.black))),
    const DropdownMenuItem(
        value: true,
        child: Text('View only', style: TextStyle(color: Colors.black))),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Meeting'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Family Name',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: famID,
                        items: familiesData
                            .map((e) => DropdownMenuItem(
                                value: '${e[0]}',
                                child: Text(e[1],
                                    style:
                                        const TextStyle(color: Colors.black))))
                            .toList(),
                        onChanged: (String? chosenFam) {
                          setState(() {
                            famID = chosenFam!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Student Name',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: studentID,
                        items: (famID == null)
                            ? null
                            : (isClassAdmin
                                ? studentsData
                                    .where((element) =>
                                        (element[1] == classID) &&
                                        (element[7] == int.parse(famID!)))
                                    .map((e) => DropdownMenuItem(
                                        value: '${e[0]}',
                                        child: Text(e[2],
                                            style: const TextStyle(
                                                color: Colors.black))))
                                    .toList()
                                : studentsData
                                    .where((element) =>
                                        element[7] == int.parse(famID!))
                                    .map((e) => DropdownMenuItem(
                                        value: '${e[0]}',
                                        child: Text(e[2],
                                            style: const TextStyle(
                                                color: Colors.black))))
                                    .toList()),
                        onChanged: (String? chosenStudent) {
                          setState(() {
                            studentID = chosenStudent!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Meeting Date',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Select Date',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  readOnly: true,
                  controller: meetingDateController,
                  onTap: () async {
                    DateTime? chosenDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2030),
                    );
                    if (chosenDate != null) {
                      setState(() {
                        meetingDateController.text =
                            DateFormat('dd/MM/yyyy').format(chosenDate);
                        meetingDate = meetingDateController.text;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Father Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Fr. Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: meetingFrController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Meeting Comments',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Comments',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: meetingCommentsController,
                ),
              ),
              if (isAdmin)
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Class Manager Access',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: manAccessType,
                          items: accessType,
                          onChanged: (dynamic accessChosen) {
                            setState(() {
                              manAccessType = accessChosen!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              if (isAdmin || isClassAdmin)
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Teacher Access',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: serAccessType,
                          items: accessType,
                          onChanged: (dynamic accessChosen) {
                            setState(() {
                              serAccessType = accessChosen!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    meetingFr = meetingFrController.text;
                    meetingComments = meetingCommentsController.text;
                    if (meetingFr != '' &&
                        meetingComments != '' &&
                        meetingDate != '' &&
                        famID != null) {
                      int lastIndex = -1;
                      await db
                          .collection('meetings')
                          .orderBy('m_id', descending: true)
                          .limit(1)
                          .get()
                          .then((collec) {
                        for (var i in collec.docs) {
                          lastIndex = i.data()['m_id'];
                          break;
                        }
                      });
                      setState(() {
                        bool manEdit, serEdit, isFam;
                        manEdit = serEdit = isFam = false;
                        if (studentID != null) {
                          if (isAdmin) {
                            if (manAccessType != null &&
                                serAccessType != null) {
                              manEdit = !(manAccessType!);
                              serEdit = !(serAccessType!);
                              meetingsData.add([
                                lastIndex + 1,
                                int.parse(studentID!),
                                meetingDate,
                                meetingComments,
                                meetingFr,
                                manEdit,
                                serEdit,
                                isFam,
                                [1]
                              ]);
                              if ((widget.sid != null) &&
                                  (widget.sid == int.parse(studentID!))) {
                                lstMeetings.add(meetingsData.last);
                              }
                              Navigator.pop(context, 0);
                            }
                          } else if (isClassAdmin) {
                            if (serAccessType != null) {
                              manEdit = true;
                              serEdit = !(serAccessType!);
                              meetingsData.add([
                                lastIndex + 1,
                                int.parse(studentID!),
                                meetingDate,
                                meetingComments,
                                meetingFr,
                                manEdit,
                                serEdit,
                                isFam,
                                [1]
                              ]);
                              if ((widget.sid != null) &&
                                  (widget.sid == int.parse(studentID!))) {
                                lstMeetings.add(meetingsData.last);
                              }
                              Navigator.pop(context, 0);
                            }
                          } else {
                            manEdit = true;
                            serEdit = true;
                            meetingsData.add([
                              lastIndex + 1,
                              int.parse(studentID!),
                              meetingDate,
                              meetingComments,
                              meetingFr,
                              manEdit,
                              serEdit,
                              isFam,
                              [1]
                            ]);
                            if ((widget.sid != null) &&
                                (widget.sid == int.parse(studentID!))) {
                              lstMeetings.add(meetingsData.last);
                            }
                            Navigator.pop(context, 0);
                          }
                        } else {
                          isFam = true;
                          if (isAdmin) {
                            if (manAccessType != null) {
                              manEdit = !(manAccessType!);
                              serEdit = false;
                              meetingsData.add([
                                lastIndex + 1,
                                int.parse(famID!),
                                meetingDate,
                                meetingComments,
                                meetingFr,
                                manEdit,
                                serEdit,
                                isFam,
                                [1]
                              ]);
                              if ((widget.fid != null) &&
                                  (widget.sid == null) &&
                                  (widget.fid == int.parse(famID!))) {
                                lstMeetings.add(meetingsData.last);
                              }
                              Navigator.pop(context, 0);
                            }
                          } else if (isClassAdmin) {
                            manEdit = true;
                            serEdit = false;
                            meetingsData.add([
                              lastIndex + 1,
                              int.parse(famID!),
                              meetingDate,
                              meetingComments,
                              meetingFr,
                              manEdit,
                              serEdit,
                              isFam,
                              [1]
                            ]);
                            if ((widget.fid != null) &&
                                (widget.sid == null) &&
                                (widget.fid == int.parse(famID!))) {
                              lstMeetings.add(meetingsData.last);
                            }
                            Navigator.pop(context, 0);
                          }
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditAnnouncementPage extends StatefulWidget {
  const EditAnnouncementPage({super.key, required this.title, required this.i});
  final String title;
  final int i;
  @override
  State<EditAnnouncementPage> createState() => _EditAnnouncementPageState();
}

class _EditAnnouncementPageState extends State<EditAnnouncementPage> {
  @override
  void initState() {
    editedAnnouncementController.text = announcementsData[widget.i][1];
    editedAnnouncement = editedAnnouncementController.text;
    editedAccessType = announcementsData[widget.i][2];
    for (var x in classesData) {
      if (x.last.contains(announcementsData[widget.i][0])) {
        selectedClasses.add(Selection(x[0], x[1]));
      }
    }
    super.initState();
  }

  TextEditingController editedAnnouncementController = TextEditingController();
  String editedAnnouncement = '';
  List<dynamic> selectedClasses = [];
  bool? editedAccessType;
  List<DropdownMenuItem> accessType = [
    const DropdownMenuItem(
        value: false,
        child: Text('Editable by class admin',
            style: TextStyle(color: Colors.black))),
    const DropdownMenuItem(
        value: true,
        child: Text('View only', style: TextStyle(color: Colors.black))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Announcement'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  maxLines: 20,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Announcement Content',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Announcement',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedAnnouncementController,
                ),
              ),
              if (isAdmin) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: CustomDropdown.multiSelectSearch(
                    items: classesData
                        .map((e) => Selection(
                              int.parse(e[0]),
                              e[1],
                            ))
                        .toList(),
                    initialItems: selectedClasses,
                    hintText: 'Select Classes',
                    onListChanged: (List<dynamic>? val) {
                      setState(() {
                        selectedClasses = [];
                        for (var x in val!) {
                          selectedClasses.add(x.selClassID);
                        }
                        if (selectedClasses.length > 1) {
                          accessType = [
                            const DropdownMenuItem(
                                value: true,
                                child: Text('View Only',
                                    style: TextStyle(color: Colors.black))),
                          ];
                          editedAccessType = true;
                        } else {
                          accessType = [
                            const DropdownMenuItem(
                                value: false,
                                child: Text('Editable by class admin',
                                    style: TextStyle(color: Colors.black))),
                            const DropdownMenuItem(
                                value: true,
                                child: Text('View Only',
                                    style: TextStyle(color: Colors.black))),
                          ];
                          editedAccessType = null;
                        }
                      });
                    },
                  ),
                ),
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Class Access Level',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: editedAccessType,
                          items: accessType,
                          onChanged: (dynamic accessChosen) {
                            setState(() {
                              editedAccessType = accessChosen!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    editedAnnouncement = editedAnnouncementController.text;
                    if (editedAnnouncement != '') {
                      if (isAdmin &&
                          selectedClasses.isNotEmpty &&
                          editedAccessType != null) {
                        announcementsData[widget.i][1] = editedAnnouncement;
                        for (var x in classesData) {
                          if (x.last.contains(announcementsData[widget.i][0]) &&
                              !(selectedClasses.contains(x[0]))) {
                            x.last.remove(announcementsData[widget.i][0]);
                          } else if (!(x.last
                                  .contains(announcementsData[widget.i][0])) &&
                              selectedClasses.contains(x[0])) {
                            x.last.add(announcementsData[widget.i][0]);
                          }
                        }
                        announcementsData[widget.i][2] = editedAccessType;
                        setState(() {
                          announcementsData;
                          classesData;
                        });
                        Navigator.pop(context, selectedClasses);
                      } else if (!isAdmin) {
                        announcementsData[widget.i][1] = editedAnnouncement;
                        setState(() {
                          announcementsData;
                          classesData;
                        });
                        Navigator.pop(context, selectedClasses);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditFamilyPage extends StatefulWidget {
  const EditFamilyPage({super.key, required this.title, required this.i});
  final String title;
  final int i;
  @override
  State<EditFamilyPage> createState() => _EditFamilyPageState();
}

class _EditFamilyPageState extends State<EditFamilyPage> {
  @override
  void initState() {
    editedFamilyNameController.text = familiesData[widget.i][1];
    editedFamilyName = editedFamilyNameController.text;
    editedAddressController.text = familiesData[widget.i][2];
    editedAddress = editedAddressController.text;
    editedAddressLinkController.text = familiesData[widget.i][3];
    editedAddressLink = editedAddressLinkController.text;
    super.initState();
  }

  TextEditingController editedFamilyNameController = TextEditingController();
  String editedFamilyName = '';
  TextEditingController editedAddressController = TextEditingController();
  String editedAddress = '';
  TextEditingController editedAddressLinkController = TextEditingController();
  String editedAddressLink = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Family Data'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Family Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedFamilyNameController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Address',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Address',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedAddressController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Address Link',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Link',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedAddressLinkController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    editedFamilyName = editedFamilyNameController.text;
                    editedAddress = editedAddressController.text;
                    editedAddressLink = editedAddressLinkController.text;
                    if (editedFamilyName != '' &&
                        editedAddress != '' &&
                        editedAddressLink != '') {
                      familiesData[widget.i] = [
                        familiesData[widget.i][0],
                        editedFamilyName,
                        editedAddress,
                        editedAddressLink
                      ];
                      Navigator.pop(context, 0);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditStudentPage extends StatefulWidget {
  const EditStudentPage({super.key, required this.title, required this.i});
  final String title;
  final int i;
  @override
  State<EditStudentPage> createState() => _EditStudentPageState();
}

class _EditStudentPageState extends State<EditStudentPage> {
  @override
  void initState() {
    editedClassID = lstMembers[widget.i][1].toString();
    editedStudentNameController.text = lstMembers[widget.i][2];
    editedStudentName = editedStudentNameController.text;
    editedStudentDoBController.text = lstMembers[widget.i][3];
    editedStudentDoB = editedStudentDoBController.text;
    editedStudentGender = lstMembers[widget.i][4];
    editedStudentNumController.text = lstMembers[widget.i][5].toString();
    editedStudentNum = editedStudentNumController.text;
    editedConfessionFrController.text = lstMembers[widget.i][6];
    editedConfessionFr = editedConfessionFrController.text;
    editedFamID = lstMembers[widget.i][7].toString();
    editedFrChurchController.text = lstMembers[widget.i][8];
    editedFrChurch = editedFrChurchController.text;
    editedJobController.text = lstMembers[widget.i][9];
    editedJob = editedJobController.text;
    editedMemType = lstMembers[widget.i][10];
    super.initState();
  }

  String? editedClassID;
  TextEditingController editedStudentNameController = TextEditingController();
  String editedStudentName = '';
  TextEditingController editedStudentDoBController = TextEditingController();
  String editedStudentDoB = '';
  String? editedStudentGender;
  TextEditingController editedStudentNumController = TextEditingController();
  String editedStudentNum = '';
  TextEditingController editedConfessionFrController = TextEditingController();
  String editedConfessionFr = '';
  String? editedFamID;
  TextEditingController editedFrChurchController = TextEditingController();
  String editedFrChurch = '';
  TextEditingController editedJobController = TextEditingController();
  String editedJob = '';
  String? editedMemType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Student Data'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Student Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedStudentNameController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Number',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Phone Number',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedStudentNumController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Father of Confession',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Fr. Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedConfessionFrController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Father\'s Church',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Church Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedFrChurchController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Select Date',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  readOnly: true,
                  controller: editedStudentDoBController,
                  onTap: () async {
                    DateTime? chosenDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (chosenDate != null) {
                      setState(() {
                        editedStudentDoBController.text =
                            DateFormat('dd/MM/yyyy').format(chosenDate);
                        editedStudentDoB = editedStudentDoBController.text;
                      });
                    }
                  },
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Gender',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: editedStudentGender,
                        items: const [
                          DropdownMenuItem(
                              value: 'Male',
                              child: Text('Male',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Female',
                              child: Text('Female',
                                  style: TextStyle(color: Colors.black))),
                        ],
                        onChanged: (String? chosenGender) {
                          setState(() {
                            editedStudentGender = chosenGender!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Job',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Job',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedJobController,
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Member Type',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: editedMemType,
                        items: const [
                          DropdownMenuItem(
                              value: 'Father',
                              child: Text('Father',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Mother',
                              child: Text('Mother',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Son',
                              child: Text('Son',
                                  style: TextStyle(color: Colors.black))),
                          DropdownMenuItem(
                              value: 'Daughter',
                              child: Text('Daughter',
                                  style: TextStyle(color: Colors.black))),
                        ],
                        onChanged: (String? chosenType) {
                          setState(() {
                            editedMemType = chosenType!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (isAdmin) ...[
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Family ID',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: editedFamID,
                          items: familiesData
                              .map((e) => DropdownMenuItem(
                                  value: '${e[0]}',
                                  child: Text(e[1],
                                      style: const TextStyle(
                                          color: Colors.black))))
                              .toList(),
                          onChanged: (String? chosenFamID) {
                            setState(() {
                              editedFamID = chosenFamID!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 93.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 152, 155, 148),
                          ),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text(
                            'Class ID',
                            style: TextStyle(color: Colors.blue),
                          ),
                          value: editedClassID,
                          items: classesData
                              .map((e) => DropdownMenuItem(
                                  value: '${e[0]}',
                                  child: Text(e[1],
                                      style: const TextStyle(
                                          color: Colors.black))))
                              .toList(),
                          onChanged: (String? chosenClassID) {
                            setState(() {
                              editedClassID = chosenClassID!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    editedStudentName = editedStudentNameController.text;
                    editedStudentNum = editedStudentNumController.text;
                    editedConfessionFr = editedConfessionFrController.text;
                    editedFrChurch = editedFrChurchController.text;
                    editedJob = editedJobController.text;
                    if (editedStudentName != '' &&
                        editedStudentNum != '' &&
                        editedConfessionFr != '' &&
                        editedFrChurch != '' &&
                        editedMemType != null &&
                        editedJob != '' &&
                        editedStudentDoB != '' &&
                        editedStudentGender != null) {
                      int x = studentsData.indexWhere(
                          (element) => element[0] == lstMembers[widget.i][0]);
                      if (isAdmin &&
                          editedClassID != null &&
                          editedFamID != null) {
                        if (lstMembers[widget.i][1] !=
                            int.parse(editedClassID!)) {
                          studentsData[x][1] = int.parse(editedClassID!);
                        }
                        if (lstMembers[widget.i][7] !=
                            int.parse(editedFamID!)) {
                          studentsData[x][7] = int.parse(editedFamID!);
                          lstMembers.removeAt(widget.i);
                        }
                        studentsData[x] = [
                          studentsData[x][0],
                          studentsData[x][1],
                          editedStudentName,
                          editedStudentDoB,
                          editedStudentGender,
                          int.parse(editedStudentNum),
                          editedConfessionFr,
                          studentsData[x][7],
                          editedFrChurch,
                          editedJob,
                          editedMemType
                        ];
                        Navigator.pop(context, x);
                      } else if (!isAdmin) {
                        studentsData[x] = [
                          studentsData[x][0],
                          studentsData[x][1],
                          editedStudentName,
                          editedStudentDoB,
                          editedStudentGender,
                          int.parse(editedStudentNum),
                          editedConfessionFr,
                          studentsData[x][7],
                          editedFrChurch,
                          editedJob,
                          editedMemType
                        ];
                        Navigator.pop(context, x);
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditMeetingPage extends StatefulWidget {
  const EditMeetingPage({super.key, required this.title, required this.i});
  final String title;
  final int i;
  @override
  State<EditMeetingPage> createState() => _EditMeetingPageState();
}

class _EditMeetingPageState extends State<EditMeetingPage> {
  @override
  void initState() {
    if (lstMeetings[widget.i][7]) {
      editedStudentID = null;
      editedTempFamID = lstMeetings[widget.i][1].toString();
    } else {
      editedStudentID = lstMeetings[widget.i][1].toString();
      editedTempFamID = studentsData
          .firstWhere((e) => e[0] == int.parse(editedStudentID!))[7]
          .toString();
    }
    editedMeetingDateController.text = lstMeetings[widget.i][2];
    editedMeetingDate = editedMeetingDateController.text;
    editedMeetingCommentController.text = lstMeetings[widget.i][3];
    editedMeetingComment = editedMeetingCommentController.text;
    editedMeetingFrController.text = lstMeetings[widget.i][4];
    editedMeetingFr = editedMeetingFrController.text;
    super.initState();
  }

  String? editedTempFamID;
  String? editedStudentID;
  TextEditingController editedMeetingDateController = TextEditingController();
  String editedMeetingDate = '';
  TextEditingController editedMeetingCommentController =
      TextEditingController();
  String editedMeetingComment = '';
  TextEditingController editedMeetingFrController = TextEditingController();
  String editedMeetingFr = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Edit Visit'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Meeting Date',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Select Date',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  readOnly: true,
                  controller: editedMeetingDateController,
                  onTap: () async {
                    DateTime? chosenDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (chosenDate != null) {
                      setState(() {
                        editedMeetingDateController.text =
                            DateFormat('dd/MM/yyyy').format(chosenDate);
                        editedMeetingDate = editedMeetingDateController.text;
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Father Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Fr. Name',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedMeetingFrController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Meeting Comments',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Comments',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: editedMeetingCommentController,
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Family ID',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: editedTempFamID,
                        items: familiesData
                            .map((e) => DropdownMenuItem(
                                value: '${e[0]}',
                                child: Text(e[1],
                                    style:
                                        const TextStyle(color: Colors.black))))
                            .toList(),
                        onChanged: (String? chosenTempFamID) {
                          setState(() {
                            editedTempFamID = chosenTempFamID!;
                            editedStudentID = null;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 93.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 152, 155, 148),
                        ),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        isExpanded: true,
                        hint: const Text(
                          'Student ID',
                          style: TextStyle(color: Colors.blue),
                        ),
                        value: editedStudentID,
                        items: studentsData
                            .where((s) => s[7] == int.parse(editedTempFamID!))
                            .map((e) => DropdownMenuItem(
                                value: '${e[0]}',
                                child: Text(e[2],
                                    style:
                                        const TextStyle(color: Colors.black))))
                            .toList(),
                        onChanged: (String? chosenStudentID) {
                          setState(() {
                            editedStudentID = chosenStudentID!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    editedMeetingFr = editedMeetingFrController.text;
                    editedMeetingComment = editedMeetingCommentController.text;
                    if (editedMeetingFr != '' &&
                        editedMeetingComment != '' &&
                        editedMeetingDate != '') {
                      setState(() {
                        int x = meetingsData.indexWhere((element) =>
                            element[0] == lstMeetings[widget.i][0]);
                        if (editedTempFamID != null) {
                          if (editedStudentID != null) {
                            meetingsData[x] = [
                              meetingsData[x][0],
                              int.parse(editedStudentID!),
                              editedMeetingDate,
                              editedMeetingComment,
                              editedMeetingFr,
                              meetingsData[x][5],
                              meetingsData[x][6],
                              false,
                              meetingsData[x][8]
                            ];
                            if (!(lstMeetings[widget.i][7]) &&
                                (lstMeetings[widget.i][1] ==
                                    int.parse(editedStudentID!))) {
                              lstMeetings[widget.i] = [
                                lstMeetings[widget.i][0],
                                lstMeetings[widget.i][1],
                                editedMeetingDate,
                                editedMeetingComment,
                                editedMeetingFr,
                                lstMeetings[widget.i][5],
                                lstMeetings[widget.i][6],
                                lstMeetings[widget.i][7],
                                lstMeetings[widget.i][8]
                              ];
                            } else {
                              lstMeetings.removeAt(widget.i);
                            }
                            Navigator.pop(context, x);
                          } else {
                            if (isAdmin || isClassAdmin) {
                              meetingsData[x] = [
                                meetingsData[x][0],
                                int.parse(editedTempFamID!),
                                editedMeetingDate,
                                editedMeetingComment,
                                editedMeetingFr,
                                meetingsData[x][5],
                                meetingsData[x][6],
                                true,
                                meetingsData[x][8]
                              ];
                              if (lstMeetings[widget.i][7] &&
                                  (lstMeetings[widget.i][1] ==
                                      int.parse(editedTempFamID!))) {
                                lstMeetings[widget.i] = [
                                  lstMeetings[widget.i][0],
                                  lstMeetings[widget.i][1],
                                  editedMeetingDate,
                                  editedMeetingComment,
                                  editedMeetingFr,
                                  lstMeetings[widget.i][5],
                                  lstMeetings[widget.i][6],
                                  lstMeetings[widget.i][7],
                                  lstMeetings[widget.i][8]
                                ];
                              } else {
                                lstMeetings.removeAt(widget.i);
                              }
                              Navigator.pop(context, x);
                            }
                          }
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewStudentPage extends StatefulWidget {
  const ViewStudentPage({super.key, required this.title, required this.sIndex});
  final String title;
  final int sIndex;
  @override
  State<ViewStudentPage> createState() => _ViewStudentPageState();
}

class _ViewStudentPageState extends State<ViewStudentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Student Details'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Name:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][2]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Gender:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][4]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Date of Birth:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][3]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Number:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][5]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Confession Father:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][6]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Confession Fr Church:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][8]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Job:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][9]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Member Type:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMembers[widget.sIndex][10]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewMeetingPage extends StatefulWidget {
  const ViewMeetingPage({super.key, required this.title, required this.mIndex});
  final String title;
  final int mIndex;
  @override
  State<ViewMeetingPage> createState() => _ViewMeetingPageState();
}

class _ViewMeetingPageState extends State<ViewMeetingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Meeting Details'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Meeting Date:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMeetings[widget.mIndex][2]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Text('Father Name:  ',
                            style: TextStyle(color: Colors.blue, fontSize: 16)),
                        Expanded(
                            child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text('${lstMeetings[widget.mIndex][4]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                    height: MediaQuery.sizeOf(context).height * 7 / 16,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 152, 155, 148),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Meeting Comments:',
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16)),
                            ],
                          ),
                        ),
                        Expanded(
                            child: SingleChildScrollView(
                                child: Text('${lstMeetings[widget.mIndex][3]}',
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16))))
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyAppLandingPage extends StatelessWidget {
  const MyAppLandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Church App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 84, 255, 106)),
        useMaterial3: true,
      ),
      home: const LoginPage(title: 'Dashboard'),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});
  final String title;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  String username = '';
  TextEditingController passwordController = TextEditingController();
  String password = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login'),
        toolbarHeight: 45,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Username',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: usernameController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: TextField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 152, 155, 148),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Colors.blue,
                      ),
                    ),
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.blue),
                    hintText: 'Enter Password',
                    hintStyle: TextStyle(color: Colors.blue),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  controller: passwordController,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.black),
                  ),
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    username = usernameController.text;
                    password = passwordController.text;
                    if (username != '' && password != '') {
                      int validLogin = -1;
                      for (var i in classesData) {
                        if (i[2] == username && i[3] == password) {
                          validLogin = i[0];
                          isClassAdmin = true;
                          break;
                        } else if (i[2] == username && i[4] == password) {
                          validLogin = i[0];
                          break;
                        }
                      }
                      if (username == 'admin' && password == 'admin') {
                        validLogin = -2;
                        isAdmin = true;
                      }
                      if (validLogin != -1) {
                        classID = validLogin;
                        SharedPreferences storedClass =
                            await SharedPreferences.getInstance();
                        await storedClass.setInt('classID', classID);
                        await storedClass.setInt(
                            'classAdmin', isClassAdmin ? 1 : 0);
                        await _readData();
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return const MainPage(title: '-');
                        }));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
