class PaginationModel {
  int pageNumber;
  int pageSize;
  int totalPages;
  List pages;

  PaginationModel(
      {this.pageNumber = 1,
      this.pageSize = 10,
      this.totalPages = 0,
      this.pages = const []});

  @override
  String toString() {
    return 'pageNumber: $pageNumber - pageSize: $pageSize - pages length: ${pages.length} -- totalPages:$totalPages';
  }
}
