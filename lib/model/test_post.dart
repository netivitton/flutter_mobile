class TestPost {
  String keyword;

  TestPost(this.keyword);

  TestPost.fromJson(Map<String, dynamic> json)
      : keyword = json['keyword']; // ผมสามารถเปลี่ยนชื่อไม่ต้องใช้ page ก็ได้
  Map<String, dynamic> toJson() => {'keyword': keyword};
}
