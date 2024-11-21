import 'package:cli_server/handlers/parkingSpace_handlers.dart';
import 'package:cli_server/handlers/parking_handlers.dart';
import 'package:cli_server/handlers/person_handlers.dart';
import 'package:cli_server/handlers/vehicle_handlers.dart';
import 'package:cli_shared/cli_shared.dart';
import 'package:shelf_router/shelf_router.dart';

class ServerConfig {
  // singleton constructor

  ServerConfig._privateConstructor() {
    initialize();
  }

  static final ServerConfig _instance = ServerConfig._privateConstructor();

  static ServerConfig get instance => _instance;

  late Store store;

  late Router router;

  initialize() {
    // Configure routes.
    router = Router();

    store = openStore();

    router.get('/persons', getAllPersons);
    router.get('/persons/<id>', getPersonById);
    router.post('/persons', createPerson);
    router.put('/persons', updatePerson);
    router.delete('/persons', deletePerson);

    router.get('/vehicles', getAllVehicles);
    router.get('/vehicles/<id>', getVehicleById);
    router.post('/vehicles', createVehicle);
    router.put('/vehicles', updateVehicle);
    router.delete('/vehicles', deleteVehicle);

    router.get('/parkingSpaces', getAllParkingSpaces);
    router.get('/parkingSpaces/<id>', getParkingSpaceById);
    router.post('/parkingSpaces', createParkingSpace);
    router.put('/parkingSpaces', updateParkingSpace);
    router.delete('/parkingSpaces', deleteParkingSpace);

    router.get('/parkings', getAllParkings);
    router.get('/parkings/<id>', getParkingById);
    router.post('/parkings', createParking);
    router.put('/parkings', updateParking);
    router.delete('/parkings', deleteParking);
  }
}
