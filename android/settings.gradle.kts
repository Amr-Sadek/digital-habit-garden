// Remove conflicting ANDROID_PREFS_ROOT injected by IDE process environment
run {
    try {
        val pe = Class.forName("java.lang.ProcessEnvironment")
        val field = pe.getDeclaredField("theCaseInsensitiveEnvironment")
        field.isAccessible = true
        (field.get(null) as? MutableMap<*, *>)?.remove("ANDROID_PREFS_ROOT")
    } catch (_: Throwable) {}
    try {
        val pe = Class.forName("java.lang.ProcessEnvironment")
        val field = pe.getDeclaredField("theEnvironment")
        field.isAccessible = true
        (field.get(null) as? MutableMap<*, *>)?.remove("ANDROID_PREFS_ROOT")
    } catch (_: Throwable) {}
}

pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
