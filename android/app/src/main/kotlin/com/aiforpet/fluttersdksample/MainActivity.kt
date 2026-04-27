package com.aiforpet.fluttersdksample

import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.aiforpet.pet.check.EyeCameraActivity
import com.aiforpet.pet.check.SkinCameraActivity
import com.aiforpet.pet.check.ToothCameraActivity
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.Locale

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aiforpet.sdk/channel"
    private var pendingResult: MethodChannel.Result? = null
    private val SCAN_REQUEST_CODE = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "launchSdk") {
                pendingResult = result
                val petType = call.argument<String>("petType") ?: ""
                val partType = call.argument<String>("partType") ?: ""
                val enablesQuestionnaire = call.argument<Boolean>("enablesQuestionnaire") ?: true
                val enableResultView = call.argument<Boolean>("enableResultView") ?: true
                val authConfig = call.argument<String>("authConfig") ?: ""

                launchSdkActivity(petType, partType, enablesQuestionnaire, enableResultView, authConfig)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun launchSdkActivity(petType: String, partType: String, enablesQuestionnaire: Boolean, enableResultView: Boolean, authConfig: String) {
        val selectLang = getCurrentLanguageCategory()
        val guideBase = "https://resource-core.aiforpetcdn.com/sdk/guide/$selectLang/${petType.lowercase(Locale.ROOT)}/"
        
        var guideUrl = ""
        val activityClass = when (partType) {
            "EYE" -> {
                guideUrl = guideBase + "eye.html"
                EyeCameraActivity::class.java
            }
            "TEETH" -> {
                guideUrl = guideBase + "tooth.html"
                ToothCameraActivity::class.java
            }
            "EAR", "BODY", "FOOT" -> {
                guideUrl = guideBase + "skin.html"
                SkinCameraActivity::class.java
            }
            else -> null
        }

        if (activityClass == null) {
            pendingResult?.error("INVALID_PART", "Invalid partType", null)
            return
        }

        val intent = Intent(this, activityClass)
        
        val petAdditionalInfo = JSONObject()
        petAdditionalInfo.put("innerData", "innerData")

        val bundle = Bundle().apply {
            putString("petType", petType)
            putString("userId", "userId")
            putString("petId", "petId")
            putString("petBirthday", "2025-01-01")
            putString("petBreedName", "MBSMIN")
            putString("petGender", "M")
            putBoolean("enablesQuestionnaire", enablesQuestionnaire)
            putBoolean("enableResultView", enableResultView)
            putString("petAdditionalInfo", petAdditionalInfo.toString())
            putString("ttConf", authConfig)
            putString("guideUrl", guideUrl)
            
            if (partType == "EAR" || partType == "BODY" || partType == "FOOT") {
                val realPart = if (partType == "BODY") "BELLY" else partType
                putString("partType", realPart)
            }
        }
        intent.putExtras(bundle)
        startActivityForResult(intent, SCAN_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == SCAN_REQUEST_CODE) {
            if (resultCode == RESULT_OK && data != null) {
                val resultData = data.getStringExtra("result")
                if (resultData != null) {
                    pendingResult?.success(resultData)
                } else {
                    pendingResult?.error("NO_DATA", "No result data returned", null)
                }
            } else {
                pendingResult?.error("CANCELLED", "Scan cancelled or failed", null)
            }
            pendingResult = null
        }
    }

    private fun readAssetFile(context: Context, filename: String): String {
        val builder = StringBuilder()
        try {
            context.assets.open(filename).use { inputStream ->
                BufferedReader(InputStreamReader(inputStream)).use { reader ->
                    var line: String?
                    while (reader.readLine().also { line = it } != null) {
                        builder.append(line).append('\n')
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return builder.toString()
    }

    private fun getCurrentLanguageCategory(): String {
        val currentLocale = Locale.getDefault()
        val languageCode = currentLocale.language
        return when (languageCode) {
            "ko" -> "ko"
            "ja" -> "ja"
            else -> "en"
        }
    }
}
