import 'package:hive/hive.dart';

part 'models.g.dart';

@HiveType(typeId: 0)
class PartnerResponse {
  @HiveField(0)
  final List<DataModel> data;

  PartnerResponse({
    required this.data,
  });

  factory PartnerResponse.fromJson(Map<String, dynamic> json) =>
      PartnerResponse(
        data: List<DataModel>.from(
          (json['data'] ?? []).map(
                (x) => DataModel.fromJson(x),
          ),
        ),
      );
}

@HiveType(typeId: 1)
class DataModel {
  @HiveField(0)
  final List<PartnerModel> createdPartners;
  @HiveField(1)
  final List<PartnerModel> updatedPartners;

  DataModel({
    required this.createdPartners,
    required this.updatedPartners,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) => DataModel(
    createdPartners: List<PartnerModel>.from(
      (json['created_partners'] ?? []).map(
            (x) => PartnerModel.fromJson(x),
      ),
    ),
    updatedPartners: List<PartnerModel>.from(
      (json['updated_partners'] ?? []).map(
            (x) => PartnerModel.fromJson(x),
      ),
    ),
  );
}

@HiveType(typeId: 2)
class PartnerModel extends HiveObject {
  @HiveField(0)
  final num? partnerId;

  @HiveField(1)
  final String? partnerName;

  @HiveField(2)
  final List<CapacityModel> capacities;

  @HiveField(3)
  final List<QuotationModel> quotations;

  PartnerModel({
    required this.partnerId,
    required this.partnerName,
    required this.capacities,
    required this.quotations,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) => PartnerModel(
    partnerId: json['partner_id'],
    partnerName: json['partner_name'] ?? '',
    capacities: List<CapacityModel>.from(
      (json['capacities'] ?? []).map(
            (x) => CapacityModel.fromJson(x),
      ),
    ),
    quotations: List<QuotationModel>.from(
      (json['quotations'] ?? []).map(
            (x) => QuotationModel.fromJson(x),
      ),
    ),
  );
}

@HiveType(typeId: 3)
class CapacityModel {
  @HiveField(0)
  final List<ProductModel> products;

  CapacityModel({
    required this.products,
  });

  factory CapacityModel.fromJson(Map<String, dynamic> json) => CapacityModel(
    products: List<ProductModel>.from(
      (json['products'] ?? []).map(
            (x) => ProductModel.fromJson(x),
      ),
    ),
  );
}

@HiveType(typeId: 4)
class ProductModel {
  @HiveField(0)
  final num? productTmplId;

  @HiveField(1)
  final String? productName;

  @HiveField(2)
  final String? barcode;

  @HiveField(3)
  final num? sequence;

  @HiveField(4)
  final num? capacity;

  @HiveField(5)
  final List<ColorModel> colors;

  @HiveField(6)
  final num? qtyAvailable;

  ProductModel({
    required this.productTmplId,
    required this.productName,
    required this.barcode,
    required this.sequence,
    required this.capacity,
    required this.colors, this.qtyAvailable,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    productTmplId: json['product_tmpl_id'],
    productName: json['product_name'] ?? '',
    barcode: json['barcode'] ?? '',
    sequence: json['sequence'],
    capacity: json['capacity'],
    qtyAvailable: json['qty_avaliable'],
    colors: List<ColorModel>.from(
      (json['colors'] ?? []).map(
            (x) => ColorModel.fromJson(x),
      ),
    ),
  );
}

@HiveType(typeId: 5)
class ColorModel {
  @HiveField(0)
  final num? colorId;

  @HiveField(1)
  final String? colorName;

  @HiveField(2)
  final num? capacity;

  @HiveField(3)
  final num? sequence;

  @HiveField(4)
  final String? colorHash;

  @HiveField(5)
  final num? qtyAvailable;

  ColorModel({
    this.colorId,
    required this.colorName,
    required this.capacity,
    required this.sequence,
    this.colorHash, this.qtyAvailable,
  });

  factory ColorModel.fromJson(Map<String, dynamic> json) => ColorModel(
    colorId: json['color_id'],
    colorName: json['color_name'] ?? '',
    capacity: json['capacity'],
    sequence: json['sequence'],
    colorHash: json['color_hash'],
    qtyAvailable: json['qty_avaliable'],
  );
}

@HiveType(typeId: 6)
class QuotationModel {
  @HiveField(0)
  final num? quotationId;

  @HiveField(1)
  final String? name;

  @HiveField(2)
  final List<OrderLineModel> orderLines;

  @HiveField(3)
  final List<ColorMovementModel> colorMovements;

  @HiveField(4)
  final String? state;

  @HiveField(5)
  final num? partnerId;

  @HiveField(6)
  final String? partnerName;

  @HiveField(7)
  final String? createDate;

  @HiveField(8)
  final num? totalCount;

