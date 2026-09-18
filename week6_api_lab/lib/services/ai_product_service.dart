import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;

// --- ส่วนที่ 1: Model Class ---
class AiProduct {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  AiProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory AiProduct.fromJson(Map<String, dynamic> json) {
    return AiProduct(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }
}

// --- ส่วนที่ 2 & 3: API Functions & Error Handling ---

/// ฟังก์ชันดึงข้อมูลสินค้าทั้งหมด (List)
Future<List<AiProduct>> fetchAiProducts() async {
  final url = Uri.parse('https://fakestoreapi.com/products');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => AiProduct.fromJson(item)).toList();
    } else {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (รหัส: ${response.statusCode})');
    }
  } on TimeoutException {
    // [เหตุผล] ดักจับเมื่อเซิร์ฟเวอร์ไม่ตอบสนองภายในเวลาที่กำหนด (10 วินาที)
    // เพื่อไม่ให้แอปค้างรอนานเกินไปในกรณีที่เน็ตช้ามากหรือเซิร์ฟเวอร์ล่ม
    throw 'การเชื่อมต่อหมดเวลา กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่อีกครั้ง';
  } on http.ClientException {
    // [เหตุผล] ดักจับความผิดพลาดระดับ Network เช่น ลืมเปิด Wi-Fi, DNS มีปัญหา
    // หรือ Socket ถูกปิดกั้น เป็นการเช็กว่า "ส่งคำขอไปไม่ถึงเซิร์ฟเวอร์"
    throw 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อของคุณ';
  } on FormatException {
    // [เหตุผล] ดักจับเมื่อ jsonDecode พัง เช่น เซิร์ฟเวอร์ส่ง Error เป็นหน้า HTML 
    // แทนที่จะเป็น JSON หรือโครงสร้างข้อมูลผิดเพี้ยนไปจากที่ตกลงไว้
    throw 'ข้อมูลที่ได้รับจากเซิร์ฟเวอร์มีรูปแบบไม่ถูกต้อง';
  } catch (e) {
    // [เหตุผล] ดักจับ Error อื่นๆ ที่อยู่นอกเหนือความคาดหมายเพื่อความปลอดภัยของแอป
    throw 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง';
  }
}

/// 1. เพิ่มฟังก์ชันดึงข้อมูลสินค้าตาม ID (Single Item)
Future<AiProduct> fetchAiProductById(int id) async {
  final url = Uri.parse('https://fakestoreapi.com/products/$id');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      // ตรวจสอบกรณี API คืนค่าว่าง (FakeStoreAPI บางครั้งคืนค่าว่างถ้าไม่เจอ ID)
      if (response.body == 'null' || response.body.isEmpty) {
        throw Exception('ไม่พบข้อมูลสินค้านี้');
      }
      Map<String, dynamic> body = jsonDecode(response.body);
      return AiProduct.fromJson(body);
    } else if (response.statusCode == 404) {
      throw Exception('ไม่พบรหัสสินค้าที่ระบุ');
    } else {
      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (รหัส: ${response.statusCode})');
    }
  } on TimeoutException {
    // [เหตุผล] เพื่อป้องกัน UX ที่แย่เมื่อผู้ใช้ต้องรอหน้าโหลดหมุนค้างนานเกินไป 
    // โดยเฉพาะเวลาดึงรายละเอียดสินค้าที่ต้องการความเร็ว
    throw 'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง';
  } on http.ClientException {
    // [เหตุผล] จัดการกรณีที่ User อาจจะเดินเข้าจุดอับสัญญาณหรือเน็ตหลุดขณะกดดูสินค้า
    throw 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
  } on FormatException {
    // [เหตุผล] หาก API แก้ไขโครงสร้างข้อมูลกะทันหัน หรือส่งค่า null ในจุดที่ไม่ได้รองรับ
    // จะช่วยให้เราแจ้งเตือนผู้ใช้ได้ดีกว่าแอปค้าง (Crash)
    throw 'รูปแบบข้อมูลสินค้าไม่ถูกต้อง';
  } catch (e) {
    // [เหตุผล] ดักจับ Error ทั่วไป เช่น Exception ที่เรา throw เอง (เช่น 'ไม่พบข้อมูล')
    throw e.toString().contains('Exception:') ? e.toString().replaceAll('Exception: ', '') : 'เกิดข้อผิดพลาด กรุณาลองใหม่';
  }
}