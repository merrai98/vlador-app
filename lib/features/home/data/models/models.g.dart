// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PartnerResponseAdapter extends TypeAdapter<PartnerResponse> {
  @override
  final int typeId = 0;

  @override
  PartnerResponse read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartnerResponse(
      data: (fields[0] as List).cast<DataModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PartnerResponse obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerResponseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataModelAdapter extends TypeAdapter<DataModel> {
  @override
  final int typeId = 1;

  @override
  DataModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataModel(
      createdPartners: (fields[0] as List).cast<PartnerModel>(),
      updatedPartners: (fields[1] as List).cast<PartnerModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, DataModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.createdPartners)
      ..writeByte(1)
      ..write(obj.updatedPartners);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PartnerModelAdapter extends TypeAdapter<PartnerModel> {
  @override
  final int typeId = 2;

  @override
  PartnerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PartnerModel(
      partnerId: fields[0] as num?,
      partnerName: fields[1] as String?,
      capacities: (fields[2] as List).cast<CapacityModel>(),
      quotations: (fields[3] as List).cast<QuotationModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PartnerModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.partnerId)
      ..writeByte(1)
      ..write(obj.partnerName)
      ..writeByte(2)
      ..write(obj.capacities)
      ..writeByte(3)
      ..write(obj.quotations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CapacityModelAdapter extends TypeAdapter<CapacityModel> {
  @override
  final int typeId = 3;

  @override
  CapacityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CapacityModel(
      products: (fields[0] as List).cast<ProductModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CapacityModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.products);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CapacityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 4;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel(
      productTmplId: fields[0] as num?,
      productName: fields[1] as String?,
      barcode: fields[2] as String?,
      sequence: fields[3] as num?,
      capacity: fields[4] as num?,
      colors: (fields[5] as List).cast<ColorModel>(),
      qtyAvailable: fields[6] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.productTmplId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.barcode)
      ..writeByte(3)
      ..write(obj.sequence)
      ..writeByte(4)
      ..write(obj.capacity)
      ..writeByte(5)
      ..write(obj.colors)
      ..writeByte(6)
      ..write(obj.qtyAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ColorModelAdapter extends TypeAdapter<ColorModel> {
  @override
  final int typeId = 5;

  @override
  ColorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ColorModel(
      colorId: fields[0] as num?,
      colorName: fields[1] as String?,
      capacity: fields[2] as num?,
      sequence: fields[3] as num?,
      colorHash: fields[4] as String?,
      qtyAvailable: fields[5] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, ColorModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.colorId)
      ..writeByte(1)
      ..write(obj.colorName)
      ..writeByte(2)
      ..write(obj.capacity)
      ..writeByte(3)
      ..write(obj.sequence)
      ..writeByte(4)
      ..write(obj.colorHash)
      ..writeByte(5)
      ..write(obj.qtyAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuotationModelAdapter extends TypeAdapter<QuotationModel> {
  @override
  final int typeId = 6;

  @override
  QuotationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuotationModel(
      quotationId: fields[0] as num?,
      name: fields[1] as String?,
      orderLines: (fields[2] as List).cast<OrderLineModel>(),
      colorMovements: (fields[3] as List).cast<ColorMovementModel>(),
      state: fields[4] as String?,
      partnerId: fields[5] as num?,
      partnerName: fields[6] as String?,
      createDate: fields[7] as String?,
      totalCount: fields[8] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, QuotationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.quotationId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.orderLines)
      ..writeByte(3)
      ..write(obj.colorMovements)
      ..writeByte(4)
      ..write(obj.state)
      ..writeByte(5)
      ..write(obj.partnerId)
      ..writeByte(6)
      ..write(obj.partnerName)
      ..writeByte(7)
      ..write(obj.createDate)
      ..writeByte(8)
      ..write(obj.totalCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuotationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderLineModelAdapter extends TypeAdapter<OrderLineModel> {
  @override
  final int typeId = 7;

  @override
  OrderLineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderLineModel(
      orderLineId: fields[0] as num?,
      productTmplId: fields[1] as num?,
      productName: fields[2] as String?,
      barcode: fields[3] as String?,
      quantity: fields[4] as num?,
      colorList: (fields[5] as List?)?.cast<OrderLineColorModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderLineModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.orderLineId)
      ..writeByte(1)
      ..write(obj.productTmplId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.barcode)
      ..writeByte(4)
      ..write(obj.quantity)
      ..writeByte(5)
      ..write(obj.colorList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderLineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class OrderLineColorModelAdapter extends TypeAdapter<OrderLineColorModel> {
  @override
  final int typeId = 13;

  @override
  OrderLineColorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderLineColorModel(
      color: fields[0] as String?,
      colorHash: fields[1] as String?,
      qty: fields[2] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderLineColorModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.color)
      ..writeByte(1)
      ..write(obj.colorHash)
      ..writeByte(2)
      ..write(obj.qty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderLineColorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ColorMovementModelAdapter extends TypeAdapter<ColorMovementModel> {
  @override
  final int typeId = 8;

  @override
  ColorMovementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ColorMovementModel(
      movementId: fields[0] as num?,
      productTmplId: fields[1] as num?,
      productName: fields[2] as String?,
      quantity: fields[3] as num?,
      capacity: fields[4] as num?,
      colorId: fields[5] as num?,
      colorName: fields[6] as String?,
      colorHash: fields[7] as String?,
      qtyAvailable: fields[8] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, ColorMovementModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.movementId)
      ..writeByte(1)
      ..write(obj.productTmplId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.capacity)
      ..writeByte(5)
      ..write(obj.colorId)
      ..writeByte(6)
      ..write(obj.colorName)
      ..writeByte(7)
      ..write(obj.colorHash)
      ..writeByte(8)
      ..write(obj.qtyAvailable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorMovementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleOrderModelAdapter extends TypeAdapter<SaleOrderModel> {
  @override
  final int typeId = 9;

  @override
  SaleOrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleOrderModel(
      partnerId: fields[0] as num,
      colorMovements: (fields[1] as List).cast<SaleOrderProductModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, SaleOrderModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.partnerId)
      ..writeByte(1)
      ..write(obj.colorMovements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleOrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleOrderProductModelAdapter extends TypeAdapter<SaleOrderProductModel> {
  @override
  final int typeId = 10;

  @override
  SaleOrderProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleOrderProductModel(
      productId: fields[0] as num,
      colorId: fields[1] as num?,
      quantity: fields[2] as num,
    );
  }

  @override
  void write(BinaryWriter writer, SaleOrderProductModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.colorId)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleOrderProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UpdateSaleOrderModelAdapter extends TypeAdapter<UpdateSaleOrderModel> {
  @override
  final int typeId = 11;

  @override
  UpdateSaleOrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdateSaleOrderModel(
      saleOrderId: fields[0] as num,
      colorMovements: (fields[1] as List).cast<UpdateSaleOrderProductModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, UpdateSaleOrderModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.saleOrderId)
      ..writeByte(1)
      ..write(obj.colorMovements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSaleOrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UpdateSaleOrderProductModelAdapter
    extends TypeAdapter<UpdateSaleOrderProductModel> {
  @override
  final int typeId = 12;

  @override
  UpdateSaleOrderProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdateSaleOrderProductModel(
      productId: fields[0] as num,
      colorId: fields[1] as num?,
      quantity: fields[2] as num,
    );
  }

  @override
  void write(BinaryWriter writer, UpdateSaleOrderProductModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.colorId)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSaleOrderProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
