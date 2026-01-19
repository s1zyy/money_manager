class Transaction {
    final String? id;
    final double? amount;
    final DateTime? date;
    final String? category;

    const Transaction({
        this.id,
        this.amount,
        this.date,
        this.category,
    });

    factory Transaction.fromJson(Map<String, dynamic> json) {
        return Transaction(
            id: json['id'] as String?,
            amount: json['amount'] as double?,
            date: json['date'] !=null ? DateTime.parse(json['date']) : null,
            category: json['category'] as String?,
        );
        
    }

    @override
    String toString() {
        return 'Transaction{id: $id, amount: $amount, date: $date, category: $category}';
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'amount': amount,
            'date': date?.toIso8601String(),
            'category': category,
        };
    }

}