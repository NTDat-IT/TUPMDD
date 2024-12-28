import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tối ưu phầm mềm di động',
      theme: ThemeData(useMaterial3: true),
      home: const EnergyConsumptionScreen(),
    );
  }
}

class EnergyConsumptionScreen extends StatefulWidget {
  const EnergyConsumptionScreen({super.key});

  @override
  State<EnergyConsumptionScreen> createState() =>
      _EnergyConsumptionScreenState();
}

class _EnergyConsumptionScreenState extends State<EnergyConsumptionScreen> {
  static const platform = MethodChannel('com.example.power/battery');
  double _energyConsumed = 0.0; // Tổng năng lượng tiêu thụ (mAh)
  double _energyPerSecond = 0.0; // Năng lượng tiêu thụ trong 1 giây (mAh/s)
  double _currentNow = 0.0; // Dòng điện tiêu thụ (mA)
  Timer? _timer;
  int _timeElapsed = 0; // Số giây đo
  bool _isDarkMode = false; // Biến theo dõi chế độ sáng/tối

  Future<void> _getBatteryStats() async {
    try {
      final result =
          await platform.invokeMethod<Map<dynamic, dynamic>>('getBatteryStats');
      final currentNow = (result!['currentNow'] ?? 0).toDouble(); // µA
      setState(() {
        _currentNow = currentNow; // Dòng điện tiêu thụ trả về từ native
        _timeElapsed++;
        _energyPerSecond = _currentNow / 3600 / 1000; // Đổi mA thành mAh/s
        _energyConsumed +=
            _energyPerSecond; // Cộng dồn tổng năng lượng tiêu thụ
      });
    } on PlatformException catch (e) {
      print("Lỗi khi lấy thông tin pin: ${e.message}");
    }
  }

  @override
  void initState() {
    super.initState();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _getBatteryStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _resetValues() {
    setState(() {
      _timeElapsed = 0;
      _energyConsumed = 0.0;
      _energyPerSecond = 0.0;
      _currentNow = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        title: const Text('Energy Consumption Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Thời gian đo: $_timeElapsed s',
              style: TextStyle(
                  fontSize: 24,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            Text(
              'Tổng năng lượng tiêu thụ: ${_energyConsumed.toStringAsFixed(6)} mAh',
              style: TextStyle(
                  fontSize: 24,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            Text(
              'Năng lượng tiêu thụ trong 1 giây: ${_energyPerSecond.toStringAsFixed(6)} mAh/s',
              style: TextStyle(
                  fontSize: 20,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            Text(
              'Dòng điện tiêu thụ: ${(_currentNow / 1000).toStringAsFixed(2)} mA',
              style: TextStyle(
                  fontSize: 20,
                  color: _isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleTheme,
              child: Text(_isDarkMode ? 'Chuyển sang sáng' : 'Chuyển sang tối'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetValues,
              child: const Text('Làm mới'),
            ),
          ],
        ),
      ),
    );
  }
}

// ElevatedButton(
//   onPressed: fetchDataone, // Chuyển giữa các chế độ
//   child: const Text("1 sinh viên"),
// ),
// const SizedBox(
//   height: 20,
// ),
// ElevatedButton(
//   onPressed: fetchDataAll, // Chuyển giữa các chế độ
//   child: const Text("tất cả sinh viên"),
// ),

// Future<void> fetchDataone() async {
//   for (int i = 0; i < 60; i++) {
//     final response = await http
//         .get(Uri.parse('http://192.168.110.158/tupmdd/getdataone.php'));

//     if (response.statusCode == 200) {
//       // Nếu server trả về mã thành công (200)

//       SinhVienModel sinhVien =
//           SinhVienModel.fromJson(jsonDecode(response.body));
//       list1.add(sinhVien);
//       setState(() {});
//     } else {
//       // Nếu có lỗi khi gọi API
//       throw Exception('Failed to load data');
//     }
//   }
//   print(list1.length);
// }

// Future<void> fetchDataAll() async {
//   final response =
//       await http.get(Uri.parse('http://192.168.110.158/tupmdd/connect.php'));

//   if (response.statusCode == 200) {
//     // Nếu server trả về mã thành công (200)

//     List<SinhVienModel> sinhVienList =
//         SinhVienModel.fromJsonList(jsonDecode(response.body));
//     list2.addAll(sinhVienList);
//     setState(() {});
//   } else {
//     // Nếu có lỗi khi gọi API
//     throw Exception('Failed to load data');
//   }
//   print(list1.length);
// }

class SinhVienModel {
  String? id;
  String? name;
  String? mobile;
  String? age;

  // Constructor
  SinhVienModel({
    this.id,
    this.name,
    this.mobile,
    this.age,
  });

  // Phương thức để khởi tạo đối tượng từ JSON
  factory SinhVienModel.fromJson(Map<String, dynamic> json) {
    return SinhVienModel(
      id: json['id'],
      name: json['name'],
      mobile: json['mobile'],
      age: json['age'],
    );
  }

  // Phương thức để chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'age': age,
    };
  }

  // Phương thức từ JSON cho danh sách SinhVien
  static List<SinhVienModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((item) => SinhVienModel.fromJson(item)).toList();
  }
}
