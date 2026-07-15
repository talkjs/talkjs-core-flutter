import 'dart:convert';
import 'package:collection/collection.dart';

const _mapEquality = MapEquality<String, String?>();
const _listEquality = ListEquality<dynamic>();

// TODO: String | Entity
typedef EntityTreeNode = Object;

/// A multi-root tree describing the formatting and logical entities within a message.
typedef EntityTree = List<EntityTreeNode>;

/// Base class for all entity tree nodes that are not plain strings.
///
/// @public
sealed class Entity {
  const Entity();
  String get type;
  Map<String, dynamic> toJson();
}

/// An entity that renders its children with a specific style.
sealed class EntityWithChildren extends Entity {
  const EntityWithChildren();
  List<EntityTreeNode> get children;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'children': children.map(_serializeEntityTreeNode).toList(),
  };
}

/// A node in a [TextBlock] that renders its children with a specific style.
///
/// @public
final class Markup extends EntityWithChildren {
  /// The kind of formatting to apply when rendering the children
  ///
  /// - `type: "bold"` is used when users type `*text*` and is rendered with HTML `<strong>`
  ///
  /// - `type: "italic"` is used when users type `_text_` and is rendered with HTML `<em>`
  ///
  /// - `type: "strikethrough"` is used when users type `~text~` and is rendered with HTML `<s>`
  @override
  final String type;

  @override
  final List<EntityTreeNode> children;

  const Markup({required this.type, required this.children});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Markup &&
        type == other.type &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(type, _listEquality.hash(children));
}

final class Blockquote extends EntityWithChildren {
  @override
  final String type = 'blockquote';

  @override
  final List<EntityTreeNode> children;

  const Blockquote({required this.children});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Blockquote &&
        type == other.type &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(type, _listEquality.hash(children));
}

/// A node in a [TextBlock] that adds indentation for a bullet-point list around its children (HTML `<ul>`).
///
/// @remarks
/// Used when users send a bullet-point list by starting lines of their message with `-` or `*`.
///
/// @public
final class BulletList extends EntityWithChildren {
  @override
  final String type = 'bulletList';

  @override
  final List<EntityTreeNode> children;

  const BulletList({required this.children});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BulletList &&
        type == other.type &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(type, _listEquality.hash(children));
}

/// A node in a [TextBlock] that renders its children with a bullet-point (HTML `<li>`).
///
/// @remarks
/// Used when users start a line of their message with `-` or `*`.
///
/// @public
final class BulletPoint extends EntityWithChildren {
  @override
  final String type = 'bulletPoint';

  @override
  final List<EntityTreeNode> children;

  const BulletPoint({required this.children});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is BulletPoint &&
        type == other.type &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(type, _listEquality.hash(children));
}

sealed class Clickable extends EntityWithChildren {
  const Clickable();
}

/// A node in a [TextBlock] that renders its children as a clickable link (HTML `<a>`).
///
/// @remarks
/// By default, users do not have permission to send messages containing [Link] as it can be used to maliciously hide the true destination of a link.
///
/// @public
final class Link extends Clickable {
  @override
  final String type = 'link';

  /// The URL to open when the node is clicked.
  final String url;

  @override
  final List<EntityTreeNode> children;

  const Link({required this.url, required this.children});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    'children': children.map(_serializeEntityTreeNode).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Link &&
        type == other.type &&
        url == other.url &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(type, url, _listEquality.hash(children));
}

/// A node in a [TextBlock] that renders its children as a clickable [action link](https://talkjs.com/docs/Guides/JavaScript/Classic/Action_Buttons_Links/) which triggers a custom action.
///
/// @remarks
/// By default, users do not have permission to send messages containing [ActionLink] as it can be used maliciously to trick others into invoking custom actions.
/// For example, a user could send an "accept offer" action link, but disguise it as a link to a website.
///
/// @public
final class ActionLink extends Clickable {
  @override
  final String type = 'actionLink';

  /// The name of the custom action to invoke when the link is clicked.
  final String action;

  /// The parameters to pass to the custom action.
  final Map<String, String> params;

  @override
  final List<EntityTreeNode> children;

