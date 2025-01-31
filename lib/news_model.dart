class News {
  final String title;
  final String description;
  final String urlToImage;
  final String content;
  final String publishedAt;
  final String url;
  final String? urlToVideo;  // New field for video URL (optional)

  News({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.publishedAt,
    required this.url,
    this.urlToVideo,  // Make this optional
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      title: json['title']?.toString() ?? 'No Title Available',
      description: json['description']?.toString() ?? 'No Description Available',
      urlToImage: json['urlToImage']?.toString() ?? 'https://beautyrepublicfdl.com/wp-content/uploads/2020/06/placeholder-image.jpg',
      content: json['content']?.toString() ?? 'Content not available',
      publishedAt: json['publishedAt']?.toString() ?? 'No Date Available',
      url: json['url']?.toString() ?? '#',
      urlToVideo: json['urlToVideo']?.toString(),  // Extract the video URL if available
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'urlToImage': urlToImage,
      'content': content,
      'publishedAt': publishedAt,
      'url': url,
      'urlToVideo': urlToVideo,  // Add video URL to the JSON output if available
    };
  }

  bool isImageValid() {
    return !urlToImage.contains('via.placeholder.com');
  }

  bool hasVideo() {
    return urlToVideo != null && urlToVideo!.isNotEmpty;
  }
}
