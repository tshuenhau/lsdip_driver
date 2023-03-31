import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lsdip_driver/widgets/OrderDetailsScreen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class OrderScanner extends StatelessWidget {
  OrderScanner({super.key});
  MobileScannerController cameraController =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Scanner'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state as CameraFacing) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: MobileScanner(
        // fit: BoxFit.contain,

        controller: cameraController,
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          final Uint8List? image = capture.image;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(
                    orderId: barcodes[0].rawValue.toString())),
          );
          // for (final barcode in barcodes) {
          //   debugPrint('Barcode found! ${barcode.rawValue}');
          //   Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) =>
          //             OrderDetailsScreen(orderId: barcode.rawValue.toString())),
          //   );
          // }
        },
      ),
    );
  }
}