  const ActionLink({
    required this.action,
    required this.params,
    required this.children,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'action': action,
    'params': params,
    'children': children.map(_serializeEntityTreeNode).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ActionLink &&
        type == other.type &&
        action == other.action &&
        _mapEquality.equals(params, other.params) &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(
    type,
    action,
    _mapEquality.hash(params),
    _listEquality.hash(children),
  );
}

/// A node in a [TextBlock] that renders its children as a clickable [action button](https://talkjs.com/docs/Guides/JavaScript/Classic/Action_Buttons_Links/) which triggers a custom action.
///
/// @remarks
/// By default, users do not have permission to send messages containing action buttons as they can be used maliciously to trick others into invoking custom actions.
/// For example, a user could send an "accept offer" action button, but disguise it as "view offer".
///
/// @public
final class ActionButton extends Clickable {
  @override
  final String type = 'actionButton';

  /// The name of the custom action to invoke when the button is clicked.
  final String action;

  /// The parameters to pass to the custom action.
  final Map<String, String> params;

  @override
  final List<EntityTreeNode> children;

  const ActionButton({
    required this.action,
    required this.params,
    required this.children,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'action': action,
    'params': params,
    'children': children.map(_serializeEntityTreeNode).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ActionButton &&
        type == other.type &&
        action == other.action &&
        _mapEquality.equals(params, other.params) &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(
    type,
    action,
    _mapEquality.hash(params),
    _listEquality.hash(children),
  );
}

sealed class Leaf extends Entity {
  const Leaf();
  String get text;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};
}

final class CodeBlock extends Leaf {
  @override
  final String type = 'codeBlock';

  @override
  final String text;

  final String? language;

  const CodeBlock({required this.text, this.language});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    'language': language,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CodeBlock &&
        type == other.type &&
        text == other.text &&
        language == other.language;
  }

  @override
  int get hashCode => Object.hash(type, text, language);
}

/// A node in a [TextBlock] that renders `text` in an inline code span (HTML `<code>`).
///
/// @remarks
/// Used when a user types ` ```text``` `.
///
/// @public
final class CodeSpan extends Leaf {
  @override
  final String type = 'codeSpan';

  @override
  final String text;

  const CodeSpan({required this.text});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CodeSpan && type == other.type && text == other.text;
  }

  @override
  int get hashCode => Object.hash(type, text);
}

/// A node in a [TextBlock] that renders `text` as a link (HTML `<a>`).
///
/// @remarks
/// Used when user-typed text is turned into a link automatically.
///
/// Unlike [Link], users do have permission to send [AutoLink] by default, because the `text` and `url` properties must match.
/// Specifically:
///
/// - If `text` is an email, `url` must contain a `mailto:` link to the same email address
///
/// - If `text` is a phone number, `url` must contain a `tel:` link to the same phone number
///
/// - If `text` is a website, the domain name including subdomains must be the same in both `text` and `url`.
/// If `text` includes a protocol (such as `https`), path (/page), query string (?page=true), or url fragment (#title), they must be the same in `url`.
/// If `text` does not specify a protocol, `url` must use either `https` or `http`.
///
/// This means that the following AutoLink is valid:
///
/// ```dart
/// AutoLink(
///   text: 'talkjs.com',
///   url: 'https://talkjs.com/docs/JavaScript_Data_API/Message_Content/#AutoLinkNode',
/// )
/// ```
///
/// That link will appear as `talkjs.com` and link you to the specific section of the documentation that explains how [AutoLink] works.
///
/// These rules ensure that the user knows what link they are clicking, and prevents [AutoLink] being used for phishing.
/// If you try to send a message containing an [AutoLink] that breaks these rules, the request will be rejected.
///
/// @public
final class AutoLink extends Leaf {
  @override
  final String type = 'autoLink';

  /// The URL to open when a user clicks this node.
  final String url;

  /// The text to display in the link.
  @override
  final String text;

  const AutoLink({required this.url, required this.text});

  @override
  Map<String, dynamic> toJson() => {'type': type, 'url': url, 'text': text};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AutoLink &&
        type == other.type &&
        url == other.url &&
        text == other.text;
  }

