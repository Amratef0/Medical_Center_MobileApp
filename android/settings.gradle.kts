pluginManagement {
    val flutterSdkPath =
        run {
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
    // NOTE: مثبتة على AGP 8.11.x / Kotlin 2.2.x قصدا.
    // AGP 9.x ("built-in Kotlin") هي اللي flutter create بيحطها افتراضيا في Flutter 3.47،
    // بس شوية plugins (زي file_picker) لسه بتقفل تحتها، وAGP 9 متأكد منها لحد JDK 17/21 بس، مش 25.
    // 8.11.x كومبو مجرّب وشغال كويس مع JDK 17/21.
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
