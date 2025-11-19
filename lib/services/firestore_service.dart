import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/orcamento.dart';
import '../models/recibo.dart';
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

      print('✅ Orçamento encontrado com status: ${orcamento.status}');
      return orcamento;
    } catch (e) {
      print('❌ Erro ao buscar orçamento: $e');
      rethrow;
    }
  }

  // Busca recibo específico
  Future<Recibo?> getRecibo(String userId, String reciboId) async {
    try {
      print('🔍 Buscando recibo: business/$userId/recibos/$reciboId');

      DocumentSnapshot doc = await _db
          .collection('business')
          .doc(userId)
          .collection('recibos')
          .doc(reciboId)
          .get();

      if (!doc.exists) {
        print('❌ Recibo não encontrado');
        return null;
      }

      Recibo recibo = Recibo.fromFirestore(doc);

      print('✅ Recibo encontrado com status: ${recibo.status}');
      return recibo;
    } catch (e) {
      print('❌ Erro ao buscar recibo: $e');
      rethrow;
    }
  }

  // Busca informações do negócio
  Future<BusinessInfo?> getBusinessInfo(String userId) async {
    try {
      print('🔍 Buscando dados do negócio: users/$userId/business/info');

      DocumentSnapshot doc = await _db.collection('business').doc(userId).get();

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

  // Atualiza o status do orçamento
  Future<void> updateOrcamentoStatus(
    String userId,
    String orcamentoId,
    String novoStatus,
  ) async {
    try {
      print('🔄 Atualizando status do orçamento para: $novoStatus');

      await _db
          .collection('business')
          .doc(userId)
          .collection('orcamentos')
          .doc(orcamentoId)
          .update({
        'status': novoStatus,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });

      print('✅ Status atualizado com sucesso');
    } catch (e) {
      print('❌ Erro ao atualizar status: $e');
      rethrow;
    }
  }
}
