import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({super.key});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  ValueNotifier<String> userSelectedDates = ValueNotifier("");

  ElevatedButton button({required String title}) => ElevatedButton(
      onPressed: () async {
        userSelectedDates.value = await Navigator.push(
            context, CupertinoPageRoute(builder: (_) => const AlertForm()));
      },
      child: Text(title));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder(
          valueListenable: userSelectedDates,
          builder: (_, selectedText, __) {
            if (selectedText.isNotEmpty) {
              return SizedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Hi Joes You are available in $selectedText",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    button(title: "Edit Schedule")
                  ],
                ),
              );
            } else {
              return Center(
                child: button(title: "Add Schedule"),
              );
            }
          }),
    );
  }
}

class AlertForm extends StatefulWidget {
  const AlertForm({super.key});

  @override
  State<AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends State<AlertForm>
    {
  List<Map<String, String>> weekDays = [
    {"Sunday": ""},
    {"Monday": ""},
    {"Tuesday": ""},
    {"Wednesday": ""},
    {"Thursday": ""},
    {"Friday": ""},
    {"Saturday": ""},
  ];

  String calculateDayHoursAndAdjustString(List<String> hours) {
    if (hours.length == 1) {
      return hours.first;
    } else if (hours.length == 2) {
      return hours.join(" and ");
    } else if (hours.length == 3) {
      return "Whole day";
    }
    return "";
  }

  String checkAvailableDates() {
    List<String> tempList = [];
    for (int i = 0; i < weekDays.length; i++) {
      var value = weekDays[i].entries.first.value;
      var key = weekDays[i].entries.first.key;
      if (value.isNotEmpty) {
        var tepString = "$key $value";
        tempList.add(tepString);
      }
    }
    return joinListWithAnd(tempList);
  }

  String joinListWithAnd(List<String> items) {
    if (items.isEmpty) {
      return "";
    } else if (items.length == 1) {
      return items[0];
    } else {
      String joined = items.sublist(0, items.length - 1).join(", ");
      return "$joined and ${items.last}";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, "");
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const Text(
                    'Set your weekly hours',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ListView.builder(
                    itemCount: weekDays.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      String key = weekDays[index].entries.first.key;
                      return DaySelectorWidget(
                        day: key,
                        callBack: (Map<String, String> selectedMap) {
                          List<String> dates = [];
                          selectedMap.entries.map((e) {
                            if (e.value.isNotEmpty) {
                              dates.add(e.value);
                            }
                          }).toList(growable: false);

                          weekDays[index].update(
                              key,
                                  (value) =>
                                  calculateDayHoursAndAdjustString(dates),
                              ifAbsent: () => "");
                        },
                      );
                    },
                  ),
                ],
              )),
        ),
        bottomNavigationBar: InkWell(
          onTap: () {
            var text = checkAvailableDates();
            Navigator.pop(context, text);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                    child: Text(
                      'SAVE',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}

class DaySelectorWidget extends StatefulWidget {
  final String day;
  final Function(Map<String, String>) callBack;
  const DaySelectorWidget({
    super.key,
    required this.day,
    required this.callBack,
  });

  @override
  State<DaySelectorWidget> createState() => _DaySelectorWidgetState();
}

class _DaySelectorWidgetState extends State<DaySelectorWidget>
    with AutomaticKeepAliveClientMixin {
  ValueNotifier<bool> isDaySelected = ValueNotifier(false);
  List<String> weeklyHours = ["Morning", "Afternoon", "Evening"];
  ValueNotifier<Map<String, String>> daySelectedMap = ValueNotifier({
    "Morning": "",
    "Afternoon": "",
    "Evening": "",
  });
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: 70,
      width: size.width,
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder(
                    valueListenable: isDaySelected,
                    builder: (context, selected, _) {
                      return InkWell(
                        onTap: () {
                          isDaySelected.value = !isDaySelected.value;
                          if (!isDaySelected.value) {
                            daySelectedMap.value.clear();
                            widget.callBack({});
                          }
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Icon(Icons.check_circle,
                            color: selected ? Colors.green : Colors.grey,
                            size: 30),
                      );
                    }),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    widget.day.substring(0, 3).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ValueListenableBuilder(
                      valueListenable: isDaySelected,
                      builder: (context, selected, _) {
                        return !selected
                            ? const Text(
                          "Unavailable",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        )
                            : ValueListenableBuilder(
                            valueListenable: daySelectedMap,
                            builder: (_, map, __) {
                              return ListView.builder(
                                  itemCount: weeklyHours.length,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (_, index) {
                                    String value =
                                        map[weeklyHours[index]] ?? "";
                                    return SizedBox(
                                      height: 30,
                                      child: Container(
                                          margin:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                              border: Border.all(
                                                  color: value ==
                                                      weeklyHours[index]
                                                      ? Colors.indigoAccent
                                                      : Colors.grey)),
                                          child: InkWell(
                                            onTap: () {
                                              if (value.isNotEmpty) {
                                                daySelectedMap.value.update(
                                                    weeklyHours[index],
                                                        (value) => "",
                                                    ifAbsent: () => "");
                                              } else {
                                                daySelectedMap.value.update(
                                                    weeklyHours[index],
                                                        (value) =>
                                                    weeklyHours[index],
                                                    ifAbsent: () =>
                                                    weeklyHours[index]);
                                              }
                                              // print(daySelectedMap.value);
                                              daySelectedMap.notifyListeners();
                                              widget.callBack(
                                                  daySelectedMap.value);
                                            },
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              child: Center(
                                                  child: Text(
                                                    weeklyHours[index],
                                                    style: TextStyle(
                                                        color: value ==
                                                            weeklyHours[
                                                            index]
                                                            ? Colors
                                                            .indigoAccent
                                                            : Colors.grey),
                                                  )),
                                            ),
                                          )),
                                    );
                                  });
                            });
                      }),
                ),
              ],
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}