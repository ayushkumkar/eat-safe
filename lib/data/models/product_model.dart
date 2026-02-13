class ProductModel {
  final String id;
  final String productName;
  final String brand;
  final String fssaiNumber;
  final String imageUrl;
  final double nutritionScore;
  final Map<String, dynamic> nutrients;
  final String authenticityStatus; // AUTHENTIC / SUSPICIOUS / FAKE
  final DateTime scannedAt;

  ProductModel({
    required this.id,
    required this.productName,
    required this.brand,
    required this.fssaiNumber,
    required this.imageUrl,
    required this.nutritionScore,
    required this.nutrients,
    required this.authenticityStatus,
    required this.scannedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'productName': productName,
    'brand': brand,
    'fssaiNumber': fssaiNumber,
    'imageUrl': imageUrl,
    'nutritionScore': nutritionScore,
    'nutrients': nutrients,
    'authenticityStatus': authenticityStatus,
    'scannedAt': scannedAt.toIso8601String(),
  };

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
    id: map['id'],
    productName: map['productName'],
    brand: map['brand'],
    fssaiNumber: map['fssaiNumber'],
    imageUrl: map['imageUrl'],
    nutritionScore: map['nutritionScore']?.toDouble() ?? 0.0,
    nutrients: Map<String, dynamic>.from(map['nutrients'] ?? {}),
    authenticityStatus: map['authenticityStatus'],
    scannedAt: DateTime.parse(map['scannedAt']),
  );
}