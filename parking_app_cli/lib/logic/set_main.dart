import 'dart:io';

import 'package:parking_app_cli/utils/clear_cli.dart';
import 'package:parking_app_cli/utils/print.dart';

import 'parking_logic.dart';
import 'parking_space_logic.dart';
import 'person_logic.dart';
import 'vehicle_logic.dart';

class SetMain {
  List<String> firstPageTexts = [
    'Välkommen till parkeringsappen!\n',
    'Vad vill du hantera?\n',
    '1. Personer\n',
    '2. Fordon\n',
    '3. Parkeringsplatser\n',
    '4. Parkeringar\n',
    '5. Avsluta\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  void setMainPage({bool clearConsole = false}) {
    if (clearConsole) {
      clearCli();
    }
    int pickedMenuOption;
    stdout.writeAll(firstPageTexts);
    final input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      printColor('Du har inte valt något giltigt alternativ', 'error');
      return;
    } else {
      int pickedOption = int.parse(input);

      switch (pickedOption) {
        case 1:
          clearCli();
          stdout.writeAll(PersonLogic().texts);
          final personInput = stdin.readLineSync();
          if (personInput == null || personInput.isEmpty) {
            printColor('Du har inte valt något giltigt alternativ', 'error');
            return;
          }
          pickedMenuOption = int.parse(personInput);

          final PersonLogic personLogic = PersonLogic();
          personLogic.runLogic(pickedMenuOption);
          break;
        case 2:
          clearCli();
          stdout.writeAll(VehicleLogic().texts);
          final vehicleInput = stdin.readLineSync();

          if (vehicleInput == null || vehicleInput.isEmpty) {
            printColor('Du har inte valt något giltigt alternativ', 'error');
            return;
          }
          pickedMenuOption = int.parse(vehicleInput);

          final VehicleLogic vehicleLogic = VehicleLogic();
          vehicleLogic.runLogic(pickedMenuOption);
          break;
        case 3:
          clearCli();
          stdout.writeAll(ParkingSpaceLogic().texts);
          final parkingSpaceInput = stdin.readLineSync();

          if (parkingSpaceInput == null || parkingSpaceInput.isEmpty) {
            printColor('Du har inte valt något giltigt alternativ', 'error');
            return;
          }
          pickedMenuOption = int.parse(parkingSpaceInput);

          final ParkingSpaceLogic vehicleLogic = ParkingSpaceLogic();
          vehicleLogic.runLogic(pickedMenuOption);
          break;
        case 4:
          clearCli();
          stdout.writeAll(ParkingLogic().texts);
          final parkingInput = stdin.readLineSync();

          if (parkingInput == null || parkingInput.isEmpty) {
            printColor('Du har inte valt något giltigt alternativ', 'error');
            return;
          }
          pickedMenuOption = int.parse(parkingInput);

          final ParkingLogic vehicleLogic = ParkingLogic();
          vehicleLogic.runLogic(pickedMenuOption);
          break;
        case 5:
          stdout.write(
              'Du valde att avsluta, tack för att du använde Parkeringsappen!\n');
          return;
        default:
          printColor('Ogiltigt val', 'error');
          return;
      }
      print('\n---------------------------------\n');
    }
  }

  getBackToMainPage(String printText) {
    printColor(printText, 'error');
    setMainPage();
    return;
  }
}
