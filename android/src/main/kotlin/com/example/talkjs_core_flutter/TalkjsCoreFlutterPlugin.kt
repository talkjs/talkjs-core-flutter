package com.example.talkjs_core_flutter

import ConversationAccess
import ConversationSnapshot
import CoreFlutterApi
import CoreHostApi
import CreateConversationParams
import CreateParticipantParams
import CreateUserParams
import FlutterError
import MessageOrigin
import MessageSnapshot
import MessageType
import NotificationSettings
import ParticipantSnapshot
import ReactionSnapshot
import ReferencedMessageSnapshot
import SetConversationParams
import SetParticipantParams
import SetUserParams
import TalkSessionOptions
import UserOnlineSnapshot
import UserSnapshot
import com.talkjs.core.ConversationRef
import com.talkjs.core.ConversationSubscription
import com.talkjs.core.MessageRef
import com.talkjs.core.ParticipantRef
import com.talkjs.core.TalkSession
import com.talkjs.core.UserOnlineSubscription
import com.talkjs.core.UserRef
import com.talkjs.core.UserSubscription
import io.flutter.embedding.engine.plugins.FlutterPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.CoroutineStart
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

private fun makeUserSnapshot(snapshot: com.talkjs.core.UserSnapshot): UserSnapshot = UserSnapshot(
    id = snapshot.id,
    name = snapshot.name,
    custom = snapshot.custom,
    role = snapshot.role,
    locale = snapshot.locale,
    photoUrl = snapshot.photoUrl,
    welcomeMessage = snapshot.welcomeMessage,
)

private fun makeMessageType(type: com.talkjs.core.MessageType): MessageType = when (type) {
    com.talkjs.core.MessageType.USER_MESSAGE -> MessageType.USER_MESSAGE
    com.talkjs.core.MessageType.SYSTEM_MESSAGE -> MessageType.SYSTEM_MESSAGE
}

private fun makeMessageOrigin(origin: com.talkjs.core.MessageOrigin): MessageOrigin =
    when (origin) {
        com.talkjs.core.MessageOrigin.WEB -> MessageOrigin.WEB
        com.talkjs.core.MessageOrigin.REST -> MessageOrigin.REST
        com.talkjs.core.MessageOrigin.IMPORT -> MessageOrigin.IMPORT
        com.talkjs.core.MessageOrigin.EMAIL -> MessageOrigin.EMAIL
    }

private fun makeReactionSnapshot(snapshot: com.talkjs.core.ReactionSnapshot): ReactionSnapshot =
    ReactionSnapshot(
        emoji = snapshot.emoji,
        count = snapshot.count.toLong(),
        currentUserReacted = snapshot.currentUserReacted,
    )

private fun makeReferencedMessageSnapshot(snapshot: com.talkjs.core.ReferencedMessageSnapshot): ReferencedMessageSnapshot =
    ReferencedMessageSnapshot(
        id = snapshot.id,
        type = makeMessageType(snapshot.type),
        sender = snapshot.sender?.let { makeUserSnapshot(it) },
        custom = snapshot.custom,
        createdAt = snapshot.createdAt,
        editedAt = snapshot.editedAt,
        referencedMessageId = snapshot.referencedMessageId,
        origin = makeMessageOrigin(snapshot.origin),
        plaintext = snapshot.plaintext,
        reactions = snapshot.reactions.map { makeReactionSnapshot(it) },
    )

private fun makeMessageSnapshot(snapshot: com.talkjs.core.MessageSnapshot): MessageSnapshot =
    MessageSnapshot(
        id = snapshot.id,
        type = makeMessageType(snapshot.type),
        sender = snapshot.sender?.let { makeUserSnapshot(it) },
        custom = snapshot.custom,
        createdAt = snapshot.createdAt,
        editedAt = snapshot.editedAt,
        referencedMessage = snapshot.referencedMessage?.let { makeReferencedMessageSnapshot(it) },
        origin = makeMessageOrigin(snapshot.origin),
        plaintext = snapshot.plaintext,
        reactions = snapshot.reactions.map { makeReactionSnapshot(it) },
    )

