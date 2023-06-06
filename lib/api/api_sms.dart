import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class ApiSMS {
  String username = 'AC6a67596188c0dc4c9b3a8183a663376e'; // SID do Twilio
  String password = 'f3a8cdbf4293bd6818fe8377c79dcce8'; // Token do Twilio

  String from = '+13612829466'; // Número do Twilio

  sendSMS({required String to, required String bodyMsg}) async {
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Uri uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/AC6a67596188c0dc4c9b3a8183a663376e/Messages.json'); // URL do Twilio

    Map<String, String> bodyData = {
      'To': to,
      'From': from,
      'Body': bodyMsg,
    };

    final response = await http.post(
      uri,
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: bodyData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      log('Resposta: ${response.body}');
    } else {
      log('Erro: ${response.statusCode}');
      throw 'Erro ao enviar SMS';
    }
  }
}
