class VideoModel {
  String url;
  int category;
  String videoPath;
  VideoModel({this.url, this.category});

  VideoModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    category = json['category'];
    videoPath = json['videoPath'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['category'] = this.category;
    data['videoPath'] = this.videoPath;
    return data;
  }
}
