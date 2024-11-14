import 'package:code_bar_reader_base/core/externals/permission_manager/enums/permission_manager_status_enum.dart';
import 'package:code_bar_reader_base/core/externals/permission_manager/permission_manager.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/domain/usecases/get_ticket_by_code_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

part 'ticket_scanner_state.dart';

class TicketScannerCubit extends Cubit<TicketScannerState> {
  final GetTicketByCodeUsecase _getTicketByCodeUsecase;
  final PermissionManager _permissionManager;

  TicketScannerCubit({
    required PermissionManager permissionManager,
    required GetTicketByCodeUsecase getTicketByCodeUsecase,
  })  : _permissionManager = permissionManager,
        _getTicketByCodeUsecase = getTicketByCodeUsecase,
        super(TicketScannerInitial());

  late QRViewController _qrController;

  Future<void> init() async {
    emit(TicketScannerLoading());
    await Future.delayed(const Duration(seconds: 2));
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    PermissionManagerStatusEnum status =
        await _permissionManager.requestCameraPermission();

    if (status == PermissionManagerStatusEnum.denied ||
        status == PermissionManagerStatusEnum.permanentlyDenied) {
      emit(ScannerPermissionDeniedState(
        message: 'Permission denied',
      ));
    }

    if (status == PermissionManagerStatusEnum.granted) {
      emit(TicketScannerSuccess());
    }
  }

  Future<void> setQRViewController(QRViewController controller) async {
    _qrController = controller;
    _qrController.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      _processQRCode(scanData);
    });
  }

  Future<void> pauseScanner() async {
    await _qrController.pauseCamera();
  }

  Future<void> restartScanner() async {
    await _qrController.resumeCamera();
  }

  void _processQRCode(Barcode scanData) async {
    try {
      debugPrint('QR Code Scanned: ${scanData.code}');
      if (scanData.code?.isNotEmpty == true) {
        checkTicketCode(scanData.code!);
      } else {
        emit(TicketScannerError(message: 'Invalid QR Code'));
      }
    } catch (error) {
      emit(TicketScannerError(message: error.toString()));
    }
  }

  void checkTicketCode(String code) async {
    final result = await _getTicketByCodeUsecase(code: code);
    result.fold(
      (error) {
        emit(TicketScannerError(message: 'Ticket not found'));
      },
      (ticket) {
        emit(TicketScannedSucess());
      },
    );
  }

  @override
  Future<void> close() {
    _qrController.dispose();
    return super.close();
  }

  void changeFlashMode() async {
    await _qrController.toggleFlash();
  }
}
