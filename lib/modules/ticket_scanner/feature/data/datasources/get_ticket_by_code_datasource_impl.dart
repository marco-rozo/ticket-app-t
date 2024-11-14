import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/core/consts/ticket_consts.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/core/errors/ticket_failure.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/data/datasources/get_ticket_by_code_datasource.dart';
import 'package:code_bar_reader_base/modules/ticket_scanner/feature/data/models/ticket_model.dart';

class GetTicketByCodeDatasourceImpl implements GetTicketByCodeDatasource {
  final FirebaseFirestore _firebaseFirestore;

  GetTicketByCodeDatasourceImpl({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;

  @override
  Future<TicketModel> call({required String code}) async {
    try {
      return _firebaseFirestore
          .collection(TicketConsts.collection)
          .doc(code)
          .get()
          .then(
            (snapshot) {
              print(snapshot.data());
              return TicketModel.fromMap(snapshot.data() as Map<String, dynamic>);
            },
          );
    } on Exception catch (e, s) {
      throw TicketFailure(message: e.toString(), stackTrace: s);
    }
  }
}
