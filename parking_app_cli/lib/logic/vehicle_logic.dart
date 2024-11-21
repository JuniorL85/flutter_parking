import 'dart:io';

import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/utils/print.dart';
import 'package:parking_app_cli/utils/validate.dart';
import '../repositories/person_repo.dart';
import '../repositories/vehicle_repo.dart';
import 'set_main.dart';

class VehicleLogic extends SetMain {
  final VehicleRepository vehicleRepository = VehicleRepository.instance;
  final PersonRepository personRepository = PersonRepository.instance;

  List<String> texts = [
    'Du har valt att hantera Fordon. Vad vill du göra?\n',
    '1. Skapa nytt fordon\n',
    '2. Visa alla fordon\n',
    '3. Uppdatera fordon\n',
    '4. Ta bort fordon\n',
    '5. Gå tillbaka till huvudmenyn\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  void runLogic(int chosenOption) {
    switch (chosenOption) {
      case 1:
        _addVehicleLogic();
        break;
      case 2:
        _showAllVehiclesLogic();
        break;
      case 3:
        _updateVehiclesLogic();
        break;
      case 4:
        _deleteVehicleLogic();
        break;
      case 5:
        setMainPage(clearConsole: true);
        return;
      default:
        printColor('Ogiltigt val', 'error');
        return;
    }
  }

  void _addVehicleLogic() async {
    print('\nDu har valt att lägga till ett nytt fordon\n');
    stdout.write(
        'Fyll i personnummer på ägaren (du måste ha skapat en ny person först, har du inte gjort det så skriv 1 så kommer du tillbaka till huvudmenyn): ');
    var socialSecurityNumberInput = stdin.readLineSync();

    if (socialSecurityNumberInput == null ||
        socialSecurityNumberInput.isEmpty) {
      stdout.write(
          'Du har inte fyllt i något personnummer, vänligen fyll i ett personnummer: ');
      socialSecurityNumberInput = stdin.readLineSync();
    }

    // Dubbelkollar så inga tomma värden skickas
    if (socialSecurityNumberInput == null ||
        socialSecurityNumberInput.isEmpty) {
      setMainPage();
      return;
    }

    if (validateSocialSecurityNumber(socialSecurityNumberInput)) {
      if (int.parse(socialSecurityNumberInput) == 1) {
        setMainPage();
        return;
      }
      // Lägg till rätt person på fordon
      final personList = await personRepository.getAllPersons();

      final foundPersonIndex = personList.indexWhere(
          (i) => i.socialSecurityNumber == socialSecurityNumberInput);

      if (foundPersonIndex != -1) {
        final personToAdd = personList.firstWhere((person) =>
            person.socialSecurityNumber == socialSecurityNumberInput);

        stdout.write('Fyll i registreringsnummer: ');
        var regNrInput = stdin.readLineSync();

        if (regNrInput == null || regNrInput.isEmpty) {
          stdout.write(
              'Du har inte fyllt i något registreringsnummer, vänligen fyll i ett registreringsnummer: ');
          regNrInput = stdin.readLineSync();
        }

        if (regNrInput == null || regNrInput.isEmpty) {
          setMainPage();
          return;
        }

        stdout.write(
            'Fyll i vilken typ av fordon det är med en siffra (1: Bil, 2: Motorcykel, 3: Annat): ');
        var typeInput = stdin.readLineSync();

        if (typeInput == null || typeInput.isEmpty) {
          stdout.write(
              'Du har inte fyllt i någon typ, vänligen fyll i en siffra (1: Bil, 2: Motorcykel, 3: Annat): ');
          typeInput = stdin.readLineSync();
        }

        // Dubbelkollar så inga tomma värden skickas
        if (typeInput == null || typeInput.isEmpty) {
          setMainPage();
          return;
        }

        if (validateNumber(typeInput)) {
          int pickedOption = int.parse(typeInput);
          String vehicleType;
          // Lägg till rätt fordonstyp
          switch (pickedOption) {
            case 1:
              vehicleType = 'Car';
              break;
            case 2:
              vehicleType = 'Motorcycle';
              break;
            case 3:
              vehicleType = 'Other';
              break;
            default:
              vehicleType = 'Other';
              break;
          }

          final res = await vehicleRepository.addVehicle(Vehicle(
            regNr: regNrInput.toUpperCase(),
            vehicleType: vehicleType,
            owner: Person(
                id: personToAdd.id,
                name: personToAdd.name,
                socialSecurityNumber: personToAdd.socialSecurityNumber),
          ));
          if (res.statusCode == 200) {
            printColor(
                'Fordon tillagt, välj att se alla i menyn för att se dina fordon',
                'success');
          } else {
            printColor(
                'Något gick fel du omdirigeras till huvudmenyn', 'error');
          }
          setMainPage();
        } else {
          getBackToMainPage('Du har angivit ett felaktigt värde');
          return;
        }
      } else {
        getBackToMainPage('Finns ingen person med det angivna personnumret');
        return;
      }
    } else {
      printColor(
          'Du måste ange ett personnummer med 12 siffror, du omdirigeras till huvudmenyn',
          'error');
      setMainPage();
    }
  }

