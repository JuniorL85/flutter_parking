import 'package:flutter/material.dart';
import 'package:parking_admin/views/show_active_parkings.dart';

class ManageMonitoringTitle {
  IconData titleIcon;
  String titleText;

  ManageMonitoringTitle({required this.titleIcon, required this.titleText});
}

class Monitoring extends StatefulWidget {
  const Monitoring({super.key});

  @override
  State<Monitoring> createState() => _MonitoringState();
}

class _MonitoringState extends State<Monitoring> {
  final List<ManageMonitoringTitle> manageMonitoring = [
    ManageMonitoringTitle(
        titleIcon: Icons.list_alt, titleText: 'Visa aktiva parkeringar'),
    ManageMonitoringTitle(
        titleIcon: Icons.summarize_outlined,
        titleText: 'Summa av aktiva parkeringar'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        const SizedBox(height: 50),
        const Text(
          'Övervakning',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 50),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                mainAxisExtent: 120,
              ),
              itemCount: 2,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    switch (index) {
                      case 0:
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const ShowActiveParkings(),
                          ),
                        );
                        break;
                      case 1:
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => const Text(''),
                          ),
                        );
                        break;
                      default:
                    }
                  },
                  child: Card(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      borderOnForeground: true,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(manageMonitoring[index].titleIcon),
                            Text(manageMonitoring[index].titleText),
                          ],
                        ),
                      )),
                );
              }),
        ),
      ],
    ));
  }
}
