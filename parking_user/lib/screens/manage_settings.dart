import 'package:cli_shared/cli_shared.dart';
import 'package:flutter/material.dart';
import 'package:parking_app_cli/parking_app_cli.dart';
import 'package:parking_user/providers/change_theme_provider.dart';
import 'package:parking_user/providers/get_person_provider.dart';
import 'package:provider/provider.dart';

enum ThemeSelected { lightTheme, darkTheme, defaultTheme }

class ManageSettings extends StatefulWidget {
  const ManageSettings({super.key});

  @override
  State<ManageSettings> createState() => _ManageSettingsState();
}

class _ManageSettingsState extends State<ManageSettings> {
  ThemeSelected? _themeSelected;
  final formKey = GlobalKey<FormState>();
  String? name;

  @override
  Widget build(BuildContext context) {
    final person = context.read<GetPerson>().person;

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Text(
              'Inställningar',
              style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inversePrimary),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Form(
                    key: formKey,
                    child: ListTile(
                      title: Text(
                        'Uppdatera namn',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                      trailing: ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(width: 120),
                        child: ElevatedButton(
                          onPressed: () => showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Uppdatera'),
                              content: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: TextFormField(
                                  initialValue: person.name,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Ange ett namn";
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Ange namn',
                                  ),
                                  onChanged: (value) => name = value,
                                  onSaved: (value) => name = value,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, 'Avbryt'),
                                  child: const Text('Avbryt'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      formKey.currentState!.save();
                                      final res = await PersonRepository
                                          .instance
                                          .updatePersons(Person(
                                              id: person.id,
                                              name: name!,
                                              socialSecurityNumber:
                                                  person.socialSecurityNumber));
                                      if (res.statusCode == 200) {
                                        if (context.mounted) {
                                          context
                                              .read<GetPerson>()
                                              .getPerson(person.id);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              backgroundColor:
                                                  Colors.lightGreen,
                                              content: Text(
                                                  'Du har uppdaterat ditt konto'),
                                            ),
                                          );
                                          setState(() {
                                            Navigator.pop(context);
                                          });
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              duration: Duration(seconds: 3),
                                              backgroundColor: Colors.redAccent,
                                              content: Text(
                                                  'Något gick fel vänligen försök igen senare'),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        }
                                      }
                                    }
                                  },
                                  child: const Text('Uppdatera'),
                                ),
                              ],
                            ),
                          ),
                          child: const Text('Uppdatera'),
                        ),
                      ),
                      tileColor: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    title: Text(
                      'Tema',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 120),
                      child: ElevatedButton(
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder:
                                  (BuildContext context, StateSetter setState) {
                                return AlertDialog(
                                  title: const Text('Tema'),
                                  content: const Text(
                                      'Ändra till det temat du föredrar'),
                                  actions: <Widget>[
                                    RadioListTile<ThemeSelected>(
                                      value: ThemeSelected.lightTheme,
                                      groupValue: _themeSelected,
                                      onChanged: (ThemeSelected? value) {
                                        final themeProvider =
                                            Provider.of<ChangeThemeProvider>(
                                                context,
                                                listen: false);
                                        setState(() {
                                          _themeSelected = value;
                                          themeProvider.changeThemeMode(0);
                                        });
                                      },
                                      title: const Text('Ljus'),
                                    ),
                                    RadioListTile<ThemeSelected>(
                                      value: ThemeSelected.darkTheme,
                                      groupValue: _themeSelected,
                                      onChanged: (ThemeSelected? value) {
                                        final themeProvider =
                                            Provider.of<ChangeThemeProvider>(
                                                context,
                                                listen: false);
                                        setState(() {
                                          _themeSelected = value;
                                          themeProvider.changeThemeMode(1);
                                        });
                                      },
                                      title: const Text('Mörk'),
                                    ),
                                    RadioListTile<ThemeSelected>(
                                      value: ThemeSelected.defaultTheme,
                                      groupValue: _themeSelected,
                                      onChanged: (ThemeSelected? value) {
                                        final themeProvider =
                                            Provider.of<ChangeThemeProvider>(
                                                context,
                                                listen: false);
                                        setState(() {
                                          _themeSelected = value;
                                          themeProvider.changeThemeMode(2);
                                        });
                                      },
                                      title: const Text('System default'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        child: const Text('Tema'),
                      ),
                    ),
                    tileColor: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 5),
                  ListTile(
                    title: Text(
                      'Logga ut',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints.tightFor(width: 120),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(context, ModalRoute.withName('/'));
                        },
                        child: const Text('Logga ut'),
                      ),
                    ),
                    tileColor: Theme.of(context).colorScheme.inversePrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Radera konto'),
            content: const Text(
                'Är du säker på att du vill radera ditt konto? Det går inte att ångra efter att du tryckt på knappen "Radera konto".'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Avbryt'),
                child: const Text('Avbryt'),
              ),
              TextButton(
                onPressed: () async {
                  final res =
                      await PersonRepository.instance.deletePerson(person);
                  if (res.statusCode == 200) {
                    if (context.mounted) {
                      Provider.of<GetPerson>(context, listen: false)
                          .getAllPersons();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.lightGreen,
                          content: Text('Du har raderat ditt konto!'),
                        ),
                      );
                      setState(() {
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      });
                    }
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 3),
                          backgroundColor: Colors.redAccent,
                          content: Text(
                              'Något gick fel vänligen försök igen senare'),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Radera konto'),
              ),
            ],
          ),
        ),
        style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary),
        child: const Text('Radera konto'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
