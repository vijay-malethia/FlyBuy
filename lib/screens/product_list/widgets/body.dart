import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/constants/strings.dart';
import 'package:flybuy/mixins/mixins.dart';
import 'package:flybuy/models/brand/brand.dart';
import 'package:flybuy/models/product/product.dart';
import 'package:flybuy/models/product_category/product_category.dart';
import 'package:flybuy/screens/product_list/widgets/product_list.dart';
import 'package:flybuy/screens/search/search_feature.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/app_localization.dart';
import 'package:flybuy/widgets/flybuy_cart_icon.dart';
import 'package:ui/ui.dart';

class Body extends StatefulWidget {
  final List<Product>? products;
  final bool? loading;
  final String? searchKey;
  final bool? canLoadMore;
  final Function? refresh;
  final Function? getProducts;

  final Widget? heading;
  final Widget? filter;

  final ProductCategory? category;
  final Brand? brand;

  final Map<String, dynamic>? configs;

  final Map<String, dynamic>? styles;
  final double heightHeading;
  final Map? layout;

  const Body({
    Key? key,
    this.searchKey,
    this.products,
    this.loading,
    this.refresh,
    this.getProducts,
    this.canLoadMore,
    this.heading,
    this.filter,
    this.category,
    this.brand,
    this.configs,
    this.styles,
    this.heightHeading = 58,
    this.layout,
  }) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> with LoadingMixin, AppBarMixin {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients || widget.loading! || !widget.canLoadMore!)
      return;
    final thresholdReached =
        _controller.position.extentAfter < endReachedThreshold;

    if (thresholdReached) {
      widget.getProducts!();
    }
  }

  Widget buildAppbar(BuildContext context) {
    TranslateType translate = AppLocalizations.of(context)!.translate;
    bool enableCart = get(widget.configs, ['enableAppbarCart'], true);
    bool enableCenterTitle = get(widget.configs, ['enableCenterTitle'], true);
    String? appBarType =
        get(widget.configs, ['appBarType'], Strings.appbarFloating);
    // bool extendBodyBehindAppBar = get(widget.configs, ['extendBodyBehindAppBar'], true);
    bool enableAppbarCountProduct =
        get(widget.configs, ['enableAppbarCountProduct'], true);
    bool? enableAppbarSearch =
        get(widget.configs, ['enableAppbarSearch'], false);

    int? countBrand = widget.brand?.count;
    int countCategory = widget.category?.count ?? -1;
    int countItems = countBrand ?? countCategory;
    String translateCount =
        countItems > 2 ? 'product_list_items' : 'product_list_item';

    String? nameBrand = widget.brand?.name;
    String nameCategory =
        widget.category?.name ?? translate('product_list_products');
    String name = nameBrand ?? nameCategory;

    Widget title = Column(
      crossAxisAlignment: enableCenterTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        if (widget.searchKey != null) ...{
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Search results for ',
                ),
                TextSpan(
                  text: "${widget.searchKey}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        } else ...{
          Text(name),
        },
        if (widget.searchKey == null) ...{
          if (enableAppbarCountProduct && countItems > -1)
            Text(
              translate(translateCount, {'count': '$countItems'}),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        }
      ],
    );

    List<Widget> actions =
        (enableCart || enableAppbarSearch!) && widget.searchKey == null
            ? [
                if (enableAppbarSearch!)
                  const SearchFeature(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: Icon(
                        FeatherIcons.search,
                        size: 22,
                      ),
                    ),
                  ),
                if (enableCart) const FlybuyCartIcon(),
                const SizedBox(width: 12),
              ]
            : [Container()];
    return SliverAppBar(
      leading: leading(),
      title: title,
      floating: appBarType == Strings.appbarFloating,
      elevation: 0,
      primary: true,
      centerTitle: enableCenterTitle,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);

    double padHorizontal = layoutPadding;
    double widthView = mediaQuery.size.width - 2 * padHorizontal;

    List<Product> emptyProducts =
        List.generate(10, (index) => Product()).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      controller: _controller,
      slivers: [
        buildAppbar(context),
        SliverPersistentHeader(
          pinned: false,
          floating: true,
          delegate: StickyTabBarDelegate(
              child: widget.heading!, height: widget.heightHeading),
        ),
        if (widget.filter is Widget)
          widget.filter ?? const SliverToBoxAdapter(),
        if (widget.layout != null) ...[
          CupertinoSliverRefreshControl(
            onRefresh: widget.refresh as Future<void> Function()?,
            builder: buildAppRefreshIndicator,
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
                padHorizontal, itemPaddingLarge, padHorizontal, 0),
            sliver: ProductListLayout(
              products: widget.products ?? emptyProducts,
              loading: widget.loading ?? true,
              layout: widget.layout,
              styles: widget.styles,
              widthView: widthView,
            ),
          ),
          if (widget.loading!)
            SliverToBoxAdapter(
              child: buildLoading(context, isLoading: widget.canLoadMore!),
            ),
        ]
      ],
    );
  }
}
