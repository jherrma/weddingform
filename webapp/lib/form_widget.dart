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
  bool showWhoComingError = false;
  bool showContactInfoError = false;

  final _nameController = TextEditingController();
  final _peopleController = TextEditingController();
  final _cakeFlavorController = TextEditingController();
  final _topicController = TextEditingController();
  final _contactInfoController = TextEditingController();

  final TextEditingController _startersOption1Controller =
      TextEditingController();
  final TextEditingController _startersOption2Controller =
      TextEditingController();
  final TextEditingController _mainOption1Controller = TextEditingController();
  final TextEditingController _mainOption2Controller = TextEditingController();
  final TextEditingController _mainOption3Controller = TextEditingController();
  final TextEditingController _dessertOption1Controller =
      TextEditingController();
  final TextEditingController _dessertOption2Controller =
      TextEditingController();
  final TextEditingController _whoComingController = TextEditingController();

  // Add constants for menu option texts
  static const String doYouBringCakeText = 'Do you bring a cake?';
  static const String noText = 'No';
  static const String yesText = 'Yes';
  static const String doYouHaveContributionText = 'Do you have a contribution?';
  static const String topicLabel = 'Topic';

  static const String needProjectorText = 'Need a projector';
  static const String needMusicText = 'Need music';
  static const String whatDoYouWantToEatText = 'What do you want to eat?';
  static const String selectZeroText =
      'Select \'0\' if you don\'t want a meal.';

  // meal
  static const String mainOption1Text = 'Main Option 1';
  static const String mainOption2Text = 'Main Option 2';
  static const String mainOption3Text = 'Main Option 3';
  static const String dessertOption1Text = 'Dessert Option 1';
  static const String dessertOption2Text = 'Dessert Option 2';
  static const String starterOption1Text = 'Starter Option 1';
  static const String starterOption2Text = 'Starter Option 2';

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

    if (_contactInfoController.text.trim().isEmpty) {
      setState(() {
        showContactInfoError = true;
      });
      foundError = true;
    } else {
      setState(() {
        showContactInfoError = false;
      });
    }

    if (isComing) {
      String peopleText = _peopleController.text.trim();
      int? numberOfPeople = int.tryParse(peopleText);
      bool peopleValid =
          peopleText.isNotEmpty && numberOfPeople != null && numberOfPeople > 0;

      String whoComingText = _whoComingController.text.trim();
      bool whoIsComingValid = whoComingText.isNotEmpty;

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
          (_mainOption3Controller.text.trim().isNotEmpty &&
              int.tryParse(_mainOption3Controller.text.trim()) != null &&
              int.parse(_mainOption3Controller.text.trim()) >= 0) ||
          (_dessertOption1Controller.text.trim().isNotEmpty &&
              int.tryParse(_dessertOption1Controller.text.trim()) != null &&
              int.parse(_dessertOption1Controller.text.trim()) >= 0) ||
          (_dessertOption2Controller.text.trim().isNotEmpty &&
              int.tryParse(_dessertOption2Controller.text.trim()) != null &&
              int.parse(_dessertOption2Controller.text.trim()) >= 0);

      bool cakeValid = true;
      if (isBringingCake) {
        cakeValid = _cakeFlavorController.text.trim().isNotEmpty;
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
        showWhoComingError = !whoIsComingValid;
        showMealError = !mealValid;
      });

      foundError = !peopleValid ||
          !mealValid ||
          !cakeValid ||
          !contributionValid ||
          !whoIsComingValid;
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
            TextField(
              controller: _contactInfoController,
              decoration:
                  const InputDecoration(labelText: 'Contact Information'),
            ),
            if (showContactInfoError)
              Text(
                'Please enter your contact information.',
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
              // Add the new TextField below
              TextField(
                controller: _whoComingController,
                decoration: const InputDecoration(labelText: 'Who is coming?'),
              ),
              if (showWhoComingError)
                Text(
                  'Please specify who is coming.',
                  style: TextStyle(color: Colors.red),
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
                  doYouBringCakeText,
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
                        const Text(noText),
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
                        const Text(yesText),
                      ],
                    ),
                  ),
                ],
              ),
              if (isBringingCake) ...[
                TextField(
                  controller: _cakeFlavorController,
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
                    doYouHaveContributionText,
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
                          const Text(noText),
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
                          const Text(yesText),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasContribution) ...[
                  TextField(
                    controller: _topicController,
                    decoration: const InputDecoration(labelText: topicLabel),
                  ),
                  if (showContributionError)
                    Text(
                      'Please specify the topic of your contribution.',
                      style: TextStyle(color: Colors.red),
                    ),
                  CheckboxListTile(
                    title: const Text(needProjectorText),
                    value: needProjector,
                    onChanged: (val) {
                      setState(() => needProjector = val!);
                    },
                  ),
                  CheckboxListTile(
                    title: const Text(needMusicText),
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
                    whatDoYouWantToEatText,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(selectZeroText)),
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
                      child: Text(starterOption1Text),
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
                      child: Text(starterOption2Text),
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
                      child: Text(mainOption1Text),
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
                      child: Text(mainOption2Text),
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
                Row(
                  children: [
                    Expanded(
                      child: Text(mainOption3Text),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _mainOption3Controller,
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
                      child: Text(dessertOption1Text),
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
                      child: Text(dessertOption2Text),
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
