import Flutter
import UIKit
import Auth0

public class SwiftAuth0Plugin: NSObject, FlutterPlugin {
    var credentialsManager = CredentialsManager(authentication: Auth0.authentication())

    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "auth0", binaryMessenger: registrar.messenger())
        let instance = SwiftAuth0Plugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let dic = call.arguments as? [String: Any]
        
        switch(method) {
        case "login":
            let audience = dic!["audience"] as! String
            login(audience: audience, result: result)
            break
        case "getToken":
            getAccessToken(result: result)
            break
        case "isLoggedIn":
            result(getIsLoggedIn())
            break
        case "userInfo":
            let accessToken = dic!["accessToken"] as! String
            getUserInfo(accessToken: accessToken, flutterResult: result)
            break
        case "logout":
            credentialsManager.clear()
            result(true)
            break
        default:
            result(FlutterMethodNotImplemented)
            break
        }
        
    }
    
    private func getUserInfo(accessToken: String, flutterResult: @escaping FlutterResult) {
        Auth0.authentication().userInfo(withAccessToken: accessToken)
            .start{result in
                switch result {
                case .success(let profile):
                    let dic: [String : String?] = ["sub": profile.sub, "email": profile.email]
                    flutterResult(dic)
                    break
                case .failure(let error):
                    flutterResult(FlutterError(code: "USER_INFO_ERROR", message: error.localizedDescription, details: nil))
                    break
                }}
    }
    
    private func getIsLoggedIn() -> Bool {
        return credentialsManager.hasValid()
    }
    
    private func getAccessToken(result: @escaping FlutterResult) {
        credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                let message = error?.localizedDescription ?? ""
                print("Error getting accessToken : " + message )
                result(FlutterError(code: "ACCESS_TOKEN_ERROR", message: message, details: nil))
                return
            }
            // Valid credentials, you can access the token properties such as `idToken`, `accessToken`.
            result(credentials.accessToken)
        }
    }
    
    // Login with audience
    private func login(audience: String, result: @escaping FlutterResult) {
        Auth0.webAuth()
            .scope("openid profile offline_access email")
            .audience(audience)
            .start { res in
                switch res {
                case .success(let credentials):
                    self.credentialsManager.store(credentials: credentials)
                    print("Auth0: connected")
                    result(true)
                    break
                case .failure(let error):
                    print(error)
                    result(false)
                    break
                }
        }
    }
    
}
