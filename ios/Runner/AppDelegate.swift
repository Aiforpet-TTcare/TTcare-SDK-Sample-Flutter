import AIScan
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private static let channelName = "com.aiforpet.sdk/channel"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)



    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: AppDelegate.channelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handle(call: call, result: result)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "launchSdk" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard let args = call.arguments as? [String: Any],
          let petTypeRaw = args["petType"] as? String,
          let partTypeRaw = args["partType"] as? String else {
      result(FlutterError(code: "INVALID_ARGS", message: "petType/partType required", details: nil))
      return
    }
    
    if let authConfigString = args["authConfig"] as? String,
       let authData = authConfigString.data(using: .utf8) {
      TTManager.configure(authFileData: authData)
    }

    let enableQuestionnaire = args["enablesQuestionnaire"] as? Bool ?? true
    let enableResultView = args["enableResultView"] as? Bool ?? true

    guard let petType = Self.petType(from: petTypeRaw) else {
      result(FlutterError(code: "INVALID_PET", message: "Unknown petType: \(petTypeRaw)", details: nil))
      return
    }
    guard let partType = Self.partType(from: partTypeRaw) else {
      result(FlutterError(code: "INVALID_PART", message: "Unknown partType: \(partTypeRaw)", details: nil))
      return
    }

    let guideUrl = Self.guideUrl(petType: petTypeRaw, partType: partTypeRaw)

    AIScanManager.showCamera(
      petType: petType,
      partType: partType,
      petBirthday: "2025-01-01",
      petGender: "M",
      guideUrl: guideUrl,
      enableResultView: enableResultView,
      enablesQuestionnaire: enableQuestionnaire,
      resultCompletion: { (scanResult: AIScanResult?, error: Error?) in
        if let error = error {
          result(FlutterError(code: "SCAN_ERROR", message: error.localizedDescription, details: nil))
          return
        }
        guard let scanResult = scanResult else {
          result(FlutterError(code: "NO_DATA", message: "No result data", details: nil))
          return
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(scanResult),
           let json = String(data: data, encoding: .utf8) {
          result(json)
        } else {
          result("{}")
        }
      }
    )
  }

  private static func petType(from raw: String) -> PetType? {
    switch raw.uppercased() {
    case "DOG": return .dog
    case "CAT": return .cat
    default: return nil
    }
  }

  private static func partType(from raw: String) -> PartType? {
    switch raw.uppercased() {
    case "EYE": return .eye
    case "TEETH": return .tooth
    case "EAR": return .ear
    case "BODY": return .belly
    case "FOOT": return .foot
    default: return nil
    }
  }

  private static func guideUrl(petType: String, partType: String) -> String {
    let lang: String
    switch Locale.current.languageCode {
    case "ko": lang = "ko"
    case "ja": lang = "ja"
    default: lang = "en"
    }
    let pet = petType.lowercased()
    let page: String
    switch partType.uppercased() {
    case "EYE": page = "eye.html"
    case "TEETH": page = "tooth.html"
    default: page = "skin.html"
    }
    return "https://resource-core.aiforpetcdn.com/sdk/guide/\(lang)/\(pet)/\(page)"
  }
}
