import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/utils.dart';
import 'package:flybuy/widgets/flybuy_divider.dart';
import 'package:flybuy/widgets/flybuy_product_item.dart';
import 'package:flutter/material.dart';

class LayoutBigFirst extends StatelessWidget with LoadingMixin {
  final List<Product>? products;

  final Map<String, dynamic>? template;

  final BuildItemProductType? buildItem;
  final double? pad;
  final Color? dividerColor;
  final double? dividerHeight;
  final EdgeInsetsDirectional padding;
  final double widthView;

  final bool loading;
  final bool canLoadMore;
  final bool? enableLoadMore;
  final Function? onLoadMore;

  const LayoutBigFirst({
    Key? key,
    this.products,
    this.buildItem,
    this.pad = 0,
    this.dividerColor,
    this.dividerHeight = 1,
    this.padding = EdgeInsetsDirectional.zero,
    this.template,
    this.widthView = 300,
    this.loading = false,
    this.canLoadMore = false,
    this.enableLoadMore = false,
    this.onLoadMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (products!.isEmpty) return Container();
    TranslateType translate = AppLocalizations.of(context)!.translate;

    List<Product> productsData = List<Product>.of(products!);
    Product firstProduct = productsData.removeAt(0);

    double width = ConvertData.stringToDouble(
        get(template, ['data', 'size', 'width'], 100));
    double height = ConvertData.stringToDouble(
        get(template, ['data', 'size', 'height'], 100));

    double widthItem = widthView - padding.end - padding.start;
    double heightItem = (widthItem * height) / width;

    return Container(
      padding: padding,
      child: Column(
        children: [
          Column(
            children: [
              FirstItem(
                product: firstProduct,
                width: widthItem,
                height: heightItem,
                template: template,
              ),
              FlybuyDivider(
                  color: dividerColor, height: pad, thickness: dividerHeight),
            ],
          ),
          ...List.generate(
            productsData.length,
            (int index) {
              return Column(
                children: [
                  buildItem!(
                    context,
                    product: productsData[index],
                    width: widthItem,
                    height: heightItem,
                  ),
                  FlybuyDivider(
                      color: dividerColor,
                      height: pad,
                      thickness: dividerHeight),
                ],
              );
            },
          ),
          if (enableLoadMore! && canLoadMore)
            SizedBox(
              height: 34,
              width: 140,
              child: ElevatedButton(
                onPressed: onLoadMore as void Function()?,
                child: loading
                    ? entryLoading(context, size: 14, color: Colors.white)
                    : Text(translate('load_more')),
              ),
            )
        ],
      ),
    );
  }
}

class FirstItem extends StatelessWidget {
  final Product? product;
  final double? width;
  final double? height;

  final Map<String, dynamic>? template;

  const FirstItem({
    Key? key,
    this.product,
    this.width,
    this.height,
    this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FlybuyProductItem(
      product: product,
      width: screenWidth,
      height: (screenWidth * height!) / width!,
    );
  }
}