  void _showAllVehiclesLogic() async {
    final vehicleList = await vehicleRepository.getAllVehicles();
    if (vehicleList.isNotEmpty) {
      for (var vehicle in vehicleList) {
        printColor(
            'Id: ${vehicle.id}\n RegNr: ${vehicle.regNr}\n Ägare: ${vehicle.owner.name}-${vehicle.owner.socialSecurityNumber}\n Typ: ${vehicle.vehicleType}',
            'info');
      }
    } else {
      printColor('Finns inga fordon att visa just nu....', 'error');
    }
    stdout.write('Tryck på något för att komma till huvudmenyn');
    stdin.readLineSync();
    setMainPage(clearConsole: true);
  }

  void _updateVehiclesLogic() async {
    print('\nDu har valt att uppdatera ett fordon\n');
    final vehicleList = await vehicleRepository.getAllVehicles();
    if (vehicleList.isEmpty) {
      getBackToMainPage(
          'Finns inga fordon att uppdatera, testa att lägga till ett fordon först');
      return;
    }

    stdout.write('Fyll i registreringsnummer på fordonet du vill uppdatera: ');
    var regNrInput = stdin.readLineSync()!.toUpperCase();

    if (regNrInput.isEmpty) {
      stdout.write(
          'Du har inte fyllt i något registreringsnummer, vänligen fyll i ett registreringsnummer: ');
      regNrInput = stdin.readLineSync()!.toUpperCase();
    }

    // Dubbelkollar så inga tomma värden skickas
    if (regNrInput.isEmpty) {
      setMainPage();
      return;
    }

    final foundVehicleIndex =
        vehicleList.indexWhere((p) => p.regNr == regNrInput);

    if (foundVehicleIndex != -1) {
      Vehicle vehicleById = await vehicleRepository
          .getVehicleById(vehicleList[foundVehicleIndex].id);

      print('Vänligen fyll i det nya registreringsnumret på fordonet: ');
      var regnr = stdin.readLineSync()!.toUpperCase();
      String updatedRegnr;
      if (regnr.isEmpty) {
        updatedRegnr = '';
        print('Du gjorde ingen ändring!');
      } else {
        updatedRegnr = regnr;
        final res = await vehicleRepository.updateVehicles(
          Vehicle(
            id: vehicleById.id,
            regNr: updatedRegnr,
            vehicleType: vehicleById.vehicleType,
            owner: vehicleById.owner,
          ),
        );
        if (res.statusCode == 200) {
          printColor(
              'Fordon uppdaterat, välj att se alla i menyn för att se dina fordon',
              'success');
        } else {
          printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
        }
      }
      setMainPage();
    } else {
      getBackToMainPage('Du har angett ett felaktigt registreringsnummer');
      return;
    }
  }

  void _deleteVehicleLogic() async {
    print('\nDu har valt att ta bort ett fordon\n');
    final vehicleList = await vehicleRepository.getAllVehicles();
    if (vehicleList.isEmpty) {
      getBackToMainPage(
          'Finns inga fordon att radera, testa att lägga till ett fordon först');
      return;
    }

    stdout.write('Fyll i registreringsnummer: ');
    var regNrInput = stdin.readLineSync()!.toUpperCase();

    if (regNrInput.isEmpty) {
      stdout.write(
          'Du har inte fyllt i något registreringsnummer, vänligen fyll i ett registreringsnummer: ');
      regNrInput = stdin.readLineSync()!.toUpperCase();
    }

    // Dubbelkollar så inga tomma värden skickas
    if (regNrInput.isEmpty) {
      setMainPage();
      return;
    }

    final foundVehicleIndex =
        vehicleList.indexWhere((p) => p.regNr == regNrInput);

    if (foundVehicleIndex != -1) {
      final res =
          await vehicleRepository.deleteVehicle(vehicleList[foundVehicleIndex]);
      if (res.statusCode == 200) {
        printColor(
            'Fordon raderat, välj att se alla i menyn för att se dina fordon',
            'success');
      } else {
        printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
      }
      setMainPage();
    } else {
      getBackToMainPage('Du har angett ett felaktigt registreringsnummer');
      return;
    }
  }
}