  @override
  int get hashCode => Object.hash(type, url, text);
}

final class Suppressed extends Leaf {
  @override
  final String type = 'suppressed';

  @override
  final String text;

  const Suppressed({required this.text});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Suppressed && type == other.type && text == other.text;
  }

  @override
  int get hashCode => Object.hash(type, text);
}

final class Emoji extends Leaf {
  @override
  final String type = 'emoji';

  @override
  final String text;

  const Emoji({required this.text});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Emoji && type == other.type && text == other.text;
  }

  @override
  int get hashCode => Object.hash(type, text);
}

/// A node in a [TextBlock] that is used for [custom emoji](https://talkjs.com/docs/Features/Messages/Emojis/#custom-emojis).
///
/// @public
final class CustomEmoji extends Leaf {
  @override
  final String type = 'customEmoji';

  /// The name (including colons at the start and end) of the custom emoji to show.
  @override
  final String text;

  const CustomEmoji({required this.text});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is CustomEmoji && type == other.type && text == other.text;
  }

  @override
  int get hashCode => Object.hash(type, text);
}

/// A node in a [TextBlock] that is used when a user is [mentioned](https://talkjs.com/docs/Features/Messages/Mentions/).
///
/// @remarks
/// Used when a user types `@name` and selects the user they want to mention.
///
/// @public
final class Mention extends Leaf {
  @override
  final String type = 'mention';

  /// The ID of the user who is mentioned.
  final String id;

  /// The name of the user who is mentioned.
  @override
  final String text;

  /// @suppress
  final String? internalId;

  const Mention({required this.id, required this.text, this.internalId});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'text': text,
    'internalId': internalId,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is Mention &&
        type == other.type &&
        id == other.id &&
        text == other.text &&
        internalId == other.internalId;
  }

  @override
  int get hashCode => Object.hash(type, id, text, internalId);
}

/// The content of a message is structured as a list of content blocks.
///
/// @remarks
/// Currently, each message can only have one content block, but this will change in the future.
/// This will not be considered a breaking change, so your code should assume there can be multiple content blocks.
///
/// These blocks are rendered in order, top-to-bottom.
///
/// Currently the available Content Block types are:
///
/// - `type: "text"` ([TextBlock])
///
/// - `type: "file"` ([FileBlock])
///
/// - `type: "location"` ([LocationBlock])
///
/// @public
sealed class ContentBlock {
  const ContentBlock();
  String get type;
  Map<String, dynamic> toJson();
}

/// The version of [ContentBlock] that is used when sending or editing messages.
///
/// @remarks
/// This is the same as [ContentBlock] except it uses [SendFileBlock] instead of [FileBlock]
///
/// `SendContentBlock` is a subset of `ContentBlock`.
/// This means that you can re-send the `content` from an existing message without any issues:
///
/// ```dart
/// final MessageSnapshot existingMessage = ...
///
/// final convRef = await session.conversation('example_conversation_id');
/// await convRef.sendMessage(SendMessageParams(content: existingMessage.content));
/// ```
///
/// @public
typedef SendContentBlock = ContentBlock;

/// A block of formatted text in a message's content.
///
/// @remarks
/// Each TextBlock is a tree of children describing the structure of some formatted text.
/// Each child is either a plain text string, or a `node` representing some text with additional formatting.
///
/// For example, if the user typed:
///
/// > *This first bit* is bold, and *_the second bit_* is bold and italics
///
/// Then this would become a Text Block with the structure:
///
/// ```dart
/// TextBlock(
///   children: [
///     Markup(type: 'bold', children: ['This first bit']),
///     ' is bold, and ',
///     Markup(
///       type: 'bold',
///       children: [
///         Markup(type: 'italic', children: ['the second bit']),
///       ],
///     ),
///     ' is bold and italics',
///   ],
/// )
/// ```
///
/// Rather than relying the automatic message parsing, you can also specify the `TextBlock` directly using [ConversationRef.sendMessage] with [SendMessageParams].
///
/// @public
final class TextBlock extends ContentBlock {
  @override
  final String type = 'text';

