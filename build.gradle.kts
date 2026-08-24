plugins {
    kotlin("jvm") version "1.9.22" apply false
    id("com.android.application") version "8.1.4" apply false
    id("com.android.library") version "8.1.4" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
