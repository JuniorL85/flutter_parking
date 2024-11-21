import 'dart:io';

import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/utils/print.dart';
import 'package:parking_app_cli/utils/validate.dart';
import '../repositories/person_repo.dart';
import 'set_main.dart';

class PersonLogic extends SetMain {
  final PersonRepository personRepository = PersonRepository.instance;

  List<String> texts = [
    'Du har valt att hantera Personer. Vad vill du göra?\n',
    '1. Skapa ny person\n',
    '2. Visa alla personer\n',
    '3. Uppdatera person\n',
    '4. Ta bort person\n',
    '5. Gå tillbaka till huvudmenyn\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  void runLogic(int chosenOption) {
    switch (chosenOption) {
      case 1:
        _addPersonLogic();
        break;
      case 2:
        _showAllPersonsLogic();
        break;
      case 3:
        _updatePersonsLogic();
        break;
      case 4:
        _deletePersonLogic();
        break;
      case 5:
        setMainPage(clearConsole: true);
        return;
      default:
        printColor('Ogiltigt val', 'error');
        return;
    }
  }

  void _addPersonLogic() async {
    print('\nDu har valt att skapa en ny person\n');
    stdout.write('Fyll i namn: ');
    var nameInput = stdin.readLineSync();

    if (nameInput == null || nameInput.isEmpty) {
      stdout
          .write('Du har inte fyllt i något namn, vänligen fyll i ett namn: ');
      nameInput = stdin.readLineSync();
    }

    // Dubbelkollar så inga tomma värden skickas
    if (nameInput == null || nameInput.isEmpty) {
      setMainPage();
      return;
    }

    stdout.write('Fyll i personnummer (12 siffror utan bindestreck): ');
    var socialSecurityNrInput = stdin.readLineSync();

    if (socialSecurityNrInput != null &&
        validateSocialSecurityNumber(socialSecurityNrInput)) {
      if (socialSecurityNrInput.isEmpty) {
        stdout.write(
            'Du har inte fyllt i något personnummer, vänligen fyll i ett personnummer: ');
        socialSecurityNrInput = stdin.readLineSync();
      }

      // Dubbelkollar så inga tomma värden skickas
      if (socialSecurityNrInput == null || socialSecurityNrInput.isEmpty) {
        setMainPage();
        return;
      }
      final res = await personRepository.addPerson(
          Person(name: nameInput, socialSecurityNumber: socialSecurityNrInput));

      if (res.statusCode == 200) {
        printColor(
            'Person tillagd, välj att se alla i menyn för att se personer',
            'success');
      } else {
        printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
      }
      setMainPage();
    } else {
      printColor(
          'Du måste ange ett personnummer med 12 siffror, du omdirigeras till huvudmenyn',
          'error');
      setMainPage();
    }
  }

  _showAllPersonsLogic() async {
    final personList = await personRepository.getAllPersons();
    if (personList.isNotEmpty) {
      for (var person in personList) {
        printColor(
            'Id: ${person.id}\n Namn: ${person.name}\n  Personnummer: ${person.socialSecurityNumber}',
            'info');
      }
    } else {
      printColor(
          'Inga personer att visa i nuläget. Testa att lägga till personer.',
          'error');
    }
    stdout.write('Tryck på något för att komma till huvudmenyn');
    stdin.readLineSync();
    setMainPage(clearConsole: true);
  }

  void _updatePersonsLogic() async {
    print('\nDu har valt att uppdatera en person\n');
    final personList = await personRepository.getAllPersons();
    if (personList.isEmpty) {
      getBackToMainPage(
          'Finns inga personer att uppdatera, testa att lägga till en person först');
      return;
    }
    stdout.write(
        'Fyll i personnummer på personen du vill uppdatera (12 siffror utan bindestreck): ');
    var socialSecurityNrInput = stdin.readLineSync();

    if (socialSecurityNrInput == null || socialSecurityNrInput.isEmpty) {
      stdout.write(
          'Du har inte fyllt i något personnummer, vänligen fyll i ett personnummer: ');
      socialSecurityNrInput = stdin.readLineSync();
    }

    // Dubbelkollar så inga tomma värden skickas
    if (socialSecurityNrInput == null || socialSecurityNrInput.isEmpty) {
      setMainPage();
      return;
    }

    final foundPersonIndex = personList
        .indexWhere((i) => i.socialSecurityNumber == socialSecurityNrInput);

    if (foundPersonIndex != -1) {
      // Hade inte behövt använda nedanstående här men för att påvisa att getPersonById fungerar så kör jag den här
      Person personById =
          await personRepository.getPersonById(personList[foundPersonIndex].id);

      print('Vill du uppdatera personens namn? Annars tryck Enter: ');
      var name = stdin.readLineSync();
      String updatedName;
      if (name == null || name.isEmpty) {
        updatedName = '';
        print('Du gjorde ingen ändring!');
      } else {
        updatedName = name;
        final res = await personRepository.updatePersons(Person(
          id: personById.id,
          name: updatedName,
          socialSecurityNumber: socialSecurityNrInput,
        ));
        if (res.statusCode == 200) {
          printColor(
              'Person uppdaterad, välj att se alla i menyn för att se uppdateringen',
              'success');
        } else {
          printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
        }
      }
      setMainPage();
    } else {
      getBackToMainPage('Finns ingen person med det angivna personnumret');
      return;
    }
  }

  void _deletePersonLogic() async {
    print('\nDu har valt att ta bort en person\n');
    final personList = await personRepository.getAllPersons();
    if (personList.isEmpty) {
      getBackToMainPage(
          'Finns inga personer att radera, testa att lägga till en person först');
      return;
    }
    stdout.write('Fyll i personnummer (12 siffror utan bindestreck): ');
    var socialSecurityNrInput = stdin.readLineSync();

    if (socialSecurityNrInput == null || socialSecurityNrInput.isEmpty) {
      stdout.write(
          'Du har inte fyllt i något personnummer, vänligen fyll i ett personnummer: ');
      socialSecurityNrInput = stdin.readLineSync();
    }

    // Dubbelkollar så inga tomma värden skickas
    if (socialSecurityNrInput == null || socialSecurityNrInput.isEmpty) {
      setMainPage();
      return;
    }

    final foundPersonIndex = personList
        .indexWhere((i) => i.socialSecurityNumber == socialSecurityNrInput);

    if (foundPersonIndex != -1) {
      final res =
          await personRepository.deletePerson(personList[foundPersonIndex]);

      if (res.statusCode == 200) {
        printColor(
            'Person raderad, välj att se alla i menyn för att se personer',
            'success');
      } else {
        printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
      }
      setMainPage();
    } else {
      getBackToMainPage('Finns ingen person med det angivna personnumret');
      return;
    }
  }
}
