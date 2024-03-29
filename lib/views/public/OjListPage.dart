/*
 * @Author: 18855190718 1491579574@qq.com
 * @Date: 2023-03-04 15:52:35
 * @LastEditors: SQS 1491579574@qq.com
 * @LastEditTime: 2023-05-27 18:53:03
 * @FilePath: \study_bug\lib\views\public\OjListPage.dart
 * @Description: Email:1491579574@qq.com
 * QQ:1491579574
 * Copyright (c) 2023 by ${git_name_email}, All Rights Reserved. 
 */
// OJ题库列表
// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:ltpp/assembly/KeepAliveWrapper.dart';
import 'package:ltpp/assembly/OjLine.dart';
import 'package:ltpp/assembly/MySearch.dart';
import '../../assembly/MyLoading.dart';
import '../../public/Global.dart';
import '../../public/Http.dart';

class OjListPage extends StatefulWidget {
  const OjListPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _OjListState createState() => _OjListState();
}

class _OjListState extends State<OjListPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool is_no_more = false;
  int page = 1;
  int limit = 50;
  // ignore: prefer_final_fields
  ScrollController _scrollController = ScrollController();
  List data = [];
  // ignore: non_constant_identifier_names
  bool _get_data = false;
  bool is_lock = false;

  _getData() async {
    if (!mounted) {
      return;
    }
    if (is_no_more || is_lock) {
      return;
    }
    is_lock = true;
    // ignore: non_constant_identifier_names, prefer_is_empty
    Map<String, dynamic> res = await Http.sendPost('/Oj/getProblemList',
        context: context, body: {'page': page, 'limit': limit});

    if (res['code'] == 1) {
      if (res['data'].length == 0) {
        is_no_more = true;
        setState(() {
          _get_data = true;
        });
        return;
      }
      ++page;
      setState(() {
        data.addAll(res['data']);
        _get_data = true;
      });
      is_lock = false;
    } else {
      is_no_more = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
    _scrollController.addListener(() {
      if (!is_no_more &&
          !is_lock &&
          _scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
        _getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: no_leading_underscores_for_local_identifiers, non_constant_identifier_names
    List<Widget> _view_list = [
      Padding(
          padding: const EdgeInsets.all(10),
          child: MySearch(new_page_name: 'OjSearchPage'))
    ];
    if (!_get_data) {
      return const MyLoading();
    }

    for (int i = 0; i < data.length; ++i) {
      _view_list.add(GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Global.toProblemPage(context, data[i]['id']),
          child: OjLine(
            title: data[i]['problemName'] ?? '',
            content: data[i]['problemLabe'] ?? '',
            tips: data[i]['problemFrom'] ?? '',
          )));
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            '题库',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: Global.app_bar_font_size),
          ),
          toolbarHeight: Global.app_bar_height,
          centerTitle: true),
      body: SafeArea(
          child: KeepAliveWrapper(
              child: ListView(
        controller: _scrollController,
        children: _view_list,
      ))),
    );
  }
}
