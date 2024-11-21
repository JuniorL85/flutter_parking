import 'dart:io';

import 'package:cli_shared/cli_shared.dart';
import 'package:parking_app_cli/utils/calculate.dart';
import 'package:parking_app_cli/utils/print.dart';
import 'package:parking_app_cli/utils/validate.dart';

import '../repositories/parking_repo.dart';
import '../repositories/parking_space_repo.dart';
import '../repositories/vehicle_repo.dart';
import 'set_main.dart';

class ParkingLogic extends SetMain {
  final ParkingRepository parkingRepository = ParkingRepository.instance;
  final ParkingSpaceRepository parkingSpaceRepository =
      ParkingSpaceRepository.instance;
  final VehicleRepository vehicleRepository = VehicleRepository.instance;

  List<String> texts = [
    'Du har valt att hantera Parkeringar. Vad vill du göra?\n',
    '1. Skapa ny parkering\n',
    '2. Visa alla parkeringar\n',
    '3. Uppdatera parkeringar\n',
    '4. Ta bort parkeringar\n',
    '5. Gå tillbaka till huvudmenyn\n\n',
    'Välj ett alternativ (1-5): ',
  ];

  void runLogic(int chosenOption) {
    switch (chosenOption) {
      case 1:
        _addParkingLogic();
        break;
      case 2:
        _showAllParkingsLogic();
        break;
      case 3:
        _updateParkingLogic();
        break;
      case 4:
        _deleteParkingLogic();
        break;
      case 5:
        setMainPage(clearConsole: true);
        return;
      default:
        printColor('Ogiltigt val', 'error');
        return;
    }
  }

  String _getCorrectDate(String endTime) {
    DateTime dateToday = DateTime.now();
    String date = dateToday.toString().substring(0, 10);
    return '$date $endTime';
  }

  void _addParkingLogic() async {
    print('\nDu har valt att skapa en ny parkering\n');
    final parkingList = await parkingRepository.getAllParkings();
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

    final foundActiveParking = parkingList.indexWhere(
      (activeParking) => (activeParking.vehicle.regNr.toUpperCase() ==
              regNrInput!.toUpperCase() &&
          activeParking.endTime.microsecondsSinceEpoch >
              DateTime.now().microsecondsSinceEpoch),
    );

    if (foundActiveParking != -1) {
      getBackToMainPage(
          'Det finns redan en aktiv parkering på angivet regnr testa att uppdatera den istället, du skickas tillbaka till huvudsidan');
      return;
    } else {
      final vehicleList = await vehicleRepository.getAllVehicles();
      final foundMatchingRegNr = vehicleList.indexWhere((vehicle) =>
          (vehicle.regNr.toUpperCase() == regNrInput!.toUpperCase()));

      if (foundMatchingRegNr != -1) {
        stdout.write('Fyll i id för parkeringsplatsen: ');
        var parkingPlaceIdInput = stdin.readLineSync();

        if (parkingPlaceIdInput == null || parkingPlaceIdInput.isEmpty) {
          stdout.write(
              'Du har inte fyllt i något id för parkeringsplatsen, vänligen fyll i ett id för parkeringsplatsen: ');
          parkingPlaceIdInput = stdin.readLineSync();
        }

        if (parkingPlaceIdInput == null || parkingPlaceIdInput.isEmpty) {
          setMainPage();
          return;
        }

        if (validateNumber(parkingPlaceIdInput)) {
          int transformedId = int.parse(parkingPlaceIdInput);
          final parkingSpaceList =
              await parkingSpaceRepository.getAllParkingSpaces();
          final parkingSpaceIndexId =
              parkingSpaceList.indexWhere((i) => i.id == transformedId);

          if (parkingSpaceIndexId != -1) {
            stdout.write(
                'Fyll i sluttid för din parkering i korrekt format -> (hh:mm): ');
            var endTimeInput = stdin.readLineSync();

            if (endTimeInput == null || endTimeInput.isEmpty) {
              stdout.write(
                  'Du har inte fyllt i någon sluttid för din parkering, vänligen fyll i en sluttid för din parkering: ');
              endTimeInput = stdin.readLineSync();
            }

            if (endTimeInput == null || endTimeInput.isEmpty) {
              setMainPage();
              return;
            }

            final formattedEndTimeInput =
                DateTime.tryParse(_getCorrectDate(endTimeInput));

            if (formattedEndTimeInput == null) {
              printColor('Du angav ett felaktigt tidsformat', 'error');
              setMainPage();
              return;
            }

            final res = await parkingRepository.addParking(Parking(
              vehicle: vehicleList[foundMatchingRegNr],
              parkingSpace: ParkingSpace(
                  id: parkingSpaceList[parkingSpaceIndexId].id,
                  address: parkingSpaceList[parkingSpaceIndexId].address,
                  pricePerHour:
                      parkingSpaceList[parkingSpaceIndexId].pricePerHour),
              startTime: DateTime.now(),
              endTime: formattedEndTimeInput,
            ));

            if (res.statusCode == 200) {
              calculateDuration(DateTime.now(), formattedEndTimeInput,
                  parkingSpaceList[parkingSpaceIndexId].pricePerHour);
              printColor(
                  'Parkering startad, välj att se alla i menyn för att se parkeringar',
                  'success');
            } else {
              printColor(
                  'Något gick fel du omdirigeras till huvudmenyn', 'error');
            }
            setMainPage();
          } else {
            getBackToMainPage('Finns ingen parkeringsplats med angivet id');
            return;
          }
        } else {
          getBackToMainPage('Finns ingen parkeringsplats med angivet id');
          return;
        }
      } else {
        getBackToMainPage('Finns inget matchande registreringsnummer');
        return;
      }
    }
  }

