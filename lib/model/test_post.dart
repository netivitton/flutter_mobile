class TestPost {
  String keyword;
  var page;
  TestPost(this.keyword, this.page);

  TestPost.fromJson(Map<String, dynamic> json)
      : keyword = json['keyword'], // ผมสามารถเปลี่ยนชื่อไม่ต้องใช้ page ก็ได้
        page = json['page'];
  Map<String, dynamic> toJson() => {'keyword': keyword, 'page': page};
}
