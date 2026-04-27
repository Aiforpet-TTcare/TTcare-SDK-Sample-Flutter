# Native JNI safety net — preserves all native methods across libraries
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers class * {
    @androidx.annotation.Keep *;
}

# AIScan SDK (vendor-wide)
-keep class com.aiforpet.** { *; }
-keepclassmembers class com.aiforpet.** { *; }

# ONNX Runtime — JNI references unresolvable by R8 static analysis
-keep class ai.onnxruntime.** { *; }
-keepclassmembers class ai.onnxruntime.** { *; }
-keepattributes *Annotation*, Signature, Exception, InnerClasses

# Google AI Edge LiteRT (TFLite successor)
-keep class com.google.ai.edge.litert.** { *; }
-keepclassmembers class com.google.ai.edge.litert.** { *; }

# Legacy TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**