  void _showAllParkingsLogic() async {
    var parkingList = await parkingRepository.getAllParkings();
    if (parkingList.isNotEmpty) {
      // finns det några aktiva i listan och tiden har gått ut så tas dessa bort
      final foundActiveParkingIndex = parkingList.indexWhere(
        (Parking activeParking) =>
            (activeParking.endTime.microsecondsSinceEpoch <
                DateTime.now().microsecondsSinceEpoch),
      );

      if (foundActiveParkingIndex != -1) {
        final foundActiveParking = parkingList[foundActiveParkingIndex];
        await parkingRepository.deleteParkings(foundActiveParking);
      }
      parkingList = await parkingRepository.getAllParkings();
      if (parkingList.isNotEmpty) {
        for (var park in parkingList) {
          printColor(
              'Id: ${park.id}\n Parkering: ${park.parkingSpace.address}\n Time (start and end): ${park.startTime}-${park.endTime}\n RegNr: ${park.vehicle.regNr}',
              'info');
        }
      } else {
        printColor('Inga parkeringar att visa för tillfället.....', 'error');
        getBackToMainPage('');
        return;
      }
    } else {
      printColor('Inga parkeringar att visa för tillfället.....', 'error');
    }
    stdout.write('Tryck på något för att komma till huvudmenyn');
    stdin.readLineSync();
    setMainPage(clearConsole: true);
  }

  void _updateParkingLogic() async {
    print('\nDu har valt att uppdatera en parkering\n');
    final parkingList = await parkingRepository.getAllParkings();
    if (parkingList.isEmpty) {
      getBackToMainPage(
          'Finns inga parkeringar att uppdatera, testa att lägga till en parkering först');
      return;
    }

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

    final foundParkingIndexId = parkingList
        .indexWhere((i) => (i.vehicle.regNr == regNrInput!.toUpperCase()));

    if (foundParkingIndexId != -1) {
      print('Vill du uppdatera parkeringens sluttid? Annars tryck Enter: ');
      var endTimeInput = stdin.readLineSync();
      String endTime;
      if (endTimeInput == null || endTimeInput.isEmpty) {
        endTime = '';
        print('Du gjorde ingen ändring!');
      } else {
        endTime = endTimeInput;

        final formattedEndTimeInput =
            DateTime.tryParse(_getCorrectDate(endTime));

        if (formattedEndTimeInput == null) {
          printColor('Du angav ett felaktigt tidsformat', 'error');
          setMainPage();
          return;
        }

        Parking parkingById = await parkingRepository
            .getParkingById(parkingList[foundParkingIndexId].id);

        final res = await parkingRepository.updateParkings(Parking(
          id: parkingById.id,
          vehicle: parkingById.vehicle,
          parkingSpace: parkingById.parkingSpace,
          startTime: parkingById.startTime,
          endTime: formattedEndTimeInput,
        ));

        if (res.statusCode == 200) {
          calculateDuration(parkingById.startTime, formattedEndTimeInput,
              parkingById.parkingSpace!.pricePerHour);
          printColor(
              'Parkering uppdaterad, välj att se alla i menyn för att se parkeringar',
              'success');
        } else {
          printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
        }
      }
      setMainPage();
    } else {
      getBackToMainPage(
          'Finns ingen aktiv parkering med angivet registreringsnummer');
      return;
    }
  }

  void _deleteParkingLogic() async {
    print('\nDu har valt att ta bort en parkering\n');
    final parkingList = await parkingRepository.getAllParkings();
    if (parkingList.isEmpty) {
      getBackToMainPage(
          'Finns inga parkeringar att radera, testa att lägga till en parkering först');
      return;
    }

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

    final foundParkingIndexId = parkingList
        .indexWhere((i) => (i.vehicle.regNr == regNrInput!.toUpperCase()));

    if (foundParkingIndexId != -1) {
      final parking = parkingList[foundParkingIndexId];
      final res = await parkingRepository.deleteParkings(parking);

      if (res.statusCode == 200) {
        printColor(
            'Parkering avslutad, välj att se alla i menyn för att se parkeringar',
            'success');
      } else {
        printColor('Något gick fel du omdirigeras till huvudmenyn', 'error');
      }
      setMainPage();
    } else {
      getBackToMainPage('Finns ingen aktiv parkering med angivet id');
      return;
    }
  }
}
