package com.yokaizen.app

import android.content.Context
import android.content.res.Configuration
import android.os.Bundle
import android.os.LocaleList
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "yokai_quiz_app/locale"
    private var currentLocale: Locale? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Colmi Ring Plugin will be registered automatically by Flutter

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setLocale" -> {
                    val localeString = call.argument<String>("locale")
                    if (localeString != null) {
                        try {
                            setAppLocale(localeString)
                            result.success("Locale set to $localeString")
                        } catch (e: Exception) {
                            result.error("LOCALE_ERROR", "Failed to set locale", e.message)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Locale cannot be null", null)
                    }
                }
                "getCurrentLocale" -> {
                    val current = currentLocale ?: Locale.getDefault()
                    result.success("${current.language}_${current.country}")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Check if we need to set a saved locale before calling super
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedLanguage = prefs.getString("flutter.language", null)

        if (savedLanguage != null) {
            val localeString = when (savedLanguage) {
                "ja" -> "ja_JP"
                "ko" -> "ko_KR"
                "en" -> "en_US"
                else -> "en_US"
            }
            setAppLocale(localeString)
        }

        super.onCreate(savedInstanceState)
    }

    private fun setAppLocale(localeString: String) {
        val parts = localeString.split("_")
        val language = parts[0]
        val country = if (parts.size > 1) parts[1] else language.uppercase()

        val locale = Locale(language, country)
        currentLocale = locale

        // AGGRESSIVE LOCALE SETTING - Multiple approaches

        // 1. Set as JVM default
        Locale.setDefault(locale)
        Locale.setDefault(Locale.Category.DISPLAY, locale)
        Locale.setDefault(Locale.Category.FORMAT, locale)

        // 2. Update app configuration
        val config = Configuration(resources.configuration)
        config.setLocale(locale)

        // 3. For Android 7.0+ (API 24+), also set locale list
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            val localeList = LocaleList(locale)
            LocaleList.setDefault(localeList)
            config.setLocales(localeList)
        }

        // 4. Apply to all possible contexts
        createConfigurationContext(config)
        applicationContext.createConfigurationContext(config)

        // 5. Force update resources (deprecated but necessary for RevenueCat)
        @Suppress("DEPRECATION")
        resources.updateConfiguration(config, resources.displayMetrics)

        // 6. Also update application context resources
        @Suppress("DEPRECATION")
        applicationContext.resources.updateConfiguration(config, applicationContext.resources.displayMetrics)

        println("MainActivity: AGGRESSIVELY set locale to $locale")
        println("MainActivity: Default locale: ${Locale.getDefault()}")
        println("MainActivity: Default display locale: ${Locale.getDefault(Locale.Category.DISPLAY)}")
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            println("MainActivity: Default locale list: ${LocaleList.getDefault()}")
        }
    }

    override fun attachBaseContext(newBase: Context) {
        // Check for saved locale preference and apply it before attaching base context
        val prefs = newBase.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val savedLanguage = prefs.getString("flutter.language", null)

        val contextWithLocale = if (savedLanguage != null) {
            val localeString = when (savedLanguage) {
                "ja" -> "ja_JP"
                "ko" -> "ko_KR"
                "en" -> "en_US"
                else -> "en_US"
            }

            val parts = localeString.split("_")
            val locale = Locale(parts[0], parts.getOrElse(1) { parts[0].uppercase() })

            Locale.setDefault(locale)

            val config = Configuration(newBase.resources.configuration)
            config.setLocale(locale)

            newBase.createConfigurationContext(config)
        } else {
            newBase
        }

        super.attachBaseContext(contextWithLocale)
    }
}