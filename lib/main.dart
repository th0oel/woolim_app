import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> allSentences = [
    '안녕하세요, 무엇을 도와드릴까요?',
    '오늘 날씨 어때요?',
    '알람 설정해줘',
    '타이머 5분 맞춰줘',
    '불 꺼줘',
  ];

  List<String> filteredSentences = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false; // 음성 입력 상태

  @override
  void initState() {
    super.initState();
    filteredSentences = List.from(allSentences);
  }

  void _filterSentences(String query) {
    setState(() {
      filteredSentences =
          allSentences.where((sentence) => sentence.contains(query)).toList();
    });
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      // 여기에서 실제 음성 인식 시작/중지 로직 연결 가능
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 상단 고정 Woolim 텍스트
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Woolim',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // 중앙 마이크 버튼 + 안내 텍스트
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 기존 GestureDetector 안의 child: Container(...) 부분을 아래로 교체

                GestureDetector(
                  onTap: _toggleListening,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: _isListening
                        ? const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFAED7D), // 인식 중: 노란 배경
                    )
                        : const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Color(0xFFEAE9E4), // 바깥쪽
                          Color(0xFFDAD8CF), // 안쪽
                        ],
                        radius: 0.8,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mic,
                        color: Colors.black87,
                        size: 90,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  _isListening
                      ? '듣고 있습니다!'
                      : '버튼을 누르면 음성 인식이 시작됩니다!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // 아래 슬라이드 시트
          DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 6,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      TextField(
                        controller: _searchController,
                        onChanged: _filterSentences,
                        decoration: InputDecoration(
                          hintText: '문장 검색',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '저장된 문장',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (filteredSentences.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                              child: Text('일치하는 문장이 없습니다')),
                        )
                      else
                        ...filteredSentences.map(
                              (text) => Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 4),
                            child: Text(text),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
