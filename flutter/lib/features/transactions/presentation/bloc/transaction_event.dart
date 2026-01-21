part of 'transaction_bloc.dart';

@immutable
sealed class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}