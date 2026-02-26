package com.example.talkjs_core_flutter

import CoreFlutterApi
import CoreHostApi
import CreateUserParams
import FlutterError
import SetUserParams
import TalkSessionOptions
import UserOnlineSnapshot
import UserSnapshot
import com.talkjs.core.TalkSession
import com.talkjs.core.UserOnlineSubscription
import com.talkjs.core.UserRef
import com.talkjs.core.UserSubscription
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

private var flutterApi: CoreFlutterApi? = null

private class PigeonApiImplementation : CoreHostApi {
    private val scope = CoroutineScope(Dispatchers.Default)

    private var nextId = 0L
    private val sessions: MutableMap<Long, TalkSession> = mutableMapOf()
    private val users: MutableMap<Long, UserRef> = mutableMapOf()
    private val userSubscriptions: MutableMap<Long, UserSubscription> = mutableMapOf()
    private val userOnlineSubscriptions: MutableMap<Long, UserOnlineSubscription> = mutableMapOf()

    // Session
    override fun getTalkSession(options: TalkSessionOptions): Long {
        val sessionOptions = com.talkjs.core.TalkSessionOptions(
            appId = options.appId,
            userId = options.userId,
            token = options.token,
            forceCreateNew = options.forceCreateNew == true,
            signature = options.signature,
            apiUrls = options.apiUrls?.let {
                com.talkjs.core.ApiUrlOptions(
                    realtimeWsApiUrl = it.realtimeWsApiUrl,
                    internalHttpApiUrl = it.internalHttpApiUrl,
                    restApiHttpUrl = it.restApiHttpUrl,
                )
            },
            host = options.host,
            clientBuild = options.clientBuild,
        )

        val session = com.talkjs.core.getTalkSession(sessionOptions)

        val handle = nextId
        nextId += 1

        sessions[handle] = session
        users[handle] = session.currentUser

        return handle
    }

    override fun sessionDelete(handle: Long) {
        println("Kotlin: sessionDelete $handle")

        users.remove(handle)
        sessions.remove(handle)
    }

    override fun sessionUser(handle: Long, id: String): Long {
        val session = sessions[handle] ?: throw FlutterError(
            "null-error",
            "Invalid session handle $handle",
            "",
        )

        val ref = session.user(id)

        val userHandle = nextId
        nextId += 1

        users[userHandle] = ref

        return userHandle
    }

    // User
    override fun userDelete(handle: Long) {
        println("Kotlin: userDelete $handle")

        users.remove(handle)
    }

    override fun userGet(
        handle: Long, callback: (Result<UserSnapshot?>) -> Unit
    ) {
        val ref = users[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid user handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            val snapshot = ref.get()
            callback(
                Result.success(
                    snapshot?.let {
                        UserSnapshot(
                            id = it.id,
                            name = it.name,
                            custom = it.custom,
                            role = it.role,
                            locale = it.locale,
                            photoUrl = it.photoUrl,
                            welcomeMessage = it.welcomeMessage,
                        )
                    },
                )
            )
        }

    }

    override fun userSet(
        handle: Long, data: SetUserParams, callback: (Result<Unit>) -> Unit
    ) {
        val ref = users[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid user handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.set(
                com.talkjs.core.SetUserParams(
                    name = data.name,
                    custom = data.custom,
                    locale = data.locale,
                    photoUrl = data.photoUrl,
                    role = data.role,
                    welcomeMessage = data.welcomeMessage,
                    email = data.email,
                    phone = data.phone,
                    pushTokens = data.pushTokens,
                )
            )
            callback(Result.success(Unit))
        }

    }

    override fun userCreateIfNotExists(
        handle: Long,
        data: CreateUserParams,
        callback: (Result<Unit>) -> Unit,
    ) {
        val ref = users[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid user handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.createIfNotExists(
                com.talkjs.core.CreateUserParams(
                    name = data.name,
                    custom = data.custom,
                    locale = data.locale,
                    photoUrl = data.photoUrl,
                    role = data.role,
                    welcomeMessage = data.welcomeMessage,
                    email = data.email,
                    phone = data.phone,
                    pushTokens = data.pushTokens,
                )
            )
            callback(Result.success(Unit))
        }
    }

    override fun userDeleteFields(
        handle: Long, fields: List<String>, callback: (Result<Unit>) -> Unit
    ) {
        val ref = users[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid user handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.deleteFields(*fields.toTypedArray())
            callback(Result.success(Unit))
        }
    }

    override fun userSubscribe(handle: Long): Long {
        val ref = users[handle] ?: throw FlutterError(
            "null-error",
            "Invalid user handle $handle",
            "",
        )

        val subscriptionHandle = nextId
        nextId += 1

        val subscription = ref.subscribe { snapshot ->
            scope.launch(Dispatchers.Main) {
                flutterApi?.newUserSnapshot(
                    subscriptionHandle,
                    snapshot?.let {
                        UserSnapshot(
                            id = it.id,
                            name = it.name,
                            custom = it.custom,
                            role = it.role,
                            locale = it.locale,
                            photoUrl = it.photoUrl,
                            welcomeMessage = it.welcomeMessage,
                        )
                    },
                ) {}
            }
        }

        userSubscriptions[subscriptionHandle] = subscription

        return subscriptionHandle
    }

    override fun userSubscribeOnline(handle: Long): Long {
        val ref = users[handle] ?: throw FlutterError(
            "null-error",
            "Invalid user handle $handle",
            "",
        )

        val subscriptionHandle = nextId
        nextId += 1

        val subscription = ref.subscribeOnline { snapshot ->
            scope.launch(Dispatchers.Main) {
                flutterApi?.newUserOnlineSnapshot(
                    subscriptionHandle,
                    snapshot?.let {
                        UserOnlineSnapshot(
                            user = UserSnapshot(
                                id = it.user.id,
                                name = it.user.name,
                                custom = it.user.custom,
                                role = it.user.role,
                                locale = it.user.locale,
                                photoUrl = it.user.photoUrl,
                                welcomeMessage = it.user.welcomeMessage,
                            ),
                            isConnected = it.isConnected,
                        )
                    },
                ) {}
            }
        }

        userOnlineSubscriptions[subscriptionHandle] = subscription

        return subscriptionHandle

    }

    // UserSubscription
    override fun userSubscriptionDelete(handle: Long) {
        println("Kotlin: userSubscriptionDelete $handle")

        userSubscriptions.remove(handle)
    }

    override fun userSubscriptionUnsubscribe(handle: Long) {
        val subscription = userSubscriptions[handle] ?: throw FlutterError(
            "null-error",
            "Invalid user subscription handle $handle",
            "",
        )

        subscription.unsubscribe()
    }

    // UserOnlineSubscription
    override fun userOnlineSubscriptionDelete(handle: Long) {
        println("Kotlin: userOnlineSubscriptionDelete $handle")

        userOnlineSubscriptions.remove(handle)
    }

    override fun userOnlineSubscriptionUnsubscribe(handle: Long) {
        val subscription = userOnlineSubscriptions[handle] ?: throw FlutterError(
            "null-error",
            "Invalid user subscription handle $handle",
            "",
        )

        subscription.unsubscribe()
    }
}

class TalkjsCoreFlutterPlugin : FlutterPlugin {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val api = PigeonApiImplementation()
        CoreHostApi.setUp(binding.binaryMessenger, api)
        flutterApi = CoreFlutterApi(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        CoreHostApi.setUp(binding.binaryMessenger, null)
        flutterApi = null
    }
}
