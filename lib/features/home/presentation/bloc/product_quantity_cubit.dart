import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';

class SelectedProduct {
  final ProductModel product;
  final ColorModel? color;
  final int quantity;

  SelectedProduct({
    required this.product,
    this.color,
    required this.quantity,
  });
}

class ProductQuantityState {
  final Map<String, SelectedProduct> selectedProducts; // Key: productTmplId_colorId

  ProductQuantityState({required this.selectedProducts});

  ProductQuantityState copyWith({Map<String, SelectedProduct>? selectedProducts}) {
    return ProductQuantityState(
      selectedProducts: selectedProducts ?? this.selectedProducts,
    );
  }

  int get totalQuantity => selectedProducts.values.fold(0, (sum, item) => sum + item.quantity);
}

class ProductQuantityCubit extends Cubit<ProductQuantityState> {
  ProductQuantityCubit() : super(ProductQuantityState(selectedProducts: {}));

  void updateQuantity(ProductModel product, ColorModel? color, String quantityStr) {
    final int quantity = int.tryParse(quantityStr) ?? 0;
    final String key = "${product.productTmplId}_${color?.colorId ?? 'no_color'}";
    
    final newSelected = Map<String, SelectedProduct>.from(state.selectedProducts);
    
    if (quantity > 0) {
      newSelected[key] = SelectedProduct(
        product: product,
        color: color,
        quantity: quantity,
      );
    } else {
      newSelected.remove(key);
    }
    
    emit(state.copyWith(selectedProducts: newSelected));
  }

  int getQuantity(num? productId, num? colorId) {
    final String key = "${productId}_${colorId ?? 'no_color'}";
    return state.selectedProducts[key]?.quantity ?? 0;
  }
}