  QuotationModel({
    required this.quotationId,
    required this.name,
    required this.orderLines,
    required this.colorMovements,
    required this.state,
    required this.partnerId,
    required this.partnerName,
    required this.createDate,
    required this.totalCount,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) => QuotationModel(
    quotationId: json['quotation_id'],
    name: json['name'] ?? '',
    state: json['state'] ?? '',
    partnerId: json['partner_id'],
    totalCount: json['total_count'],
    partnerName: json['partner_name'] ?? '',
    createDate: json['create_date'] ?? '',
    orderLines: List<OrderLineModel>.from(
      (json['order_lines'] ?? []).map(
            (x) => OrderLineModel.fromJson(x),
      ),
    ),
    colorMovements: List<ColorMovementModel>.from(
      (json['color_movements'] ?? []).map(
            (x) => ColorMovementModel.fromJson(x),
      ),
    ),
  );
}

@HiveType(typeId: 7)
class OrderLineModel {
  @HiveField(0)
  final num? orderLineId;

  @HiveField(1)
  final num? productTmplId;

  @HiveField(2)
  final String? productName;

  @HiveField(3)
  final String? barcode;

  @HiveField(4)
  final num? quantity;

  @HiveField(5)
  final List<OrderLineColorModel>? colorList;

  OrderLineModel({
    required this.orderLineId,
    required this.productTmplId,
    required this.productName,
    required this.barcode,
    required this.quantity,
    this.colorList,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) => OrderLineModel(
    orderLineId: json['order_line_id'],
    productTmplId: json['product_tmpl_id'],
    productName: json['product_name'] ?? '',
    barcode: json["barcode"].runtimeType==bool ? "": json['barcode'] ?? '',
    quantity: json['quantity'],
    colorList: List<OrderLineColorModel>.from(
      (json['color_list'] ?? []).map(
            (x) => OrderLineColorModel.fromJson(x),
      ),
    ),
  );
}

@HiveType(typeId: 13)
class OrderLineColorModel {
  @HiveField(0)
  final String? color;

  @HiveField(1)
  final String? colorHash;

  @HiveField(2)
  final num? qty;

  OrderLineColorModel({
    this.color,
    this.colorHash,
    this.qty,
  });

  factory OrderLineColorModel.fromJson(Map<String, dynamic> json) => OrderLineColorModel(
    color: json['color'] is bool ? null : json['color'],
    colorHash: json['color_hash'] is bool ? null : json['color_hash'],
    qty: json['qty'],
  );
}

@HiveType(typeId: 8)
class ColorMovementModel {
  @HiveField(0)
  final num? movementId;

  @HiveField(1)
  final num? productTmplId;

  @HiveField(2)
  final String? productName;

  @HiveField(3)
  final num? quantity;

  @HiveField(4)
  final num? capacity;

  @HiveField(5)
  final num? colorId;

  @HiveField(6)
  final String? colorName;

  @HiveField(7)
  final String? colorHash;

  @HiveField(8)
  final num? qtyAvailable;

  /// Total available quantity across all colours of this product
  /// (API field `all_qty`).
  @HiveField(9)
  final num? allQty;

  ColorMovementModel({
    required this.movementId,
    required this.productTmplId,
    required this.productName,
    required this.quantity,
    required this.capacity,
    this.colorId,
    required this.colorName,
    this.colorHash, this.qtyAvailable, this.allQty,
  });

  factory ColorMovementModel.fromJson(Map<String, dynamic> json) =>
      ColorMovementModel(
        movementId: json['movement_id'],
        productTmplId: json['product_tmpl_id'],
        productName: json['product_name'] ?? '',
        quantity: json['quantity'],
        capacity: json['capacity'],
        colorId: json['color_id'],
        qtyAvailable: json['qty_avaliable'],
        allQty: json['all_qty'],
        colorName: json['color_name'] ?? '',
        colorHash: json['color_hash'],
      );
}

@HiveType(typeId: 9)
class SaleOrderModel extends HiveObject {
  @HiveField(0)
  final num partnerId;
  @HiveField(1)
  final List<SaleOrderProductModel> colorMovements;

  SaleOrderModel({required this.partnerId, required this.colorMovements});

  Map<String, dynamic> toJson() => {
    "partner_id": partnerId,
    "color_movements": colorMovements.map((x) => x.toJson()).toList(),
  };
}

@HiveType(typeId: 10)
class SaleOrderProductModel {
  @HiveField(0)
  final num productId;
  @HiveField(1)
  final num? colorId;
  @HiveField(2)
  final num quantity;

  SaleOrderProductModel({
    required this.productId,
    this.colorId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    if (colorId != null) "color_id": colorId,
    "quantity": quantity,
  };
}

@HiveType(typeId: 11)
class UpdateSaleOrderModel extends HiveObject {
  @HiveField(0)
  final num saleOrderId;
  @HiveField(1)
  final List<UpdateSaleOrderProductModel> colorMovements;

  UpdateSaleOrderModel({required this.saleOrderId, required this.colorMovements});

  Map<String, dynamic> toJson() => {
    "sale_order_id": saleOrderId,
    "color_movements": colorMovements.map((x) => x.toJson()).toList(),
  };
}

@HiveType(typeId: 12)
class UpdateSaleOrderProductModel {
  @HiveField(0)
  final num productId;
  @HiveField(1)
  final num? colorId;
  @HiveField(2)
  final num quantity;

  UpdateSaleOrderProductModel({
    required this.productId,
    this.colorId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    if (colorId != null) "color_id": colorId,
    "quantity": quantity,
  };
}
