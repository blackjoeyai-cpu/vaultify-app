# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Hive adapters
-keep class * extends com.google.protobuf.GeneratedMessageLite { *; }

# Keep model classes
-keep class com.vaultify.vaultify.domain.** { *; }
-keep class com.vaultify.vaultify.data.model.** { *; }

# PointyCastle
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# General Android rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
