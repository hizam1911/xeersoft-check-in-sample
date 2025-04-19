import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastNotificationService {
  final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

  static void showSuccessNotification(String message) {
    try {
      toastification.show(
        overlayState: ToastNotificationService().globalNavigatorKey.currentState?.overlay,
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: const Text('Success', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        description: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        alignment: Alignment.bottomRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        icon: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.green,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        showProgressBar: true,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: false,
      );
    } catch (e) {
      print("error when displaying success toast notification...");
      print("error: $e");
    }
  }

  static void showInfoNotification(String message) {
    try {
      toastification.show(
        overlayState: ToastNotificationService().globalNavigatorKey.currentState?.overlay,
        type: ToastificationType.info,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: const Text('Info', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        description: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        alignment: Alignment.bottomRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        icon: const Icon(
          Icons.info,
          color: Colors.blue,
        ),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.blue,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        showProgressBar: true,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: false,
      );
    } catch (e) {
      print("error when displaying info toast notification...");
      print("error: $e");
    }
  }

  static void showWarningNotification(String message) {
    try {
      toastification.show(
        overlayState: ToastNotificationService().globalNavigatorKey.currentState?.overlay,
        type: ToastificationType.warning,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: const Text('Warning', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        description: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        alignment: Alignment.bottomRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        icon: const Icon(
          Icons.warning,
          color: Colors.yellow,
        ),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.yellow,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        showProgressBar: true,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: false,
      );
    } catch (e) {
      print("error when displaying warning toast notification...");
      print("error: $e");
    }
  }

  static void showErrorNotification(String message) {
    try {
      toastification.show(
        overlayState: ToastNotificationService().globalNavigatorKey.currentState?.overlay,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        autoCloseDuration: const Duration(seconds: 5),
        title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),),
        description: Text(
          message,
          style: TextStyle(color: Colors.black),
        ),
        alignment: Alignment.bottomRight,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        icon: const Icon(
          Icons.error,
          color: Colors.red,
        ),
        showIcon: true, // show or hide the icon
        primaryColor: Colors.red,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        showProgressBar: true,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: false,
      );
    } catch (e) {
      print("error when displaying error toast notification...");
      print("error: $e");
    }
  }
}