  /// The tree of formatted text nodes.
  final List<EntityTreeNode> children;

  const TextBlock({required this.children});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'children': children.map(_serializeEntityTreeNode).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is TextBlock &&
        type == other.type &&
        _listEquality.equals(children, other.children);
  }

  @override
  int get hashCode => Object.hash(type, _listEquality.hash(children));
}

/// The version of [FileBlock] that is used when sending or editing messages.
///
/// @remarks
/// When a user receives the message you send with `SendFileBlock`, this block will have turned into one of the [FileBlock] variants.
///
/// For information on how to obtain a file token, see [FileToken].
///
/// The `SendFileBlock` interface is a subset of the `FileBlock` interface.
/// If you have an existing `FileBlock` received in a message, you can re-use that block to re-send the same attachment:
///
/// ```dart
/// final existingFileBlock = ...
/// final imageToShare = existingFileBlock.content[0] as ImageBlock;
///
/// final convRef = await session.conversation('example_conversation_id');
/// await convRef.sendMessage(SendMessageParams(content: [imageToShare]));
/// ```
///
/// @public
final class SendFileBlock extends ContentBlock {
  @override
  final String type = 'file';

  /// The encoded identifier for the file, obtained by uploading a file with [Session.sendFile], or taken from another message.
  final String fileToken;

  const SendFileBlock({required this.fileToken});

  @override
  Map<String, dynamic> toJson() => {'type': type, 'fileToken': fileToken};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SendFileBlock &&
        type == other.type &&
        fileToken == other.fileToken;
  }

  @override
  int get hashCode => Object.hash(type, fileToken);
}

/// A block showing a location in the world, typically because a user shared their location in the chat.
///
/// @remarks
/// In the TalkJS UI, location blocks are rendered as a link to Google Maps, with the map pin showing at the specified coordinate.
/// A thumbnail shows the surrounding area on the map.
///
/// @public
final class LocationBlock extends ContentBlock {
  @override
  final String type = 'location';

  /// The north-south coordinate of the location.
  ///
  /// @remarks
  /// Usually listed first in a pair of coordinates.
  ///
  /// Must be a number between -90 and 90
  final double latitude;

  /// The east-west coordinate of the location.
  ///
  /// @remarks
  /// Usually listed second in a pair of coordinates.
  ///
  /// Must be a number between -180 and 180
  final double longitude;

  const LocationBlock({required this.latitude, required this.longitude});

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is LocationBlock &&
        type == other.type &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode => Object.hash(type, latitude, longitude);
}

sealed class FileBlock extends ContentBlock {
  const FileBlock();
  String? get subtype;
  String get fileToken;
  String get url;
  int get size;
  String get filename;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'subtype': subtype,
    'fileToken': fileToken,
    'url': url,
    'size': size,
    'filename': filename,
  };
}

/// A FileBlock variant for a video attachment, with additional video-specific metadata.
///
/// @remarks
/// You can identify this variant by checking for `subtype: "video"`.
///
/// Includes metadata about the height and width of the video in pixels, and the duration of the video in seconds, where available.
///
/// Videos that you upload with the TalkJS UI will include the dimensions and duration as long as the sender's browser can preview the file.
/// Videos that you upload with the REST API or [TalkSession.uploadVideo] will include this metadata if you specified it when uploading.
/// Videos attached in a reply to an email notification will not include any metadata.
///
/// @public
final class VideoBlock extends FileBlock {
  @override
  final String type = 'file';

  @override
  final String subtype = 'video';

  /// An encoded identifier for this file. Use in [SendFileBlock] to send this video in another message.
  @override
  final String fileToken;

  /// The URL where you can fetch the file.
  @override
  final String url;

  /// The size of the file in bytes.
  @override
  final int size;

  /// The name of the video file, including file extension.
  @override
  final String filename;

  /// The width of the video in pixels, if known.
  final int? width;

  /// The height of the video in pixels, if known.
  final int? height;

  /// The duration of the video in seconds, if known.
  final double? duration;

