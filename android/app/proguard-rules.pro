# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Play Core library rules
-keep class com.google.android.play.core.** { *; }
-keep class * implements com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# LINE SDK rules
-keep class com.linecorp.** { *; }
-dontwarn com.linecorp.**
-keep class * extends com.linecorp.linesdk.internal.android.LineApiResponseCode { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses

# Kotlin specific rules
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-keepattributes *Annotation*, Signature, Exception

# Firebase and Google Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.auth.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keepattributes Signature
-keepattributes EnclosingMethod

# Google Sign-In specific rules
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class org.json.** { *; }

# Extended Google Sign-In rules
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.auth.api.identity.** { *; }
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keep class com.google.android.gms.auth.api.phone.** { *; }
-keep class com.google.android.gms.common.api.** { *; }
-keep class com.google.android.gms.common.internal.** { *; }
-keep class com.google.android.gms.common.ConnectionResult { *; }
-keep class com.google.android.gms.common.GoogleApiAvailability { *; }

# Keep all interfaces for Google Sign-In classes
-keep interface com.google.android.gms.auth.** { *; }
-keep interface com.google.android.gms.common.** { *; }
-keep interface com.google.android.gms.tasks.** { *; }

# Keep the google sign-in client class
-keep class com.google.android.gms.auth.api.signin.GoogleSignInClient { *; }
-keep class com.google.android.gms.auth.api.signin.GoogleSignInOptions { *; }
-keep class com.google.android.gms.auth.api.signin.GoogleSignInAccount { *; }
-keep class com.google.android.gms.auth.api.signin.GoogleSignInStatusCodes { *; }

# Prevent obfuscation of types where the compiler must have access to reflection APIs
-keepattributes InnerClasses, Signature, *Annotation*

# Additional Firebase Auth Rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keep class com.google.firebase.auth.FirebaseAuth { *; }
-keep class com.google.firebase.auth.FirebaseUser { *; }
-keep class com.google.firebase.auth.internal.** { *; }
-keep class com.google.firebase.auth.api.** { *; }

# Don't note any issues with unknown classes
-dontnote **

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve all LineSDK interfaces and their implementations
-keep interface com.linecorp.linesdk.** { *; }
-keep class * implements com.linecorp.linesdk.** { *; }

# Preserve proguard mappings for debugging
-printmapping mapping.txt

# Preserve metadata used for reflection
-keepattributes SourceFile,LineNumberTable,*Annotation*

# Fix for daemon communications
-keepclassmembers class * {
    public void <init>(...);
}

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }

# General Android
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep interfaces and enums from Play Core
-keep interface com.google.android.play.core.** { *; }
-keep enum com.google.android.play.core.** { *; }

# Prevent obfuscation of types which use @JsonAdapter
-keepnames @com.google.gson.annotations.JsonAdapter class *

# Additional Parcelable rules
-keepclassmembers class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator CREATOR;
} 