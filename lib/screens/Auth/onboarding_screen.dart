import 'package:flutter/material.dart';
import 'package:heaven_book_app/themes/app_colors.dart';
import 'package:video_player/video_player.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/images/Logo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 360,
                width: 360,
                child:
                    _controller.value.isInitialized
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: VideoPlayer(_controller),
                        )
                        : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 46),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'BOOK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'HEAVEN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                //'Touch a book, reach a little piece of heaven',
                'Nơi sách chạm đến tâm hồn bạn',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppColors.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen1 extends StatelessWidget {
  const OnboardingScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Placeholder cho hình ảnh
              Container(
                height: 340,
                width: 340,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.asset(
                  'assets/images/Onboarding_1.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                'Welcome To\nHeaven Book',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: const Text(
                  //'Welcome to Heaven Book, your literary sanctuary! Explore endless stories, from classics to bestsellers',
                  'Chào mừng đến với Heaven Book, thiên đường sách của bạn! Khám phá vô vàn câu chuyện.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingScreen2 extends StatelessWidget {
  const OnboardingScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(painter: WavePainter()),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    height: 360,
                    width: 360,
                    child: Image.asset(
                      'assets/images/Onboarding_2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 160),
                  const Text(
                    //'Endless Book Choices',
                    'Vô vàn lựa chọn sách',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    //'From bestsellers to hidden gems, explore a world of books waiting to be discovered. Your perfect read is just a tap away!',
                    'Khám phá từ những cuốn sách nổi tiếng đến những tác phẩm ít người biết — cả thế giới sách đang chờ bạn!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Placeholder cho hình ảnh
              Container(
                height: 340,
                width: 340,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.asset(
                  'assets/images/Onboarding_3.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 60),
              const Text(
                //'Surprisingly\nLow Prices',
                'Giá cả bất ngờ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 4.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: const Text(
                  //'Discover a vast collection of books at unbeatable prices. Shop smart and enjoy reading without breaking the bank!',
                  'Khám phá kho sách khổng lồ với mức giá không thể hấp dẫn hơn. Mua sắm thông minh - đọc sách thỏa ga không lo về giá!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Get Started Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/init',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      elevation: 8,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      //'Get Started',
                      'Bắt đầu ngay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Màu trắng cho phần trên
    final whitePaint = Paint()..color = Colors.white;

    // Màu xanh cho phần dưới
    final bluePaint = Paint()..color = AppColors.primary;

    // Vẽ nền trắng phía trên (70% màn hình)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.7),
      whitePaint,
    );

    // Vẽ nền xanh phía dưới (30% màn hình)
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      bluePaint,
    );

    // Tạo đường sóng
    final wavePaint =
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.fill;

    final path = Path();

    // Điểm bắt đầu (điều chỉnh theo tỷ lệ 7:3)
    path.moveTo(0, size.height * 0.65);

    // Tạo sóng với nhiều điểm control
    final waveHeight =
        size.height * 0.06; // Chiều cao sóng (giảm từ 0.1 xuống 0.06)
    final waveLength = size.width / 3; // Chiều dài một chu kỳ sóng

    for (double x = 0; x <= size.width; x += waveLength) {
      path.quadraticBezierTo(
        x + waveLength * 0.25,
        size.height * 0.65 - waveHeight,
        x + waveLength * 0.5,
        size.height * 0.65,
      );
      path.quadraticBezierTo(
        x + waveLength * 0.75,
        size.height * 0.65 + waveHeight,
        x + waveLength,
        size.height * 0.65,
      );
    }

    // Đóng path để tạo vùng tô màu
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, wavePaint);

    // Thêm sóng nhỏ hơn để tạo hiệu ứng nhiều lớp
    final wave2Paint =
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.7)
          ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.66);

    for (double x = 0; x <= size.width; x += waveLength * 0.8) {
      path2.quadraticBezierTo(
        x + waveLength * 0.2,
        size.height * 0.66 - waveHeight * 0.5,
        x + waveLength * 0.4,
        size.height * 0.66,
      );
      path2.quadraticBezierTo(
        x + waveLength * 0.6,
        size.height * 0.66 + waveHeight * 0.5,
        x + waveLength * 0.8,
        size.height * 0.66,
      );
    }

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, wave2Paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
