part of 'transaction_bloc.dart';

@immutable
sealed class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class DeleteTransaction extends TransactionEvent {
  final String transactionId;
  DeleteTransaction(this.transactionId);
}

class AddTransaction extends TransactionEvent {
  final Transaction transaction;
  AddTransaction(this.transaction);
}

class UpdateTransaction extends TransactionEvent {
  final Transaction transaction;
  UpdateTransaction(this.transaction);
}

class SyncTransactions extends TransactionEvent {}