// Replace your lib/components/card_scanner.dart with this working version:
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:camera/camera.dart' as cam;

class CardScanner extends StatefulWidget {
  final CameraDescription camera;
  final Function(String) onCardDetected;
  final VoidCallback onClose;

  const CardScanner({
    Key? key,
    required this.camera,
    required this.onCardDetected,
    required this.onClose,
  }) : super(key: key);

  @override
  _CardScannerState createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isDetecting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _startCardDetection();
      }
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _startCardDetection() {
    _startTimerDetection();
  }

  void _startTimerDetection() {
    // Mock detection after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted && !_isDetecting) {
        _isDetecting = true;
        // Generate a more realistic mock card number
        final mockCards = [
          '4532 1234 5678 9012', // Visa
          '5555 5555 5555 4444', // Mastercard
          '3782 822463 10005', // American Express
        ];
        final randomCard =
            mockCards[DateTime.now().millisecond % mockCards.length];
        widget.onCardDetected(randomCard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorView();
    }

    if (!_isInitialized) {
      return _buildLoadingView();
    }

    return _buildCameraView();
  }

  Widget _buildErrorView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Camera Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onClose,
              child: Text('Close'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Camera preview
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.previewSize!.height,
                height: _controller!.value.previewSize!.width,
                child: cam.CameraPreview(_controller!),
              ),
            ),
          ),

          // Scanning overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: CardScannerOverlay(),
            ),
          ),

          // Close button
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: widget.onClose,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Position your card within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isDetecting) ...[
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Scanning...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Card dimensions (credit card aspect ratio ~1.6:1)
    final cardWidth = size.width * 0.85;
    final cardHeight = cardWidth / 1.6;
    final left = (size.width - cardWidth) / 2;
    final top = (size.height - cardHeight) / 2;

    // Corner length
    final cornerLength = 25.0;

    // Draw corner brackets
    _drawCorner(canvas, paint, Offset(left, top), cornerLength, true, true);
    _drawCorner(canvas, paint, Offset(left + cardWidth, top), cornerLength,
        false, true);
    _drawCorner(canvas, paint, Offset(left, top + cardHeight), cornerLength,
        true, false);
    _drawCorner(canvas, paint, Offset(left + cardWidth, top + cardHeight),
        cornerLength, false, false);

    // Draw center guidelines (optional)
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1.0;

    // Horizontal center line
    canvas.drawLine(
      Offset(left + cardWidth * 0.2, top + cardHeight / 2),
      Offset(left + cardWidth * 0.8, top + cardHeight / 2),
      centerPaint,
    );
  }

  void _drawCorner(Canvas canvas, Paint paint, Offset corner, double length,
      bool isLeft, bool isTop) {
    final dx = isLeft ? 1 : -1;
    final dy = isTop ? 1 : -1;

    // Horizontal line
    canvas.drawLine(
      corner,
      Offset(corner.dx + (length * dx), corner.dy),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      corner,
      Offset(corner.dx, corner.dy + (length * dy)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
