# Flutter-specific rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepclassmembers class io.flutter.embedding.engine.FlutterJNI {
    public static <methods>;
    public static <fields>;
}

# Supabase/Gotrue/Postgrest rules
-keep class io.supabase.** { *; }
-keep class io.github.jan.supabase.** { *; }

# Keep models (jika ada)
-keep class com.catatan.Ingetin.models.** { *; }

# Aturan umum untuk menjaga anotasi
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers,allowshrinking,allowobfuscation class * {
    @kotlin.jvm.JvmField <fields>;
    @kotlin.jvm.JvmStatic <methods>;
}
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Rules for Google Play Core Library
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task