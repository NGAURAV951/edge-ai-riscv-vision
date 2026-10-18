# EDGE//AI Lab — Android app

A native Android app built with Kotlin and Jetpack Compose, matching the project's dark-neon animated website style. The interface includes an animated accelerator hero, signal-intensity slider, synthetic-frame viewer, preview prediction card, feature meters, architecture walkthrough, RTL-validation summary, and links to the source repository and website. The author credit is **Nikhil Gaurav**.

## Build the debug APK

Requirements: Java 17, Android SDK platform 35, and Gradle 8.9.

From the repository root:

~~~bash
gradle -p android-app assembleDebug
~~~

APK output:

~~~text
android-app/app/build/outputs/apk/debug/app-debug.apk
~~~

Or open the repository's **Actions → Android app build** workflow and download the edge-ai-lab-debug-apk artifact from a successful run. The artifact is a debug build for testing; it is not a Play Store release.

## Install on an Android phone

1. Download and extract app-debug.apk from the workflow artifact.
2. Transfer the APK to your phone or download it directly there.
3. Open the APK and allow installation from that source if Android asks.
4. Launch **EDGE//AI Lab**.

## Important model scope

The app is a native interactive prototype. The signal generator and preview classifier run inside the app to demonstrate the interface and feature visualization. They are **not** the project's actual Python inference engine and do not report real measured latency or FPGA performance. The app links to the repository and website; integration of the actual inference model into Android is a future milestone.
