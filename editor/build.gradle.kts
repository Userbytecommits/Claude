plugins {
    kotlin("jvm")
    application
}

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

kotlin {
    jvmToolchain(11)
}

application {
    mainClass.set("dev.game.editor.EditorKt")
}

dependencies {
    implementation(project(":engine"))

    // JavaFX
    val javaFxVersion = "21.0.2"
    implementation("org.openjfx:javafx-controls:$javaFxVersion:linux")
    implementation("org.openjfx:javafx-fxml:$javaFxVersion:linux")
    implementation("org.openjfx:javafx-graphics:$javaFxVersion:linux")

    // Kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:1.9.22")

    // Serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")

    // Logging
    implementation("org.slf4j:slf4j-api:2.0.7")
    implementation("ch.qos.logback:logback-classic:1.4.11")

    // Testing
    testImplementation("junit:junit:4.13.2")
}

tasks.withType<JavaExec> {
    jvmArgs = listOf(
        "--module-path", classpath.asPath,
        "--add-modules", "javafx.controls,javafx.fxml"
    )
}