private fun makeConversationAccess(access: com.talkjs.core.ConversationAccess): ConversationAccess =
    when (access) {
        com.talkjs.core.ConversationAccess.READ -> ConversationAccess.READ
        com.talkjs.core.ConversationAccess.READ_WRITE -> ConversationAccess.READ_WRITE
    }

private fun makeConversationAccess(access: ConversationAccess): com.talkjs.core.ConversationAccess =
    when (access) {
        ConversationAccess.READ -> com.talkjs.core.ConversationAccess.READ
        ConversationAccess.READ_WRITE -> com.talkjs.core.ConversationAccess.READ_WRITE
    }

private fun makeNotificationSettings(notify: com.talkjs.core.NotificationSettings): NotificationSettings =
    when (notify) {
        com.talkjs.core.NotificationSettings.TRUE -> NotificationSettings.YES
        com.talkjs.core.NotificationSettings.FALSE -> NotificationSettings.NO
        com.talkjs.core.NotificationSettings.MENTIONS_ONLY -> NotificationSettings.MENTIONS_ONLY
    }

private fun makeNotificationSettings(notify: NotificationSettings): com.talkjs.core.NotificationSettings =
    when (notify) {
        NotificationSettings.YES -> com.talkjs.core.NotificationSettings.TRUE
        NotificationSettings.NO -> com.talkjs.core.NotificationSettings.FALSE
        NotificationSettings.MENTIONS_ONLY -> com.talkjs.core.NotificationSettings.MENTIONS_ONLY
    }

private fun makeConversationSnapshot(snapshot: com.talkjs.core.ConversationSnapshot): ConversationSnapshot =
    ConversationSnapshot(
        id = snapshot.id,
        subject = snapshot.subject,
        photoUrl = snapshot.photoUrl,
        welcomeMessages = snapshot.welcomeMessages,
        custom = snapshot.custom,
        createdAt = snapshot.createdAt,
        joinedAt = snapshot.joinedAt,
        lastMessage = snapshot.lastMessage?.let { makeMessageSnapshot(it) },
        unreadMessageCount = snapshot.unreadMessageCount.toLong(),
        readUntil = snapshot.readUntil,
        everyoneReadUntil = snapshot.everyoneReadUntil,
        isUnread = snapshot.isUnread,
        access = makeConversationAccess(snapshot.access),
        notify = makeNotificationSettings(snapshot.notify),
        lastMessageAt = snapshot.lastMessageAt,
    )

private fun makeParticipantSnapshot(snapshot: com.talkjs.core.ParticipantSnapshot): ParticipantSnapshot =
    ParticipantSnapshot(
        user = makeUserSnapshot(snapshot.user),
        access = makeConversationAccess(snapshot.access),
        notify = makeNotificationSettings(snapshot.notify),
        joinedAt = snapshot.joinedAt,
    )

private var flutterApi: CoreFlutterApi? = null

private class PigeonApiImplementation : CoreHostApi {
    private val scope = CoroutineScope(Dispatchers.Default)

    private var nextId = 0L
    private val sessions: MutableMap<Long, TalkSession> = mutableMapOf()
    private val users: MutableMap<Long, UserRef> = mutableMapOf()
    private val userSubscriptions: MutableMap<Long, UserSubscription> = mutableMapOf()
    private val userOnlineSubscriptions: MutableMap<Long, UserOnlineSubscription> = mutableMapOf()
    private val conversations: MutableMap<Long, ConversationRef> = mutableMapOf()
    private val conversationSubscriptions: MutableMap<Long, ConversationSubscription> =
        mutableMapOf()
    private val participants: MutableMap<Long, ParticipantRef> = mutableMapOf()
    private val messages: MutableMap<Long, MessageRef> = mutableMapOf()

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