  const VideoBlock({
    required this.fileToken,
    required this.url,
    required this.size,
    required this.filename,
    this.width,
    this.height,
    this.duration,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'subtype': subtype,
    'fileToken': fileToken,
    'url': url,
    'size': size,
    'filename': filename,
    'width': width,
    'height': height,
    'duration': duration,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is VideoBlock &&
        type == other.type &&
        subtype == other.subtype &&
        fileToken == other.fileToken &&
        url == other.url &&
        size == other.size &&
        filename == other.filename &&
        width == other.width &&
        height == other.height &&
        duration == other.duration;
  }

  @override
  int get hashCode => Object.hash(
    type,
    subtype,
    fileToken,
    url,
    size,
    filename,
    width,
    height,
    duration,
  );
}

/// A FileBlock variant for an image attachment, with additional image-specific metadata.
///
/// @remarks
/// You can identify this variant by checking for `subtype: "image"`.
///
/// Includes metadata about the height and width of the image in pixels, where available.
///
/// Images that you upload with the TalkJS UI will include the image dimensions as long as the sender's browser can preview the file.
/// Images that you upload with the REST API or [TalkSession.uploadImage] will include the dimensions if you specified them when uploading.
/// Image attached in a reply to an email notification will not include the dimensions.
///
/// @public
final class ImageBlock extends FileBlock {
  @override
  final String type = 'file';

  @override
  final String subtype = 'image';

  /// An encoded identifier for this file. Use in [SendFileBlock] to send this image in another message.
  @override
  final String fileToken;

  /// The URL where you can fetch the file.
  @override
  final String url;

  /// The size of the file in bytes.
  @override
  final int size;

  /// The name of the image file, including file extension.
  @override
  final String filename;

  /// The width of the image in pixels, if known.
  final int? width;

  /// The height of the image in pixels, if known.
  final int? height;

  const ImageBlock({
    required this.fileToken,
    required this.url,
    required this.size,
    required this.filename,
    this.width,
    this.height,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'subtype': subtype,
    'fileToken': fileToken,
    'url': url,
    'size': size,
    'filename': filename,
    'width': width,
    'height': height,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ImageBlock &&
        type == other.type &&
        subtype == other.subtype &&
        fileToken == other.fileToken &&
        url == other.url &&
        size == other.size &&
        filename == other.filename &&
        width == other.width &&
        height == other.height;
  }

  @override
  int get hashCode =>
      Object.hash(type, subtype, fileToken, url, size, filename, width, height);
}

/// A FileBlock variant for an audio attachment, with additional audio-specific metadata.
///
/// @remarks
/// You can identify this variant by checking for `subtype: "audio"`.
///
/// The same file could be uploaded as either an audio block, or as a [VoiceBlock].
/// The same data will be available either way, but they will be rendered differently in the UI.
///
/// Includes metadata about the duration of the audio file in seconds, where available.
///
/// Audio files that you upload with the TalkJS UI will include the duration as long as the sender's browser can preview the file.
/// Audio files that you upload with the REST API or [TalkSession.uploadAudio] will include the duration if you specified it when uploading.
/// Audio files attached in a reply to an email notification will not include the duration.
///
/// @public
final class AudioBlock extends FileBlock {
  @override
  final String type = 'file';

  @override
  final String subtype = 'audio';

  /// An encoded identifier for this file. Use in [SendFileBlock] to send this file in another message.
  @override
  final String fileToken;

  /// The URL where you can fetch the file
  @override
  final String url;

  /// The size of the file in bytes
  @override
  final int size;

  /// The name of the audio file, including file extension
  @override
  final String filename;

  /// The duration of the audio in seconds, if known
  final double? duration;

