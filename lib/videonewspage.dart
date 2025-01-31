import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeNewsPage extends StatefulWidget {
  @override
  _YouTubeNewsPageState createState() => _YouTubeNewsPageState();
}

class _YouTubeNewsPageState extends State<YouTubeNewsPage> {
  final String apiKey = ""; // Replace with your valid API key

  final List<String> newsChannelIds = [
    "UCt4t-jeY85JegMlZ-E5UWtA", // Aaj Tak
    "UCIR2UdcU9cFfY5YPJ7Z_ztw", // ABP News
    "UCIvaYmXn910QMdemBG3v1pQ", // Zee News
    "UCjLEmnpCNeisMxy134KPwWw", // Republic Bharat
    "UC9CYT9gSNLevX5ey2_6CK0Q", // NDTV India
  ];

  List videos = [];
  bool isLoading = true;
  String? nextPageToken;
  int currentChannelIndex = 0;

  Future<void> fetchYouTubeVideos({bool loadMore = false}) async {
    setState(() => isLoading = true);

    if (currentChannelIndex >= newsChannelIds.length) return;

    String channelId = newsChannelIds[currentChannelIndex];
    String url =
        "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&order=date&maxResults=10&channelId=$channelId&key=$apiKey";

    if (nextPageToken != null && loadMore) {
      url += "&pageToken=$nextPageToken";
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          videos.addAll(
              data['items'].where((video) => video['id']['videoId'] != null));
          nextPageToken = data['nextPageToken'];

          if (nextPageToken == null) {
            currentChannelIndex++;
          }
        });
      } else {
        print("Failed to fetch videos for channel: $channelId");
      }
    } catch (e) {
      print("Error fetching videos: $e");
    }

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchYouTubeVideos();
  }

  void playVideo(String videoId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        padding: EdgeInsets.all(10),
        child: YoutubePlayer(
          controller: YoutubePlayerController(
            initialVideoId: videoId,
            flags: YoutubePlayerFlags(autoPlay: true, mute: false),
          ),
          showVideoProgressIndicator: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF0F1),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("News Videos",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
                color: Colors.white)),
        backgroundColor: Color(0xFF2C3E50),
        centerTitle: true,
        elevation: 5,
      ),
      body: videos.isEmpty
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollEndNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.pixels ==
              scrollInfo.metrics.maxScrollExtent &&
              nextPageToken != null) {
            fetchYouTubeVideos(loadMore: true);
          }
          return false;
        },
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: videos.length + (nextPageToken != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == videos.length) {
              return Center(child: CircularProgressIndicator());
            }

            final video = videos[index];
            final videoTitle = video['snippet']['title'];
            final videoId = video['id']['videoId'];
            final thumbnailUrl = video['snippet']['thumbnails']['high']['url'];
            final channelName = video['snippet']['channelTitle'];
            final publishedAt = video['snippet']['publishedAt']
                .toString()
                .split("T")[0];

            return Card(
              color: Colors.white, // White card for contrast
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => playVideo(videoId),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      child: Stack(
                        children: [
                          Image.network(
                            thumbnailUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 75,
                            left: MediaQuery.of(context).size.width / 2 - 30,
                            child: Icon(Icons.play_circle_fill,
                                color: Colors.white, size: 60),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          videoTitle,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                channelName,
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              "📅 $publishedAt",
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
