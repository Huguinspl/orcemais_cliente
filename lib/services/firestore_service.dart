import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orcamento.dart';
import '../models/business_info.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Busca orçamento específico
  Future<Orcamento?> getOrcamento(String userId, String orcamentoId) async {
    try {
      print('🔍 Buscando orçamento: users/$userId/orcamentos/$orcamentoId');

      DocumentSnapshot doc = await _db
          .collection('business')
          .doc(userId)
          .collection('orcamentos')
          .doc(orcamentoId)
          .get();

      if (!doc.exists) {
        print('❌ Orçamento não encontrado');
        return null;
      }

      Orcamento orcamento = Orcamento.fromFirestore(doc);

      // Validar se o orçamento está com status "Enviado"
      if (orcamento.status != 'Enviado') {
        print('❌ Orçamento não está disponível (status: ${orcamento.status})');
        throw Exception('Este orçamento não está disponível para visualização');
      }

      print('✅ Orçamento encontrado: #${orcamento.numero}');
      return orcamento;
    } catch (e) {
      print('❌ Erro ao buscar orçamento: $e');
      rethrow;
    }
  }

  // Busca informações do negócio
  Future<BusinessInfo?> getBusinessInfo(String userId) async {
    try {
      print('🔍 Buscando dados do negócio: users/$userId/business/info');

      DocumentSnapshot doc = await _db
          .collection('users')
          .doc(userId)
          .collection('meta')
          .doc('business')
          .get();

      if (!doc.exists) {
        print('❌ Dados do negócio não encontrados');
        return null;
      }

      final businessInfo = BusinessInfo.fromDoc(doc);
      print('✅ Negócio encontrado: ${businessInfo.nomeEmpresa}');
      return businessInfo;
    } catch (e) {
      print('❌ Erro ao buscar dados do negócio: $e');
      rethrow;
    }
  }
}
