import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/pages/MainPage.dart';
import 'package:project/pages/user/learning/ProblemPage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:project/pages/user/Mypage/MyPage.dart';
import 'dart:convert';

class ShortformPage extends StatefulWidget {
  final String selectedCategory;
  final int userId;
  final String apiUrl;
  final String profileImagePath;

  const ShortformPage({
    Key? key,
    required this.selectedCategory,
    required this.userId,
    required this.apiUrl, 
    required this.profileImagePath,
    required int scriptsId,
  }) : super(key: key);

  @override
  _ShortformPageState createState() => _ShortformPageState();
}

class _ShortformPageState extends State<ShortformPage> {
  late String selectedCategory;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isLoading = true;
  String videoUrl = '';
  final int scriptsId = 23;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    fetchVideoUrl(scriptsId);
  }

  Future<void> fetchVideoUrl(int scriptsId) async {
    final url = '${widget.apiUrl}/get_stream_video/$scriptsId';
    print('Fetching video URL from: $url'); // 디버깅 로그 추가
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String videoPath = responseData['video_url'];
        print('Received video path: $videoPath'); // 디버깅 로그 추가
        fetchStreamVideo(videoPath);
      } else {
        throw Exception('Failed to load video URL');
      }
    } catch (e) {
      print('Error fetching video URL: $e'); // 에러 로그 추가
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStreamVideo(String videoPath) async {
    final url = '${widget.apiUrl}/stream_mobile_video/$videoPath';
    print('Streaming video from: $url'); // 디버깅 로그 추가
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          videoUrl = json.decode(response.body);
          print('Received stream video URL: $videoUrl'); // 디버깅 로그 추가
          if (videoUrl.isNotEmpty) {
            _videoPlayerController = VideoPlayerController.network(videoUrl);
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              autoPlay: true,
              looping: true,
            );
          }
          isLoading = false;
        });
      } else {
        throw Exception('Failed to stream video');
      }
    } catch (e) {
      print('Error streaming video: $e'); // 에러 로그 추가
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double containerWidth = constraints.maxWidth * 0.8;
            double containerHeight = constraints.maxHeight * 0.65;

            return Stack(
              children: [
                Center(
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Align(
                      alignment: const Alignment(0, 0.3),
                      child: Container(
                        width: containerWidth,
                        height: containerHeight,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              width: 2,
                              color: Color(0xFF4399FF),
                            ),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          shadows: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : (_chewieController != null
                                        ? Chewie(
                                            controller: _chewieController!,
                                          )
                                        : const Text("No video available")),
                              ),
                            ),
                            const SizedBox(height: 50),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProblemPage(
                                      selectedCategory: selectedCategory,
                                      scriptsId: scriptsId,
                                      userId: widget.userId,
                                      apiUrl: widget.apiUrl,
                                      profileImagePath: widget.profileImagePath,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 20),
                              ),
                              child: const Text(
                                '문제 풀러 가기',
                                style: TextStyle(
                                  color: Color(0xFF4399FF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 50,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      'assets/img/backbtn.png',
                      width: 45,
                      height: 45,
                    ),
                  ),
                ),
                Positioned(
                  top: 68,
                  left: 55,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/img/circle.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        '오늘의 학습',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/img/backbtn.png',
              width: 24,
              height: 24,
            ),
            label: 'Back',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/img/homebtn.png',
              width: 28,
              height: 28,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/img/mypagebtn.png',
              width: 24,
              height: 24,
            ),
            label: 'My Page',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pop(context);
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(userId: widget.userId, apiUrl: widget.apiUrl, profileImagePath: widget.profileImagePath,),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyPage(userId: widget.userId, apiUrl: widget.apiUrl, profileImagePath: widget.profileImagePath,),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
