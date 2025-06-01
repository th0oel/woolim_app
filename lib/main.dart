import 'package:flutter/material.dart';
final DraggableScrollableController _sheetController = DraggableScrollableController();

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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  late AnimationController _pulseController;
  final List<String> allSentences = [
    '안녕하세요',
    '감사합니다',
    '고민 중이에요',
    '잠시만요',
    '노래 듣고 있어요',
    '너무하시네요',
    '도와줄 수 있어요?',
    '아이스 아메리카노',
    '한잔',
    '마시고 갈게요'
  ];

  List<String> filteredSentences = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    filteredSentences = List.from(allSentences);
    _pulseController = AnimationController(

      vsync: this,
      duration: const Duration(milliseconds: 700),
      lowerBound: 0.9,
      upperBound: 1.1,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
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
    });
    if (_isListening) {
      _pulseController.forward();
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent, // 👈 바깥쪽 탭 감지 가능하게 함
        onTap: () {
          // 시트가 펼쳐져 있을 때만 자동으로 초기 위치로 복귀
          if (_sheetController.size > 0.13 + 0.01) {
            _sheetController.animateTo(
              0.13,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        },
        child: Stack(
          children: [
            // 상단 고정 Woolim 텍스트
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false,
                    );
                  },
                  child: const Text(
                    'Woolim',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            // 중앙 마이크 버튼 + 안내 텍스트
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: _isListening
                          ? const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFAED7D),
                      )
                          : const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color(0xFFEAE9E4),
                            Color(0xFFDAD8CF),
                          ],
                          radius: 0.8,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic,
                          color: Colors.black38,
                          size: 90,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isListening
                      ? ScaleTransition(
                    scale: _pulseController,
                    child: const Text(
                      '듣고 있습니다!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  )
                      : const Text(
                    '버튼을 누르면 음성 인식이 시작됩니다!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                ],
              ),
            ),

            // 아래 슬라이드 시트
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.13,
              minChildSize: 0.13,
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
                            width: 160,
                            height: 40,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFFAED7D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.star, size: 20, color: Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  '저장된 문장',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
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
                        if (filteredSentences.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Center(child: Text('일치하는 문장이 없습니다')),
                          )
                        else
                          ...filteredSentences.map(
                                (text) =>
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4),
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
      ),
    );
  }
}