import 'package:flutter/material.dart';
import 'package:weddingform/Models/authentication_state.dart';

class FormWidget extends StatefulWidget {
  final AuthenticationState authenticationState;

  const FormWidget({super.key, required this.authenticationState});

  @override
  State<FormWidget> createState() => _FormWidgetState();
}

class _FormWidgetState extends State<FormWidget> {
  bool showError = false;
  bool isComing = false;
  bool hasContribution = false;
  bool needProjector = false;
  bool needMusic = false;
  bool isBringingCake = false;
  bool showNameError = false;
  bool showPeopleError = false;
  bool showMealError = false;
  bool showCakeError = false;
  bool showContributionError = false;

  final _nameController = TextEditingController();
  final _peopleController = TextEditingController();
  final _cakeController = TextEditingController();
  final _topicController = TextEditingController();

  final TextEditingController _startersOption1Controller =
      TextEditingController();
  final TextEditingController _startersOption2Controller =
      TextEditingController();
  final TextEditingController _mainOption1Controller = TextEditingController();
  final TextEditingController _mainOption2Controller = TextEditingController();
  final TextEditingController _dessertOption1Controller =
      TextEditingController();
  final TextEditingController _dessertOption2Controller =
      TextEditingController();

  bool _isFormValid() {
    bool foundError = false;
    if (_nameController.text.trim().isEmpty ||
        _nameController.text.trim().length < 3) {
      setState(() {
        showNameError = true;
      });
      foundError = true;
    } else {
      setState(() {
        showNameError = false;
      });
    }
    if (isComing) {
      String peopleText = _peopleController.text.trim();
      bool peopleValid = peopleText.isNotEmpty && int.tryParse(peopleText)! > 0;

      // Validate meal options
      bool mealValid = (_startersOption1Controller.text.trim().isNotEmpty &&
              int.tryParse(_startersOption1Controller.text.trim()) != null &&
              int.parse(_startersOption1Controller.text.trim()) >= 0) ||
          (_startersOption2Controller.text.trim().isNotEmpty &&
              int.tryParse(_startersOption2Controller.text.trim()) != null &&
              int.parse(_startersOption2Controller.text.trim()) >= 0) ||
          (_mainOption1Controller.text.trim().isNotEmpty &&
              int.tryParse(_mainOption1Controller.text.trim()) != null &&
              int.parse(_mainOption1Controller.text.trim()) >= 0) ||
          (_mainOption2Controller.text.trim().isNotEmpty &&
              int.tryParse(_mainOption2Controller.text.trim()) != null &&
              int.parse(_mainOption2Controller.text.trim()) >= 0) ||
          (_dessertOption1Controller.text.trim().isNotEmpty &&
              int.tryParse(_dessertOption1Controller.text.trim()) != null &&
              int.parse(_dessertOption1Controller.text.trim()) >= 0) ||
          (_dessertOption2Controller.text.trim().isNotEmpty &&
              int.tryParse(_dessertOption2Controller.text.trim()) != null &&
              int.parse(_dessertOption2Controller.text.trim()) >= 0);

      // Validate cake field
      bool cakeValid = true;
      if (isBringingCake) {
        cakeValid = _cakeController.text.trim().isNotEmpty;
        if (!cakeValid) {
          setState(() {
            showCakeError = true;
          });
        } else {
          setState(() {
            showCakeError = false;
          });
        }
      } else {
        setState(() {
          showCakeError = false;
        });
      }

      // Validate contributions if selected
      bool contributionValid = true;
      if (hasContribution) {
        contributionValid = _topicController.text.trim().isNotEmpty;
        if (!contributionValid) {
          showContributionError = true;
        }
      } else {
        showContributionError = false;
      }

      setState(() {
        showPeopleError = !peopleValid;
        showMealError = !mealValid;
      });

      foundError =
          !peopleValid || !mealValid || !cakeValid || !contributionValid;
    }
    return !foundError;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration:
                  const InputDecoration(labelText: 'What\'s your name?'),
            ),
            if (showNameError)
              Text(
                'Please enter your name.',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            Column(
              children: [
                InkWell(
                  onTap: () => setState(() => isComing = false),
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: isComing,
                        onChanged: (val) => setState(() => isComing = val!),
                      ),
                      const Text('I\'m not coming'),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => isComing = true),
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: isComing,
                        onChanged: (val) => setState(() => isComing = val!),
                      ),
                      const Text('I\'m coming'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (isComing) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'With how many people are you attending?',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _peopleController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(),
                    ),
                  ),
                ],
              ),
              if (showPeopleError)
                Text(
                  'Please enter the number of people attending.',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Do you bring a cake?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => isBringingCake = false),
                    child: Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          groupValue: isBringingCake,
                          onChanged: (val) =>
                              setState(() => isBringingCake = val!),
                        ),
                        const Text('No'),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => isBringingCake = true),
                    child: Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isBringingCake,
                          onChanged: (val) =>
                              setState(() => isBringingCake = val!),
                        ),
                        const Text('Yes'),
                      ],
                    ),
                  ),
                ],
              ),
              if (isBringingCake) ...[
                TextField(
                  controller: _cakeController,
                  decoration:
                      const InputDecoration(labelText: 'Cake you bring'),
                ),
                if (showCakeError)
                  Text(
                    'Please specify the cake you are bringing.',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
              if (widget.authenticationState ==
                  AuthenticationState.attendingFestivities) ...[
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Do you have a contribution?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () => setState(() => hasContribution = false),
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: false,
                            groupValue: hasContribution,
                            onChanged: (val) =>
                                setState(() => hasContribution = val!),
                          ),
                          const Text('No'),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => hasContribution = true),
                      child: Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: hasContribution,
                            onChanged: (val) =>
                                setState(() => hasContribution = val!),
                          ),
                          const Text('Yes'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasContribution) ...[
                  TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(labelText: 'Topic'),
                  ),
                  if (showContributionError)
                    Text(
                      'Please specify the topic of your contribution.',
                      style: TextStyle(color: Colors.red),
                    ),
                  CheckboxListTile(
                    title: const Text('Need a projector'),
                    value: needProjector,
                    onChanged: (val) {
                      setState(() => needProjector = val!);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Need music'),
                    value: needMusic,
                    onChanged: (val) {
                      setState(() => needMusic = val!);
                    },
                  ),
                ],
                SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What do you want to eat?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select \'0\' if you don\'t want a meal.')),
                SizedBox(height: 8),
                // Starters Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Starters',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Starter Option 1'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _startersOption1Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Starter Option 2'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _startersOption2Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Main Course Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Main',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Main Option 1'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _mainOption1Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Main Option 2'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _mainOption2Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Dessert Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dessert',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Dessert Option 1'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _dessertOption1Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text('Dessert Option 2'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _dessertOption2Controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                  ],
                ),
                if (showMealError)
                  Text(
                    'Please select your meal options. If you don\'t want a meal, please select 0.',
                    style: TextStyle(color: Colors.red),
                  ),
              ]
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                bool isFormValid = _isFormValid();
                if (isFormValid) {
                  // Submit form
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
