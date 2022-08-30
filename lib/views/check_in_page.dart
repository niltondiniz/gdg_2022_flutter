import 'package:flutter/material.dart';
import 'package:gdg_2022/views/widgets/vertical_space_16.dart';

// ignore: must_be_immutable
class CheckInPage extends StatefulWidget {
  CheckInPage({Key? key}) : super(key: key);

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  Iterable<String> busIds = [
    'Selecione',
    'Moura Brasil',
    'Jaqueira',
    'Cantagalo',
    'Monte Castelo',
    'Ponte das Garças',
    'Pilões',
    'Mirante Sul',
    'Morada do Sol',
    'Palmital'
  ];

  String selectedBusId = 'Selecione';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const VerticalSpace16Widget(),
              const VerticalSpace16Widget(),
              const Expanded(
                flex: 1,
                child: Text(
                  'Selecione a linha para check-in',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: DropdownButton(
                    isExpanded: true,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    hint: const Text('Selecione uma opção'),
                    items: busIds
                        .map((String dropDownStringItem) =>
                            DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem)))
                        .toList(),
                    onChanged: ((String? value) {
                      setState(() {
                        selectedBusId = value!;
                      });
                    }),
                    value: selectedBusId,
                  ),
                ),
              ),
              const Expanded(flex: 7, child: VerticalSpace16Widget()),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (selectedBusId.isNotEmpty &&
                        selectedBusId != 'Selecione') {
                      Navigator.pop(context, selectedBusId);
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Check-in',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const Expanded(flex: 7, child: VerticalSpace16Widget()),
            ],
          ),
        ),
      ),
    );
  }
}
