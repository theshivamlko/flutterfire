// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:firebase_crashlytics_platform_interface/firebase_crashlytics_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

final List<MethodCall> methodCallLog = <MethodCall>[];

class MockFirebaseAppWithCollectionEnabled implements TestFirebaseCoreHostApi {
  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async {
    return CoreInitializeResponse(
      name: appName,
      options: CoreFirebaseOptions(
        apiKey: '123',
        projectId: '123',
        appId: '123',
        messagingSenderId: '123',
      ),
      pluginConstants: {
        'plugins.flutter.io/firebase_crashlytics': {
          'isCrashlyticsCollectionEnabled': true
        }
      },
    );
  }

  @override
  Future<List<CoreInitializeResponse>> initializeCore() async {
    return [
      CoreInitializeResponse(
        name: defaultFirebaseAppName,
        options: CoreFirebaseOptions(
          apiKey: '123',
          projectId: '123',
          appId: '123',
          messagingSenderId: '123',
        ),
        pluginConstants: {
          'plugins.flutter.io/firebase_crashlytics': {
            'isCrashlyticsCollectionEnabled': true
          }
        },
      )
    ];
  }

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async {
    return CoreFirebaseOptions(
      apiKey: '123',
      projectId: '123',
      appId: '123',
      messagingSenderId: '123',
    );
  }
}

void setupFirebaseCrashlyticsMocks([Callback? customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestFirebaseCoreHostApi.setUp(MockFirebaseAppWithCollectionEnabled());

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannelFirebaseCrashlytics.channel,
          (MethodCall methodCall) async {
    methodCallLog.add(methodCall);
    switch (methodCall.method) {
      case 'Crashlytics#checkForUnsentReports':
        return {
          'unsentReports': true,
        };
      case 'Crashlytics#setCrashlyticsCollectionEnabled':
        return {
          'isCrashlyticsCollectionEnabled': methodCall.arguments['enabled']
        };
      case 'Crashlytics#didCrashOnPreviousExecution':
        return {
          'didCrashOnPreviousExecution': true,
        };
      case 'Crashlytics#recordError':
        return null;
      default:
        return false;
    }
  });
}
