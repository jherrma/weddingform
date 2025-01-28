import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:weddingform/Models/authentication_state.dart';
import 'package:weddingform/Models/authentication_type.dart';
import 'dart:convert';

import 'package:weddingform/Services/http_service.dart';

enum RideOption {
  public(0),
  searching(1),
  offering(2);

  final int value;
  const RideOption(this.value);
}

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
  bool showCakeError = false;
  bool showContributionError = false;
  bool showWhoComingError = false;
  bool showContactInfoError = false;
  bool showSubmissionError = false;
  bool formSentSuccessfully = false;

  // Add submission state variable
  bool isSubmitting = false;

  final _nameController = TextEditingController();
  final _peopleController = TextEditingController();
  final _cakeFlavorController = TextEditingController();
  final _topicController = TextEditingController();
  final _contactInformationController = TextEditingController();

  final TextEditingController _whoComingController = TextEditingController();

  bool showContactInformationError = false;

  // Add new controller and error state for contribution duration
  final _contributionDurationController = TextEditingController();
  bool showContributionDurationError = false;

  // Add constants for menu option texts
  static const String doYouBringCakeText = 'Ich bringe einen Kuchen mit';
  static const String cakeLabel = 'Welchen Kuchen bringst du mit?';
  static const String specifyCakeError =
      'Bitte gib an, welchen Kuchen du mitbringst.';

  static const String doYouBringSnacksText = 'Ich bringe Häppchen mit';
  static const String snacksLabel = 'Welche Häppchen bringst du mit?';
  static const String snacksErrorText =
      'Bitte gib an, welche Häppchen du mitbringst.';

  static const String noText = 'Nein';
  static const String yesText = 'Ja';
  static const String doYouHaveContributionText =
      'Möchtest du uns am Abend mit einem Beitrag bereichern?';
  static const String topicLabel = 'Thema oder Beschreibung';

  static const String needProjectorText = 'Brauchst du einen Projektor?';
  static const String needMusicText = 'Spielst du Musik ab?';

  // Extracted constants
  static const String headerHinweis = 'Hinweis:';
  static const String dataPrivacyNotice =
      'Deine Angaben werden ausschließlich zum Organisieren unserer Hochzeit verwendet und gespeichert. Ausgewählte Personen, die uns beim Organisieren helfen, erhalten eine Kopie der Angaben. Deine Daten werden nicht an Dritte weitergegeben. Deine Angaben werden per Mail versendet.';
  static const String submitButtonText = 'Absenden';
  static const String nameLabel = 'Wie lautet dein Name?';
  static const String emailLabel = 'Wie lautet deine E-Mail-Adresse?';
  static const String imNotComingText = 'Ich komme nicht';
  static const String imComingText = 'Ich komme';
  static const String numberOfPeopleText = 'Mit wie vielen Personen kommst du?';
  static const String whoIsComingLabel = 'Wer kommt mit?';

  static const String specifyContributionError =
      'Bitte gib das Thema oder eine Beschreibung deines Beitrags an.';
  static const String nameErrorText = 'Bitte gib deinen Namen an.';
  static const String contactInfoErrorText =
      'Bitte gib eine Kontaktmöglichkeit an.';
  static const String whoComingErrorText = 'Bitte gib an, wer mitkommt.';
  static const String peopleErrorText = 'Bitte gib an, zu wievielt ihr kommt.';
  static const String submissionErrorText =
      'Fehler beim Absenden des Formulars. Bitte versuche es erneut.';

  static const String phoneLabel = 'Wie lautet deine Mobilnummer?';
  static const String phoneErrorText = 'Bitte gib deine Mobilnummer an.';

  bool isBringingSnacks = false;
  final TextEditingController _snacksController = TextEditingController();
  bool showSnacksError = false;

  RideOption rideOption = RideOption.public;
  final _needRideController = TextEditingController();
  final _offerRideController = TextEditingController();
  bool showNeedRideError = false;
  bool showOfferRideError = false;

  // Add new controllers and state variables
  final _allergiesController = TextEditingController();
  bool isVegetarian = false;
  bool isVegan = false;

  // Add new controller for notes
  final _notesController = TextEditingController();

  Future<void> _launchMailClient() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'example@example.com',
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
    String name = _nameController.text.trim();
    if (name.isEmpty || name.length < 3) {
      setState(() {
        showNameError = true;
      });
      foundError = true;
    } else {
      setState(() {
        showNameError = false;
      });
    }

    if (_contactInformationController.text.trim().isEmpty) {
      setState(() {
        showContactInformationError = true;
      });
      foundError = true;
    } else {
      setState(() {
        showContactInformationError = false;
      });
    }

    if (!isComing) {
      return !foundError;
    }

    String peopleText = _peopleController.text.trim();
    int? numberOfPeople = int.tryParse(peopleText);
    bool peopleValid = numberOfPeople != null && numberOfPeople > 0;

    String whoComingText = _whoComingController.text.trim();
    bool whoIsComingValid =
        whoComingText.isNotEmpty && whoComingText.length > 3;

    foundError = !(peopleValid && whoIsComingValid);

    setState(() {
      showPeopleError = !peopleValid;
      showWhoComingError = !whoIsComingValid;
    });

    if (isBringingCake) {
      String cakeText = _cakeFlavorController.text.trim();
      if (cakeText.isNotEmpty && cakeText.length > 3) {
        setState(() {
          showCakeError = false;
        });
      } else {
        setState(() {
          showCakeError = true;
        });
        foundError = true;
      }
    }

    if (isBringingSnacks) {
      String snacks = _snacksController.text.trim();
      if (snacks.isEmpty || snacks.length < 3) {
        setState(() {
          showSnacksError = true;
        });
        foundError = true;
      } else {
        setState(() {
          showSnacksError = false;
        });
      }
    }

    if (widget.authenticationState.authenticationType !=
        AuthenticationType.attendingFestivities) {
      return !foundError;
    }

    if (hasContribution) {
      String contributionText = _topicController.text.trim();
      if (contributionText.isNotEmpty && contributionText.length > 3) {
        setState(() {
          showContributionError = false;
        });
      } else {
        setState(() {
          showContributionError = true;
        });
        foundError = true;
      }

      String durationText = _contributionDurationController.text.trim();
      int? duration = int.tryParse(durationText);
      bool durationValid = duration != null && duration > 0;

      if (!durationValid) {
        setState(() {
          showContributionDurationError = true;
        });
        foundError = true;
      } else {
        setState(() {
          showContributionDurationError = false;
        });
      }
    }

    if (rideOption == RideOption.searching) {
      String needRide = _needRideController.text.trim();
      int? needRideAmount = int.tryParse(needRide);

      if (needRideAmount == null || needRideAmount <= 0) {
        setState(() {
          showNeedRideError = true;
        });
        foundError = true;
      } else {
        setState(() {
          showNeedRideError = false;
        });
      }
    } else if (rideOption == RideOption.offering) {
      String offerRide = _offerRideController.text.trim();
      int? offerRideAmount = int.tryParse(offerRide);
      if (offerRideAmount == null || offerRideAmount <= 0) {
        setState(() {
          showOfferRideError = true;
        });
        foundError = true;
      } else {
        setState(() {
          showOfferRideError = false;
        });
      }
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
        "numberOfPeople": int.tryParse(_peopleController.text) ?? 0,
        "contactInformation": _contactInformationController.text,
        "doYouHaveContribution": hasContribution,
        "topic": _topicController.text,
        "contributionDuration":
            int.tryParse(_contributionDurationController.text) ?? 0,
        "needProjector": needProjector,
        "needMusic": needMusic,
        "doYouBringCake": isBringingCake,
        "cakeFlavor": _cakeFlavorController.text,
        "doYouBringSnacks": isBringingSnacks,
        "snacksFlavor": _snacksController.text,
        "rideOption": rideOption.value,
        "needRide": int.tryParse(_needRideController.text) ?? 0,
        "offerRide": int.tryParse(_offerRideController.text) ?? 0,
        "allergies": _allergiesController.text,
        "isVegetarian": isVegetarian,
        "isVegan": isVegan,
        "notes": _notesController.text, // Add notes field
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
                    controller: _contactInformationController,
                    decoration: const InputDecoration(
                        labelText: 'Kontaktmöglichkeit (Email oder Mobil)'),
                  ),
                  if (showContactInformationError)
                    Text(
                      'Bitte gib eine Kontaktmöglichkeit an.',
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            numberOfPeopleText,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
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
                        'Nach der Trauung',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: InkWell(
                    //     onTap: _launchMailClient,
                    //     child: Text(
                    //       'Bei Fragen bitte an Joanna Hoffert wenden',
                    //       style: TextStyle(
                    //         color: Colors.blue,
                    //         decoration: TextDecoration.underline,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    CheckboxListTile(
                      title: const Text(doYouBringCakeText),
                      value: isBringingCake,
                      onChanged: (bool? value) {
                        setState(() {
                          isBringingCake = value!;
                        });
                      },
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
                    SizedBox(height: 8),
                    CheckboxListTile(
                      title: const Text(doYouBringSnacksText),
                      value: isBringingSnacks,
                      onChanged: (bool? value) {
                        setState(() {
                          isBringingSnacks = value!;
                        });
                      },
                    ),
                    if (isBringingSnacks) ...[
                      TextField(
                        controller: _snacksController,
                        decoration:
                            const InputDecoration(labelText: snacksLabel),
                      ),
                      if (showSnacksError)
                        Text(
                          snacksErrorText,
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
                        TextField(
                          controller: _contributionDurationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Dauer des Beitrags in Minuten'),
                        ),
                        if (showContributionDurationError)
                          Text(
                            'Bitte gib eine gültige Dauer in Minuten an.',
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
                          'Abendessen',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _allergiesController,
                        decoration: const InputDecoration(
                            labelText: 'Unverträglichkeiten'),
                      ),
                      SizedBox(height: 8),
                      CheckboxListTile(
                        title: const Text('Ich bin vegetarisch'),
                        value: isVegetarian,
                        onChanged: (bool? value) {
                          setState(() {
                            isVegetarian = value!;
                            if (!isVegetarian && isVegan) {
                              isVegan = false;
                            }
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: const Text('Ich bin vegan'),
                        value: isVegan,
                        onChanged: (bool? value) {
                          setState(() {
                            isVegan = value!;
                            if (isVegan) {
                              isVegetarian = true;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Fahrt zur Feier',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () =>
                                setState(() => rideOption = RideOption.public),
                            child: Row(
                              children: [
                                Radio<RideOption>(
                                  value: RideOption.public,
                                  groupValue: rideOption,
                                  onChanged: (val) =>
                                      setState(() => rideOption = val!),
                                ),
                                const Text('Ich fahre öffentlich/alleine'),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(
                                () => rideOption = RideOption.searching),
                            child: Row(
                              children: [
                                Radio<RideOption>(
                                  value: RideOption.searching,
                                  groupValue: rideOption,
                                  onChanged: (val) =>
                                      setState(() => rideOption = val!),
                                ),
                                const Text('Ich suche eine Mitfahrgelegenheit'),
                              ],
                            ),
                          ),
                          if (rideOption == RideOption.searching) ...[
                            TextField(
                              controller: _needRideController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Wie viele Personen suchen?'),
                            ),
                            if (showNeedRideError)
                              const Text(
                                'Bitte eine gültige Anzahl angeben.',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                          InkWell(
                            onTap: () => setState(
                                () => rideOption = RideOption.offering),
                            child: Row(
                              children: [
                                Radio<RideOption>(
                                  value: RideOption.offering,
                                  groupValue: rideOption,
                                  onChanged: (val) =>
                                      setState(() => rideOption = val!),
                                ),
                                const Text('Ich biete eine Mitfahrgelegenheit'),
                              ],
                            ),
                          ),
                          if (rideOption == RideOption.offering) ...[
                            TextField(
                              controller: _offerRideController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText:
                                      'Für wie viele Personen hast du Platz?'),
                            ),
                            if (showOfferRideError)
                              const Text(
                                'Bitte eine gültige Anzahl angeben.',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ],
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
