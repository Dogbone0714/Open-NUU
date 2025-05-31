pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_PROJECT)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "android"
include(":app")

// This is needed to include Flutter as a module
apply(from = "${System.getenv("FLUTTER_ROOT")}/packages/flutter_tools/gradle/app_plugin_loader.gradle")
