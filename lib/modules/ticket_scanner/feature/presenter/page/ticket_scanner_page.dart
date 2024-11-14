import 'package:code_bar_reader_base/core/theme/components/custom_bottom_sheet/custom_bottom_sheet.dart';
import 'package:code_bar_reader_base/core/theme/components/custom_button/custom_button.dart';
import 'package:code_bar_reader_base/core/theme/components/custom_generic_loading.dart/custom_generic_loading_widget.dart';
import 'package:code_bar_reader_base/core/theme/components/custom_snackbar/custom_snackbar.dart';
import 'package:code_bar_reader_base/core/theme/components/custom_text_form_field/custom_text_form_field.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/presenter/cubit/ticket_scanner_cubit.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/presenter/widget/manual_insertion_body/manual_insertion_body_widget.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/presenter/widget/ticket_scanner_body/ticket_scanner_body_widget.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/presenter/widget/scanner_camera_error/scanner_camera_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TicketScannerPage extends StatefulWidget {
  const TicketScannerPage({super.key});

  @override
  State<TicketScannerPage> createState() => _TicketScannerPageState();
}

class _TicketScannerPageState extends State<TicketScannerPage>
    with CustomBottomSheet, CustomSnackBar {
  late final TicketScannerCubit _scannerCubit;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void initState() {
    super.initState();
    _scannerCubit = context.read<TicketScannerCubit>()..init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TicketScannerCubit, TicketScannerState>(
        bloc: _scannerCubit,
        listener: (context, state) {
          if (state is TicketScannedSucess) {
            showCustomSnackBar(
              context,
              message: 'Codigo identificado com sucesso',
            );
            context.pop();
          }
          if (state is TicketScannerError) {
            debugPrint('Error: ${state.message}');
            _scannerCubit.init();
          }
        },
        builder: (_, state) => switch (state) {
          TicketScannerSuccess() => TicketScannerBodyWidget(
              qrKey: qrKey,
              setQRViewController: _scannerCubit.setQRViewController,
              toggleFlash: _scannerCubit.changeFlashMode,
              openInsertManualCode: () async {
                _scannerCubit.pauseScanner();
                TextEditingController codeTextController =
                    TextEditingController();
                final codeInput = await showCustomBottomSheet<String>(
                  initialChildSize: 0.8,
                  context: context,
                  child: ManualInsertionBodyWidget(
                      codeTextController: codeTextController),
                );

                if (codeInput != null) {
                  _scannerCubit.checkTicketCode(codeInput);
                } else {
                  _scannerCubit.restartScanner();
                }
              },
            ),
          ScannerPermissionDeniedState() => const ScannerCameraErrorWidget(),
          TicketScannerInitial() ||
          TicketScannerLoading() ||
          _ =>
            const CustomGenericLoadingWidget(),
        },
      ),
    );
  }
}
