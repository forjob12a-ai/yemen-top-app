class AppBanner {
  final int id;
  final String? title;
  final String? subtitle;
  final String? imageUrl;
  final String? link;
  final String? buttonText;

  AppBanner({required this.id, this.title, this.subtitle, this.imageUrl, this.link, this.buttonText});

  factory AppBanner.fromJson(Map<String, dynamic> j) => AppBanner(
        id: j['id'],
        title: j['title'],
        subtitle: j['subtitle'],
        imageUrl: j['image_url'] ?? j['mobile_image_url'],
        link: j['link'],
        buttonText: j['button_text'],
      );
}
