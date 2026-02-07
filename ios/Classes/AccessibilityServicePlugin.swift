import Flutter
import UIKit

public class AccessibilityServicePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let eventChannel = FlutterEventChannel(name: "accessibility_service/announcement_state", binaryMessenger: registrar.messenger())

    let instance = AccessibilityServicePlugin()
    eventChannel.setStreamHandler(instance)
  }

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(announcementDidFinish(_:)),
      name: UIAccessibility.announcementDidFinishNotification,
      object: nil
    )

    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(self)
    self.eventSink = nil

    return nil
  }

  @objc private func announcementDidFinish(_ notification: Notification) {
      eventSink?(nil)
  }
}
