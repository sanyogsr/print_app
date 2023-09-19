import 'dart:async';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class PrintPage extends StatefulWidget {
  // List<Map<String, dynamic>> data;
  final String title;
  final int price;
  final int quantity;

  PrintPage(
      {Key? key,
      required this.title,
      required this.price,
      required this.quantity})
      : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = [];
  String _deviceMsg = "";
  final currencyFormater = NumberFormat("\$###,###.00", "en_US");
  bool _showProgressIndicator = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initPrinter();
    });
  }

  Future<void> initPrinter() async {
    final status = await Permission.bluetooth.status;
    if (status != PermissionStatus.granted) {
      final result = await Permission.bluetooth.request();
      if (result != PermissionStatus.granted) {
        // Permission denied, handle it accordingly
        return;
      }
    }

    final locationStatus = await Permission.location.status;
    if (locationStatus != PermissionStatus.granted) {
      final locationResult = await Permission.location.request();
      if (locationResult != PermissionStatus.granted) {
        // Location permission denied, handle it accordingly
        return;
      }
    }

    // await openAppSettings();

    try {
      await bluetoothPrint.startScan(timeout: Duration(seconds: 2));

      if (!mounted) {
        return;
      }

      bluetoothPrint.scanResults.listen((value) {
        if (!mounted) return;
        setState(() {
          _devices = value;
        });
        if (_devices.isEmpty) {
          setState(() {
            _deviceMsg = "No devices found";
          });
        }
      });
    } catch (e) {
      print("Error while scanning for devices: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildDeviceList());
  }

  Future<void> _startPrint(BluetoothDevice device) async {
    if (device != null && device.address != null) {
      await bluetoothPrint.connect(device);

      Map<String, dynamic> config = Map();
      List<LineText> list = [];

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: "Printed Receipt",
          width: 2,
          height: 2,
          weight: 2,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content: widget.title,
          weight: 0,
          align: LineText.ALIGN_LEFT,
          linefeed: 1));

      list.add(LineText(
          type: LineText.TYPE_TEXT,
          content:
              "${currencyFormater.format(this.widget.price)} * ${this.widget.quantity}",
          align: LineText.ALIGN_LEFT,
          linefeed: 1));
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text("Select Printer"),
      centerTitle: true,
      backgroundColor: Colors.blue.shade300,
    );
  }

  Widget _buildDeviceList() {
    return _devices.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Finding a Printer",
                  style: TextStyle(color: Colors.blue),
                )
              ],
            ),
          )
        : ListView.builder(
            itemCount: _devices.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.print),
                title: Text("${_devices[index].name}"),
                subtitle: Text("${_devices[index].address}"),
                onTap: () {
                  _startPrint(_devices[index]);
                },
              );
            },
          );
  }
}
