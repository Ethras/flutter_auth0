package com.ethras.auth0

import android.app.Dialog
import com.auth0.android.Auth0
import com.auth0.android.authentication.AuthenticationException
import com.auth0.android.provider.AuthCallback
import com.auth0.android.provider.WebAuthProvider
import com.auth0.android.result.Credentials
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.auth0.android.authentication.AuthenticationAPIClient
import com.auth0.android.authentication.storage.SharedPreferencesStorage
import com.auth0.android.authentication.storage.CredentialsManager
import com.auth0.android.authentication.storage.CredentialsManagerException
import com.auth0.android.callback.BaseCallback


class Auth0Plugin(private val registrar: Registrar) : MethodCallHandler {
    private val account = Auth0(registrar.context())
    private val authentication = AuthenticationAPIClient(account)
    var manager = CredentialsManager(authentication, SharedPreferencesStorage(registrar.context()))

    val isLoggedIn
        get(): Boolean {
            return manager.hasValidCredentials()
        }


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "auth0")
            channel.setMethodCallHandler(Auth0Plugin(registrar))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        when (call.method) {
            "login" -> {
                val audience = call.argument<String>("audience") ?: ""
                val scheme = call.argument<String>("scheme") ?: "https"
                login(audience, scheme, result)
            }
            "logout" -> {
                manager.clearCredentials()
                result.success(true)
            }
            "getToken" -> {
                if (isLoggedIn) {
                    manager.getCredentials(object : BaseCallback<Credentials, CredentialsManagerException?> {
                        override fun onSuccess(payload: Credentials) {
                            manager.saveCredentials(payload)
                            registrar.activity().runOnUiThread {
                                result.success(payload.accessToken)
                            }
                        }

                        override fun onFailure(error: CredentialsManagerException?) {
                            registrar.activity().runOnUiThread {
                                result.error("Error getting credentials", error.toString(), null)
                            }
                        }
                    })
                } else {
                    registrar.activity().runOnUiThread {
                        result.error("No credentials", "Check if logged in", null)
                    }
                }
            }
            "isLoggedIn" -> {
                result.success(isLoggedIn)
            }
            else -> result.notImplemented()
        }
    }

    private fun login(audience: String, scheme: String, result: Result) {
        WebAuthProvider.init(account).apply {
            if (audience.isNotEmpty()) {
                withAudience(audience)
            }
        }
                .withScheme(scheme)
                .withScope("openid offline_access")
                .start(registrar.activity(), object : AuthCallback {
                    override fun onSuccess(credentials: Credentials) {
                        println("Connecté")
                        manager.saveCredentials(credentials)
                        println(credentials)
                        registrar.activity().runOnUiThread {
                            result.success(true)
                        }
                    }

                    override fun onFailure(dialog: Dialog) {
                        println("Echec")
                        registrar.activity().runOnUiThread {
                            result.success(false)
                        }
                    }

                    override fun onFailure(exception: AuthenticationException?) {
                        println("Echec ${exception?.description}")
                        registrar.activity().runOnUiThread {
                            result.success(false)
                        }
                    }
                })
    }
}

