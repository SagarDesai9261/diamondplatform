import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import '../model/model.dart';

class contactInfo extends StatefulWidget {
  JobPost jobPost;
  contactInfo({required this.jobPost});
  @override
  State<contactInfo> createState() => _contactInfoState();
}

class _contactInfoState extends State<contactInfo> {
  @override
  Widget build(BuildContext context) {
    var data = widget!.jobPost.mobileCount!.length <= 3
        ? widget.jobPost.mobileCount!.length
        : 3;
    return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        tileColor: Colors.black12,
        title: Column(
          children: [
            if (widget.jobPost.mobileCount!.length == 0) ...[
              Center(
                child: Text("No Call Details"),
              )
            ],
              if(widget.jobPost.mobileCount!.length != 0)...[

              DataTable(columns: [
              // Set the name of the column
              DataColumn(
                label: Text('Name'),
              ),
              DataColumn(
                label: Flexible(child: Text('M.No')),
              ),
              DataColumn(
                label: Flexible(child: Text('Date Time')),
              ),
            ], rows: [
              for (int i = 0; i < data; i++) ...[
                // Set the values to the columns
                DataRow(cells: [
                  DataCell(Text(
                      "${widget.jobPost.mobileCount![i]["name"].toString()}")),
                  DataCell(InkWell(
                    onTap: (){
                      _showPhoneCallConfirmationDialog(widget.jobPost.mobileCount![i]["mobileNumber"]);
                      //   _launchPhoneCall(widget.jobPost.mobileCount![i]["mobileNumber"]);
                    },
                    child: Text(
                        "${widget.jobPost.mobileCount![i]["mobileNumber"].toString()}"),
                  )),
                  DataCell(Flexible(
                      child: Text(
                          "${widget.jobPost.mobileCount![i]["currentDateAndTime"].toString()}"))),
                ]),
              ]
            ]),
            data>=2? Container(
              child: TextButton(onPressed: (){},child: Text("View More"),),
            ):Container()
            ]
          ],
        ));

    // print(widget.jobPost.id);
    /*return const


    ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      tileColor: Colors.black12,
      title: Column(
        children: [
          Row(
            children: [
              Text('Con.name '),
              Text('     Contact number'),
            ],
          ),
          Text('Contact Information 1'),
        ],
      ),
      // You can customize further styling or add more widgets here.
    );*/
  }
  void _launchPhoneCall(String phoneNumber) async {
    //set the number here
    bool? res = await FlutterPhoneDirectCaller.callNumber(phoneNumber);

  }
  void _showPhoneCallConfirmationDialog(String phoneNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Make Phone Call"),
          content: Text("Do you want to call +91 $phoneNumber ?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Call"),
              onPressed: () {
                //Mobile_add_count(id);
                Navigator.of(context).pop(); // Close the dialog
                _launchPhoneCall(phoneNumber);
              },
            ),
          ],
        );
      },
    );
  }
}
