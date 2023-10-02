import 'package:diamondplatform/model/model.dart';
import 'package:flutter/material.dart';

class Employee_view extends StatefulWidget {
  JobPost? jobPost;
  Employee_view({Key? key,this.jobPost}) : super(key: key);

  @override
  State<Employee_view> createState() => _Employee_viewState();
}

class _Employee_viewState extends State<Employee_view> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee views"),
      ),
      body:  SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: FittedBox(
          child: DataTable(columns: [
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
            for (int i = 0; i < widget.jobPost!.employeeView!.length; i++) ...[
              // Set the values to the columns
              DataRow(cells: [
                DataCell(Text(
                    "${widget.jobPost!.employeeView![i]["name"].toString()}")),
                DataCell(InkWell(
                  onTap: (){
                 //   _showPhoneCallConfirmationDialog(widget.jobPost.employeeView![i]["mobileNumber"]);
                    //   _launchPhoneCall(widget.jobPost.mobileCount![i]["mobileNumber"]);
                  },
                  child: Text(
                      "${widget.jobPost!.employeeView![i]["mobileNumber"].toString()}"),
                )),
                DataCell(Flexible(
                    child: Text(
                        "${widget.jobPost!.employeeView![i]["currentDateAndTime"].toString()}"))),
              ]),
            ]
          ]),
        ),
      ),

    );
  }
}
