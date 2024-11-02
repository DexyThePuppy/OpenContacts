#include <windows.h>
#include <string>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/plugin_registrar_windows.h>

void RegisterMainThreadHandler(flutter::PluginRegistrarWindows* registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "platform_channel",
          &flutter::StandardMethodCodec::GetInstance());

  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "runOnMainThread") {
          // Get the function to run from arguments
          const auto* arguments = std::get_if<std::string>(call.arguments());
          if (arguments) {
            // Post the message to the main thread
            PostMessage(nullptr, WM_USER, 0, 0);
            result->Success();
          } else {
            result->Error("INVALID_ARGUMENTS", "Arguments must be a string");
          }
        } else {
          result->NotImplemented();
        }
      });
}