  const AudioBlock({
    required this.fileToken,
    required this.url,
    required this.size,
    required this.filename,
    this.duration,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'subtype': subtype,
    'fileToken': fileToken,
    'url': url,
    'size': size,
    'filename': filename,
    'duration': duration,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AudioBlock &&
        type == other.type &&
        subtype == other.subtype &&
        fileToken == other.fileToken &&
        url == other.url &&
        size == other.size &&
        filename == other.filename &&
        duration == other.duration;
  }

  @override
  int get hashCode =>
      Object.hash(type, subtype, fileToken, url, size, filename, duration);
}

/// A FileBlock variant for a voice recording attachment, with additional voice-recording-specific metadata.
///
/// @remarks
/// You can identify this variant by checking for `subtype: "voice"`.
///
/// The same file could be uploaded as either a voice block, or as an [AudioBlock].
/// The same data will be available either way, but they will be rendered differently in the UI.
///
/// Includes metadata about the duration of the recording in seconds, where available.
///
/// Voice recordings done in the TalkJS UI will always include the duration.
/// Voice recording that you upload with the REST API or [TalkSession.uploadVoice] will include this metadata if you specified it when uploading.
///
/// Voice recordings will never be taken from a reply to an email notification.
/// Any attached audio file will become an [AudioBlock] instead of a voice block.
///
/// @public
final class VoiceBlock extends FileBlock {
  @override
  final String type = 'file';

  @override
  final String subtype = 'voice';

  /// An encoded identifier for this file. Use in [SendFileBlock] to send this voice recording in another message.
  @override
  final String fileToken;

  /// The URL where you can fetch the file
  @override
  final String url;

  /// The size of the file in bytes
  @override
  final int size;

  /// The name of the file, including file extension
  @override
  final String filename;

  /// The duration of the voice recording in seconds, if known
  final double? duration;

  const VoiceBlock({
    required this.fileToken,
    required this.url,
    required this.size,
    required this.filename,
    this.duration,
  });

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'subtype': subtype,
    'fileToken': fileToken,
    'url': url,
    'size': size,
    'filename': filename,
    'duration': duration,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is VoiceBlock &&
        type == other.type &&
        subtype == other.subtype &&
        fileToken == other.fileToken &&
        url == other.url &&
        size == other.size &&
        filename == other.filename &&
        duration == other.duration;
  }

  @override
  int get hashCode =>
      Object.hash(type, subtype, fileToken, url, size, filename, duration);
}

/// The most basic FileBlock variant, used whenever there is no additional metadata for a file.
///
/// @remarks
/// Do not try to check for `subtype == null` directly, as this will break when we add new FileBlock variants in the future.
///
/// Instead, treat GenericFileBlock as the default. For example:
///
/// ```dart
/// switch (block) {
///   case VideoBlock():
///     handleVideoBlock(block);
///   case ImageBlock():
///     handleImageBlock(block);
///   case AudioBlock():
///     handleAudioBlock(block);
///   case VoiceBlock():
///     handleVoiceBlock(block);
///   default:
///     handleGenericFileBlock(block);
/// }
/// ```
///
/// @public
final class GenericFileBlock extends FileBlock {
  @override
  final String type = 'file';

  /// Never set for generic file blocks.
  @override
  final String? subtype = null;

  /// An encoded identifier for this file. Use in [SendFileBlock] to send this file in another message.
  @override
  final String fileToken;

  /// The URL where you can fetch the file
  @override
  final String url;

  /// The size of the file in bytes
  @override
  final int size;

  /// The name of the file, including file extension
  @override
  final String filename;

