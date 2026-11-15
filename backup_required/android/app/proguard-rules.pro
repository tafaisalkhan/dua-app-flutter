# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# google_mobile_ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# audioplayers
-keep class xyz.luan.audioplayers.** { *; }

# Play Core (missing classes for R8)
-dontwarn com.google.android.play.core.**