    override fun sessionDeleteHandle(handle: Long) {
        println("Kotlin: sessionDeleteHandle $handle")

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

    override fun sessionConversation(handle: Long, id: String): Long {
        val session = sessions[handle] ?: throw FlutterError(
            "null-error",
            "Invalid session handle $handle",
            "",
        )

        val ref = session.conversation(id)

        val conversationHandle = nextId
        nextId += 1

        conversations[conversationHandle] = ref

        return conversationHandle
    }

    // User
    override fun userDeleteHandle(handle: Long) {
        println("Kotlin: userDeleteHandle $handle")

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
            callback(Result.success(snapshot?.let { makeUserSnapshot(it) }))
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
                    snapshot?.let { makeUserSnapshot(it) },
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
                            user = makeUserSnapshot(it.user),
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
    override fun userSubscriptionDeleteHandle(handle: Long) {
        println("Kotlin: userSubscriptionDeleteHandle $handle")

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
    override fun userOnlineSubscriptionDeleteHandle(handle: Long) {
        println("Kotlin: userOnlineSubscriptionDeleteHandle $handle")

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

    // Conversation
    override fun conversationDeleteHandle(handle: Long) {
        println("Kotlin: conversationDeleteHandle $handle")

        conversations.remove(handle)
    }

    override fun conversationGet(
        handle: Long, callback: (Result<ConversationSnapshot?>) -> Unit
    ) {
        val ref = conversations[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid conversation handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            val snapshot = ref.get()
            callback(
                Result.success(snapshot?.let { makeConversationSnapshot(it) })
            )
        }
    }

    override fun conversationSet(
        handle: Long, data: SetConversationParams, callback: (Result<Unit>) -> Unit
    ) {
        val ref = conversations[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid conversation handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.set(
                com.talkjs.core.SetConversationParams(
                    subject = data.subject,
                    photoUrl = data.photoUrl,
                    welcomeMessages = data.welcomeMessages,
                    custom = data.custom,
                    access = data.access?.let { makeConversationAccess(it) },
                    notify = data.notify?.let { makeNotificationSettings(it) },
                )
            )
            callback(Result.success(Unit))
        }
    }

    override fun conversationCreateIfNotExists(
        handle: Long, data: CreateConversationParams, callback: (Result<Unit>) -> Unit
    ) {
        val ref = conversations[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid conversation handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.createIfNotExists(
                com.talkjs.core.CreateConversationParams(
                    subject = data.subject,
                    photoUrl = data.photoUrl,
                    welcomeMessages = data.welcomeMessages,
                    custom = data.custom,
                    access = data.access?.let { makeConversationAccess(it) },
                    notify = data.notify?.let { makeNotificationSettings(it) },
                )
            )
            callback(Result.success(Unit))
        }
    }

    override fun conversationDeleteFields(
        handle: Long, fields: List<String>, callback: (Result<Unit>) -> Unit
    ) {
        val ref = conversations[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid conversation handle $handle",
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

    override fun conversationParticipant(handle: Long, user: String): Long {
        val conversation = conversations[handle] ?: throw FlutterError(
            "null-error",
            "Invalid conversation handle $handle",
            "",
        )

        val ref = conversation.participant(user)

        val participantHandle = nextId
        nextId += 1

        participants[participantHandle] = ref

        return participantHandle
    }

    override fun conversationMessage(handle: Long, messageId: String): Long {
        val conversation = conversations[handle] ?: throw FlutterError(
            "null-error",
            "Invalid conversation handle $handle",
            "",
        )

        val ref = conversation.message(messageId)

        val messageHandle = nextId
        nextId += 1

        messages[messageHandle] = ref

        return messageHandle

    }

    override fun conversationSubscribe(handle: Long): Long {
        val ref = conversations[handle] ?: throw FlutterError(
            "null-error",
            "Invalid conversation handle $handle",
            "",
        )

        val subscriptionHandle = nextId
        nextId += 1

        val subscription = ref.subscribe { snapshot ->
            scope.launch(Dispatchers.Main) {
                flutterApi?.newConversationSnapshot(
                    subscriptionHandle,
                    snapshot?.let { makeConversationSnapshot(it) },
                ) {}
            }
        }

        conversationSubscriptions[subscriptionHandle] = subscription

        return subscriptionHandle
    }

    // ConversationSubscription
    override fun conversationSubscriptionDeleteHandle(handle: Long) {
        println("Kotlin: conversationSubscriptionDeleteHandle $handle")

        conversationSubscriptions.remove(handle)
    }

    override fun conversationSubscriptionUnsubscribe(handle: Long) {
        val subscription = conversationSubscriptions[handle] ?: throw FlutterError(
            "null-error",
            "Invalid conversation subscription handle $handle",
            "",
        )

        subscription.unsubscribe()
    }

    // Participant
    override fun participantDeleteHandle(handle: Long) {
        println("Kotlin: participantDeleteHandle $handle")

        participants.remove(handle)
    }

    override fun participantGet(
        handle: Long, callback: (Result<ParticipantSnapshot?>) -> Unit
    ) {
        val ref = participants[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid participant handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            val snapshot = ref.get()
            callback(
                Result.success(snapshot?.let { makeParticipantSnapshot(it) })
            )
        }
    }

    override fun participantSet(
        handle: Long, data: SetParticipantParams, callback: (Result<Unit>) -> Unit
    ) {
        val ref = participants[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid participant handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.set(
                com.talkjs.core.SetParticipantParams(
                    access = data.access?.let { makeConversationAccess(it) },
                    notify = data.notify?.let { makeNotificationSettings(it) },
                )
            )
            callback(Result.success(Unit))
        }
    }

    override fun participantEdit(
        handle: Long, data: SetParticipantParams, callback: (Result<Unit>) -> Unit
    ) {
        val ref = participants[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid participant handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.edit(
                com.talkjs.core.SetParticipantParams(
                    access = data.access?.let { makeConversationAccess(it) },
                    notify = data.notify?.let { makeNotificationSettings(it) },
                )
            )
            callback(Result.success(Unit))
        }
    }

    override fun participantCreateIfNotExists(
        handle: Long, data: CreateParticipantParams, callback: (Result<Unit>) -> Unit
    ) {
        val ref = participants[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid participant handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.createIfNotExists(
                com.talkjs.core.CreateParticipantParams(
                    access = data.access?.let { makeConversationAccess(it) },
                    notify = data.notify?.let { makeNotificationSettings(it) },
                )
            )
            callback(Result.success(Unit))
        }
    }

    override fun participantDeleteFields(
        handle: Long, fields: List<String>, callback: (Result<Unit>) -> Unit
    ) {
        val ref = participants[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid participant handle $handle",
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

    override fun participantDelete(
        handle: Long, callback: (Result<Unit>) -> Unit
    ) {
        val ref = participants[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid participant handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.delete()
            callback(Result.success(Unit))
        }
    }

    override fun messageDeleteHandle(handle: Long) {
        println("Kotlin: messageDeleteHandle $handle")

        messages.remove(handle)
    }

    override fun messageGet(
        handle: Long, callback: (Result<MessageSnapshot?>) -> Unit
    ) {
        val ref = messages[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid message handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            val snapshot = ref.get()
            callback(
                Result.success(snapshot?.let { makeMessageSnapshot(it) })
            )
        }
    }

    override fun messageEdit(
        handle: Long, params: String, callback: (Result<Unit>) -> Unit
    ) {
        val ref = messages[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid message handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.edit(params)
            callback(Result.success(Unit))
        }
    }

    override fun messageDeleteFields(
        handle: Long, fields: List<String>, callback: (Result<Unit>) -> Unit
    ) {
        val ref = messages[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid message handle $handle",
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

    override fun messageDelete(
        handle: Long, callback: (Result<Unit>) -> Unit
    ) {
        val ref = messages[handle]
        if (ref == null) {
            callback(
                Result.failure(
                    FlutterError(
                        "null-error",
                        "Invalid message handle $handle",
                        "",
                    )
                )
            )
            return
        }

        scope.launch(start = CoroutineStart.UNDISPATCHED) {
            ref.delete()
            callback(Result.success(Unit))
        }
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