  const GenericFileBlock({
    required this.fileToken,
    required this.url,
    required this.size,
    required this.filename,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is GenericFileBlock &&
        type == other.type &&
        subtype == other.subtype &&
        fileToken == other.fileToken &&
        url == other.url &&
        size == other.size &&
        filename == other.filename;
  }

  @override
  int get hashCode =>
      Object.hash(type, subtype, fileToken, url, size, filename);
}

// Implementation details

dynamic _serializeEntityTreeNode(EntityTreeNode node) {
  if (node is String) {
    return node;
  }

  if (node is Entity) {
    return node.toJson();
  }

  throw Exception('Unknown EntityTreeNode type: ${node.runtimeType}');
}

String serializeContent(List<SendContentBlock> content) {
  return jsonEncode(content.map((block) => block.toJson()).toList());
}

List<ContentBlock> deserializeContent(String json) {
  return (jsonDecode(json) as List<dynamic>)
      .map((block) => deserializeContentBlock(block as Map<String, dynamic>))
      .toList();
}

ContentBlock deserializeContentBlock(Map<String, dynamic> json) {
  return switch (json['type'] as String?) {
    'text' => TextBlock(
      children: _deserializeEntityTree(json['children'] as List<dynamic>),
    ),
    'location' => LocationBlock(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    ),
    'file' => switch (json['subtype'] as String?) {
      'video' => VideoBlock(
        fileToken: json['fileToken'] as String,
        url: json['url'] as String,
        size: (json['size'] as num).toInt(),
        filename: json['filename'] as String,
        width: (json['width'] as num?)?.toInt(),
        height: (json['height'] as num?)?.toInt(),
        duration: (json['duration'] as num?)?.toDouble(),
      ),
      'image' => ImageBlock(
        fileToken: json['fileToken'] as String,
        url: json['url'] as String,
        size: (json['size'] as num).toInt(),
        filename: json['filename'] as String,
        width: (json['width'] as num?)?.toInt(),
        height: (json['height'] as num?)?.toInt(),
      ),
      'audio' => AudioBlock(
        fileToken: json['fileToken'] as String,
        url: json['url'] as String,
        size: (json['size'] as num).toInt(),
        filename: json['filename'] as String,
        duration: (json['duration'] as num?)?.toDouble(),
      ),
      'voice' => VoiceBlock(
        fileToken: json['fileToken'] as String,
        url: json['url'] as String,
        size: (json['size'] as num).toInt(),
        filename: json['filename'] as String,
        duration: (json['duration'] as num?)?.toDouble(),
      ),
      _ => GenericFileBlock(
        fileToken: json['fileToken'] as String,
        url: json['url'] as String,
        size: (json['size'] as num).toInt(),
        filename: json['filename'] as String,
      ),
    },
    _ => throw Exception('Unknown ContentBlock type: ${json['type']}'),
  };
}

EntityTree _deserializeEntityTree(List<dynamic> list) {
  return list.map(_deserializeEntityTreeNode).toList();
}

EntityTreeNode _deserializeEntityTreeNode(dynamic json) {
  if (json is String) {
    return json;
  }

  if (json is Map<String, dynamic>) {
    return _deserializeEntity(json);
  }

  throw Exception('Unknown EntityTreeNode: $json');
}

Entity _deserializeEntity(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  final children = json['children'] as List<dynamic>?;

  return switch (type) {
    'bold' || 'italic' || 'strikethrough' => Markup(
      type: type!,
      children: _deserializeEntityTree(children!),
    ),
    'blockquote' => Blockquote(children: _deserializeEntityTree(children!)),
    'bulletlist' ||
    'bulletList' => BulletList(children: _deserializeEntityTree(children!)),
    'bulletpoint' ||
    'bulletPoint' => BulletPoint(children: _deserializeEntityTree(children!)),
    'link' => Link(
      url: json['url'] as String,
      children: _deserializeEntityTree(children!),
    ),
    'actionlink' || 'actionLink' => ActionLink(
      action: json['action'] as String,
      params: Map<String, String>.from(json['params'] as Map),
      children: _deserializeEntityTree(children!),
    ),
    'actionbutton' || 'actionButton' => ActionButton(
      action: json['action'] as String,
      params: Map<String, String>.from(json['params'] as Map),
      children: _deserializeEntityTree(children!),
    ),
    'codeblock' || 'codeBlock' => CodeBlock(
      text: json['text'] as String,
      language: json['language'] as String?,
    ),
    'codespan' || 'codeSpan' => CodeSpan(text: json['text'] as String),
    'autolink' || 'autoLink' => AutoLink(
      url: json['url'] as String,
      text: json['text'] as String,
    ),
    'suppressed' => Suppressed(text: json['text'] as String),
    'emoji' => Emoji(text: json['text'] as String),
    'customemoji' || 'customEmoji' => CustomEmoji(text: json['text'] as String),
    'mention' => Mention(
      id: json['id'] as String,
      text: json['text'] as String,
      internalId: json['internalId'] as String?,
    ),
    _ => throw Exception('Unknown Entity type: $type'),
  };
}
