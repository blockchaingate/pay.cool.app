class PaginationModel {
  int pageNumber;
  final int pageSize = 10;
  int totalPages;
  List pages;

  PaginationModel({int pageNumber, int pageSize, int totalPages, List pages}) {
    this.pageNumber = pageNumber ?? 1;

    this.totalPages = totalPages ?? 0;
    this.pages = pages ?? [];
  }

  @override
  String toString() {
    return 'pageNumber: $pageNumber - pageSize: $pageSize - pages length: ${pages.length} -- totalPages:$totalPages';
  }
}
