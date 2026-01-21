class Transaction {
    final String id;
    final double amount;
    final DateTime date;
    final String category;
    final bool isSynced;

    const Transaction({
        required this.id,
        required this.amount,
        required this.date,
        required this.category,
        required this.isSynced,
    });

    Transaction copyWith({
        String? id,
        double? amount,
        DateTime? date,
        String? category,
        bool? isSynced,
    }) {
        return Transaction(
            id: id ?? this.id,
            amount: amount ?? this.amount,
            date: date ?? this.date,
            category: category ?? this.category,
            isSynced: isSynced ?? this.isSynced,
        );
    }

}