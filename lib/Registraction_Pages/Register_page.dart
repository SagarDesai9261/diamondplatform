import 'package:diamondplatform/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'Company_Registraction.dart';
import 'Employee_regitraction.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  bool _isEmployee = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Registration") ?? "Registration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEmployee ? Colors.black : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmployee = true;
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.translate('Employee') ?? "Employee"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isEmployee ? Colors.black : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEmployee = false;
                      });
                    },
                    child: Text(AppLocalizations.of(context)!.translate('Company') ?? "Company"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _isEmployee
                  ? EmployeeForm(
                      isEmployee: _isEmployee,
                    )
                  : CompanyForm(
                      isEmployee: _isEmployee,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
