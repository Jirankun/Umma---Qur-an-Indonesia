# ─── Umma ProGuard Rules ─────────────────────────────────────
# Keep all app classes
-keep class app.umma.aokaze.** { *; }

# Keep model/serialization classes
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep plugin classes used via reflection
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Suppress R8 warnings for Google Play Core missing classes
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.common.**
