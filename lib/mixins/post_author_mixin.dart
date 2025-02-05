import 'package:flutter/material.dart';
import 'package:flybuy/models/post_author/post_author.dart';
import 'package:flybuy/types/types.dart';
import 'package:flybuy/utils/app_localization.dart';
import 'package:flybuy/widgets/flybuy_cache_image.dart';
import 'package:flybuy/widgets/flybuy_shimmer.dart';

mixin PostAuthorMixin {
  Widget buildName(
    ThemeData theme, {
    required PostAuthor author,
    Color? color,
    TextAlign textAlign = TextAlign.start,
  }) {
    if (author.id == null) {
      return FlybuyShimmer(
        child: Container(
          height: 24,
          width: 324,
          color: Colors.white,
        ),
      );
    }
    return Text(
      author.name!,
      style: theme.textTheme.titleMedium?.copyWith(color: color),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }

  Widget buildCount(
    BuildContext context, {
    ThemeData? theme,
    required PostAuthor author,
    Color? color,
    TextAlign textAlign = TextAlign.left,
  }) {
    if (author.id == null) {
      return FlybuyShimmer(
        child: Container(
          height: 12,
          width: 94,
          color: Colors.white,
        ),
      );
    }
    TranslateType translate = AppLocalizations.of(context)!.translate;
    String translateText =
        author.count! > 1 ? 'post_author_articles' : 'post_author_article';
    return Text(
      translate(translateText, {'count': '${author.count}'}).toUpperCase(),
      style: theme!.textTheme.labelSmall?.copyWith(color: color),
      textAlign: textAlign,
    );
  }

  Widget buildImage(
      {required PostAuthor author, double width = 70, double height = 70}) {
    double radius = width > height ? width / 2 : height / 2;
    BorderRadius borderRadius = BorderRadius.circular(radius);

    if (author.id == null) {
      return FlybuyShimmer(
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius,
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: borderRadius,
      child: FlybuyCacheImage(
        author.avatar?.medium ?? '',
        width: width,
        height: height,
      ),
    );
  }
}
