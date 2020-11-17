import 'package:flutter/material.dart';
import 'customer.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

//import 'package:flutter/rendering.dart';

enum STATE {
  loading,
  success,
  error_response,
  error_dio,
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DynamicPart(),
    );
  }
}

class DynamicPart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DynamicState();
}

class DynamicState extends State<DynamicPart> {
  var messages = 1;

  List<Customer> customer = List();

  STATE state = STATE.loading;
  String errorMessage;
  int errorCode;
  DioError dioError;

  NumberFormat nfMoney = new NumberFormat("#,##0.00", "pt_BR");

  Dio createDio() {
    Dio dio = Dio(BaseOptions(
        connectTimeout: 5000, baseUrl: "http://192.168.1.31:8080/"));

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (RequestOptions request) async {
      request.headers["token"] = "";
      request.headers.forEach((key, value) {
        print("key $key");
        print("value $value");
      });
      return request;
    }, onResponse: (Response response) async {
      print("response.statusCode ${response.statusCode}");
      print("response.data ${response.data}");
      print("response.statusMessage ${response.statusMessage}");
      if (response.statusCode == 200) {
        setState(() {
          state = STATE.success;
        });
        response.data.forEach((value) {
          customer.add(Customer.fromJson(value));
        });
      } else {
        setState(() {
          state = STATE.error_response;
        });
        errorMessage = response.statusMessage;
        errorCode = response.statusCode;
      }
      return response;
    }, onError: (DioError error) async {
      print("error.error ${error.error}");
      print("error.message ${error.message}");
      print("error.type ${error.type.toString()}");
      dioError = error;
      setState(() {
        state = STATE.error_dio;
      });
      return error;
    }));

    return dio;
  }

  Future<Response> fetchItems() {
    return createDio().get("customer");
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Link"),
        leading: Icon(Icons.menu),
      ),
      body: Center(child: getWidgetCenter()),
    );
  }

  Widget getLoadingWidget() {
    return CircularProgressIndicator();
  }

  Widget getSuccessWidget() {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(
              '${customer[index].nome}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            leading: Text(index.toString()),
            subtitle: Text(
              '${customer[index].id}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        },
        itemCount: customer.length);
  }

  Widget getErrorResponse() {
    return Center(
      child: Column(
        children: <Widget>[
          Text("HTTP Status Code: ${errorCode}"),
          Text("Mensagem: ${errorMessage}"),
        ],
      ),
    );
  }

  Widget getErrorDio() {
    return Center(
      child: Column(
        children: <Widget>[
          Text("Código: ${dioError?.response?.statusCode ?? ''}"),
          Text("Mensagem: ${dioError.message}"),
        ],
      ),
    );
  }

  Widget getWidgetCenter() {
    if (state == STATE.loading) {
      return getLoadingWidget();
    } else if (state == STATE.success) {
      return getSuccessWidget();
    } else if (state == STATE.error_dio) {
      return getErrorDio();
    } else if (state == STATE.error_response) {
      return getErrorResponse();
    }
  }
}
