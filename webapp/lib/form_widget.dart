import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:weddingform/Models/authentication_state.dart';
import 'package:weddingform/Models/authentication_type.dart';
import 'dart:convert';

import 'package:weddingform/Services/http_service.dart';

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
  bool showSubmissionError = false;
  bool formSentSuccessfully = false;

  // Add submission state variable
  bool isSubmitting = false;

  final _nameController = TextEditingController();
  final _cakeFlavorController = TextEditingController();
  final _topicController = TextEditingController();
  final _contactInfoController = TextEditingController();
  final _notesController = TextEditingController();

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
  static const String doYouBringCakeText = 'Bringst du einen Kuchen mit?';
  static const String noText = 'Nein';
  static const String yesText = 'Ja';
  static const String doYouHaveContributionText =
      'Möchtest du uns am Abend mit einem Beitrag bereichern?';
  static const String topicLabel = 'Thema oder Beschreibung';

  static const String needProjectorText = 'Brauchst du einen Projektor?';
  static const String needMusicText = 'Spielst du Musik ab?';
  static const String whatDoYouWantToEatText = 'Was möchtet ihr essen?';
  static const String selectZeroText =
      'Wähle \'0\', wenn du keine Mahlzeit möchtest.';

  // meal
  static const String starterOption1Text = 'Schwäbische Hochzeitssuppe';
  static const String starterOption2Text = 'Bunter Beilagensalat (vegan)';

  static const String mainOption1Text = 'Rinderschmorbraten';
  static const String mainOption2Text =
      'Hähnchenbrust unter der Kräuterkruste mit Grillgemüse und Gnocchi';
  static const String mainOption3Text =
      'Gebackene Falafel mit Humus, Granatapfelkernen und Rosmarinkartoffeln (vegan)';

  static const String dessertOption1Text = 'Crème brûlée';
  static const String dessertOption2Text = 'Mousse au Chocolat (vegan)';

  // Extracted constants
  static const String headerHinweis = 'Hinweis:';
  static const String dataPrivacyNotice =
      'Deine Angaben werden ausschließlich zum Organisieren unserer Hochzeit verwendet und gespeichert. Ausgewählte Personen, die uns beim Organisieren helfen, erhalten eine Kopie der Angaben. Deine Daten werden nicht an Dritte weitergegeben. Deine Angaben werden per Mail versendet.';
  static const String submitButtonText = 'Absenden';
  static const String nameLabel = 'Wie lautet dein Name?';
  static const String contactInfoLabel =
      'Kontaktmöglichkeit (vorzugsweise E-Mail)';
  static const String imNotComingText = 'Ich komme nicht';
  static const String imComingText = 'Ich komme';
  static const String whoIsComingLabel = 'Wer kommt mit inkl dir?';
  static const String cakeLabel = 'Welchen Kuchen bringst du mit?';
  static const String specifyCakeError =
      'Bitte gib an, welchen Kuchen du mitbringst.';
  static const String specifyContributionError =
      'Bitte gib das Thema oder eine Beschreibung deines Beitrags an.';
  static const String nameErrorText = 'Bitte gib deinen Namen an.';
  static const String contactInfoErrorText =
      'Bitte gib eine Kontaktmöglichkeit an.';
  static const String whoComingErrorText = 'Bitte gib an, wer mitkommt.';
  static const String peopleErrorText = 'Bitte gib an, zu wievielt ihr kommt.';
  static const String submissionErrorText =
      'Fehler beim Absenden des Formulars. Bitte versuche es erneut.';

  Future<void> _launchMailClient(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    try {
      await launchUrlString(emailUri.toString());
    } catch (e) {
      print('Error launching mail client: $e');
      await Clipboard.setData(ClipboardData(text: emailUri.toString()));
    }
  }

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
      String whoComingText = _whoComingController.text.trim();
      bool whoIsComingValid = whoComingText.isNotEmpty;

      bool cakeValid = true;
      if (isBringingCake) {
        String cakeText = _cakeFlavorController.text.trim();
        cakeValid = cakeText.isNotEmpty && cakeText.length > 3;
      }

      bool mealValid = true;
      if (widget.authenticationState.authenticationType ==
          AuthenticationType.attendingFestivities) {
        mealValid = (_startersOption1Controller.text.trim().isNotEmpty &&
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
      }

      bool contributionValid = true;
      if (hasContribution) {
        String contributionText = _topicController.text.trim();
        contributionValid =
            contributionText.isNotEmpty && contributionText.length > 3;
      }

      setState(() {
        showWhoComingError = !whoIsComingValid;
        showMealError = !mealValid;
        showContributionError = !contributionValid;
        showCakeError = !cakeValid;
      });

      foundError = foundError ||
          !mealValid ||
          !cakeValid ||
          !contributionValid ||
          !whoIsComingValid;
    }
    return !foundError;
  }

  void _submitForm() async {
    if (_isFormValid()) {
      setState(() {
        isSubmitting = true;
      });
      final formData = {
        "name": _nameController.text,
        "isComing": isComing,
        "whoIsComing": _whoComingController.text,
        "contactInformation": _contactInfoController.text,
        "doYouHaveContribution": hasContribution,
        "topic": _topicController.text,
        "needProjector": needProjector,
        "needMusic": needMusic,
        "doYouBringCake": isBringingCake,
        "cakeFlavor": _cakeFlavorController.text,
        "startersOption1": _startersOption1Controller.text,
        "startersOption2": _startersOption2Controller.text,
        "mainOption1": _mainOption1Controller.text,
        "mainOption2": _mainOption2Controller.text,
        "mainOption3": _mainOption3Controller.text,
        "dessertOption1": _dessertOption1Controller.text,
        "dessertOption2": _dessertOption2Controller.text,
        "notes": _notesController.text,
      };

      final username = widget.authenticationState.username;
      final password = widget.authenticationState.password;

      final credentials = base64Encode(utf8.encode('$username:$password'));

      final body = json.encode(formData);

      final response = await HttpService.sendForm(credentials, body);

      if (response.statusCode == 200) {
        setState(() {
          showSubmissionError = false;
          formSentSuccessfully = true;
        });
      } else {
        setState(() {
          showSubmissionError = true;
        });
      }

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return formSentSuccessfully
        ? Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.green),
                SizedBox(width: 8),
                Text(
                    "Formular erfolgreich gesendet! Du kannst die Seite jetzt schließen."),
              ],
            ),
          )
        : SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      headerHinweis,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  // Update data privacy notice to regular font weight
                  Text(
                    dataPrivacyNotice,
                    style: TextStyle(fontWeight: FontWeight.normal),
                  ),
                  // Insert a divider
                  Divider(),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: nameLabel),
                  ),
                  if (showNameError)
                    Text(
                      nameErrorText,
                      style: TextStyle(color: Colors.red),
                    ),
                  TextField(
                    controller: _contactInfoController,
                    decoration:
                        const InputDecoration(labelText: contactInfoLabel),
                  ),
                  if (showContactInfoError)
                    Text(
                      contactInfoErrorText,
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
                              onChanged: (val) =>
                                  setState(() => isComing = val!),
                            ),
                            const Text(imNotComingText),
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
                              onChanged: (val) =>
                                  setState(() => isComing = val!),
                            ),
                            const Text(imComingText),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  if (isComing) ...[
                    // Add the new TextField below
                    TextField(
                      controller: _whoComingController,
                      decoration:
                          const InputDecoration(labelText: whoIsComingLabel),
                    ),
                    if (showWhoComingError)
                      Text(
                        whoComingErrorText,
                        style: TextStyle(color: Colors.red),
                      ),
                    if (showPeopleError)
                      Text(
                        peopleErrorText,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        doYouBringCakeText,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Text(
                            'Bei Fragen bitte an Lea Burret wenden.',
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () => _launchMailClient(
                                widget.authenticationState.emailCoffee),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.open_in_new, size: 16),
                        ],
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
                        decoration: const InputDecoration(labelText: cakeLabel),
                      ),
                      if (showCakeError)
                        Text(
                          specifyCakeError,
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                    if (widget.authenticationState.authenticationType ==
                        AuthenticationType.attendingFestivities) ...[
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          doYouHaveContributionText,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              'Bei Fragen bitte an Michael Simbürger wenden.',
                            ),
                            SizedBox(width: 8),
                            InkWell(
                              onTap: () => _launchMailClient(
                                  widget.authenticationState.emailContribution),
                              child: Text(
                                'Email',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.open_in_new, size: 16),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () =>
                                setState(() => hasContribution = false),
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
                          decoration:
                              const InputDecoration(labelText: topicLabel),
                        ),
                        if (showContributionError)
                          Text(
                            specifyContributionError,
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
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
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
                          'Vorspeisen',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
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
                              decoration: InputDecoration(labelText: 'Menge'),
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
                              decoration: InputDecoration(labelText: 'Menge'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Main Course Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hauptgerichte',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
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
                              decoration: InputDecoration(labelText: 'Menge'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
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
                              decoration: InputDecoration(labelText: 'Menge'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
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
                              decoration: InputDecoration(labelText: 'Menge'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Dessert Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Desserts',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
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
                              decoration: InputDecoration(labelText: 'Menge'),
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
                              decoration: InputDecoration(labelText: 'Menge'),
                            ),
                          ),
                        ],
                      ),
                      if (showMealError)
                        Text(
                          'Bitte wähle Deine Essensoptionen aus. Wenn Du kein Essen möchtest, trage bitte eine 0 ein.',
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
                    SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Möchtest du uns noch etwas mitteilen?',
                      ),
                    ),
                  ],
                  SizedBox(height: 32),
                  isSubmitting
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          child: const Text(submitButtonText),
                        ),
                  if (showSubmissionError)
                    Text(
                      submissionErrorText,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}
