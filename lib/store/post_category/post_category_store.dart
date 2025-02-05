import 'package:flybuy/models/post/post_category.dart';
import 'package:flybuy/service/helpers/request_helper.dart';
import 'package:flybuy/utils/debug.dart';
import 'package:flybuy/utils/query.dart';
import 'package:mobx/mobx.dart';

part 'post_category_store.g.dart';

class PostCategoryStore = PostCategoryStoreBase with _$PostCategoryStore;

abstract class PostCategoryStoreBase with Store {
  final String? key;

  // Request helper instance
  final RequestHelper _requestHelper;

  // store for handling errors
  // final ErrorStore errorStore = ErrorStore();

  // constructor:---------------------------------------------------------------
  PostCategoryStoreBase(this._requestHelper,
      {int? perPage, String? lang, this.key}) {
    if (perPage != null) _perPage = perPage;
    if (lang != null) _lang = lang;
    _reaction();
  }

  // store variables:-----------------------------------------------------------
  static ObservableFuture<List<PostCategory>> emptyPostCategoryResponse =
      ObservableFuture.value([]);

  @observable
  ObservableFuture<List<PostCategory>?> fetchPostCategoriesFuture =
      emptyPostCategoryResponse;

  @observable
  ObservableList<PostCategory> _postCategories =
      ObservableList<PostCategory>.of([]);

  @observable
  bool success = false;

  @observable
  int _nextPage = 1;

  @observable
  int _perPage = 10;

  @observable
  String _lang = '';

  @observable
  bool _canLoadMore = true;

  // computed:-------------------------------------------------------------------
  @computed
  bool get loading => fetchPostCategoriesFuture.status == FutureStatus.pending;

  @computed
  ObservableList<PostCategory> get postCategories => _postCategories;

  @computed
  bool get canLoadMore => _canLoadMore;

  @computed
  int get perPage => _perPage;

  @computed
  String get lang => _lang;

  // actions:-------------------------------------------------------------------
  @action
  Future<void> getPostCategories() async {
    Map<String, dynamic> qs = {
      "per_page": _perPage,
      'page': _nextPage,
      'lang': _lang,
    };
    final future = _requestHelper.getPostCategories(
        queryParameters: preQueryParameters(qs));
    fetchPostCategoriesFuture = ObservableFuture(future);
    return future.then((postCategories) {
      // Replace state in the first time or refresh
      if (_nextPage <= 1) {
        _postCategories = ObservableList<PostCategory>.of(postCategories!);
      } else {
        // Add posts when load more page
        _postCategories
            .addAll(ObservableList<PostCategory>.of(postCategories!));
      }

      // Check if can load more item
      if (postCategories.length >= _perPage) {
        _nextPage++;
      } else {
        _canLoadMore = false;
      }
    }).catchError((error) {
      avoidPrint(error);
      // errorStore.errorMessage = DioExceptionUtil.handleError(error);
    });
  }

  @action
  Future<void> refresh() {
    _canLoadMore = true;
    _nextPage = 1;
    _postCategories.clear();
    return getPostCategories();
  }

  // disposers:-----------------------------------------------------------------
  late List<ReactionDisposer> _disposers;

  void _reaction() {
    _disposers = [];
  }

  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
