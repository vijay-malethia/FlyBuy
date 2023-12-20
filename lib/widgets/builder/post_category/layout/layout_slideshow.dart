import 'package:flybuy/constants/constants.dart';
import 'package:flybuy/models/models.dart';
import 'package:flybuy/types/types.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter/material.dart';

class LayoutSlideshow extends StatefulWidget {
  final List<PostCategory>? categories;
  final BuildItemPostCategoryType? buildItem;
  final Color? indicatorColor;
  final Color? indicatorActiveColor;
  final EdgeInsetsDirectional padding;
  final double widthView;
  final double heightView;
  final double heightImage;

  const LayoutSlideshow({
    Key? key,
    this.categories,
    this.buildItem,
    this.indicatorColor,
    this.indicatorActiveColor,
    this.padding = EdgeInsetsDirectional.zero,
    this.widthView = 300,
    this.heightView = 200,
    this.heightImage = 200,
  }) : super(key: key);

  @override
  State<LayoutSlideshow> createState() => _LayoutSlideshowState();
}

class _LayoutSlideshowState extends State<LayoutSlideshow> {
  int pagination = 0;

  void changePagination(int value) {
    setState(() {
      pagination = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    double widthView =
        widget.widthView - widget.padding.end - widget.padding.start;

    double width = widthView;
    double height = widget.heightView;

    return Padding(
      padding: widget.padding,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Swiper(
          itemWidth: width,
          itemHeight: height,
          containerWidth: width,
          containerHeight: height,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: width,
              child: Column(
                children: [
                  widget.buildItem!(
                    context,
                    category: widget.categories![index],
                    width: width,
                    height: height,
                    heightImage: widget.heightImage,
                  ),
                ],
              ),
            );
          },
          itemCount: widget.categories!.length,
          curve: Curves.linear,
          pagination: SwiperPagination(
            margin: secondPaddingMedium,
            builder: DotSwiperPaginationBuilder(
              space: 4,
              activeSize: 6,
              size: 6,
              color: widget.indicatorColor,
              activeColor: widget.indicatorActiveColor,
            ),
          ),
          // onIndexChanged: (int value) => changePagination(value),
        ),
      ),
    );
  }
}
