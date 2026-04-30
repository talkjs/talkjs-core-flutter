# Architecture of talkjs-core-flutter

The bridge between the Dart/Flutter side and the native (Kotlin/Swift) side is
handled by a library called Pigeon.

The docs for Pigeon can be found here:

https://docs.flutter.dev/platform-integration/platform-channels#pigeon

## Why Pigeon

Pigeon is mentioned in the official Flutter docs as a type safe alternative to
platform channels, which communicate only using strings.

## How does Pigeon work

You write a Dart file (in this case it's `pigeons/core_api.dart`), let's call
it the Pigeon file, for clarity, where you define the data structures that
will be used to communicate between the Flutter and Native parts.
Pigeon will generate 2 files (or 3 when iOS/Swift support will be implemented)
(in this case they are `core.g.dart` and `Core.g.kt`).
These generated files will have all the structures that were defined in the
Pigeon file, as native classes for the respective programming languages.

Also, in the Pigeon file, we have the `CoreHostApi` class, that defines some methods.
Each method of this class is used to communicate between Flutter and the
Native part, which means that in `TalkjsCoreFlutterPlugin.kt`, we have the
class `PigeonApiImplementation` that implements all the methods defined in `CoreHostApi`.

We also have the `CoreFlutterApi` class, that is used when the Native part
wants to communicate with Flutter, and `lib/src/api.dart` has the class
`CoreFlutterApiImplementation` that implements all those methods.

To generate the `core.g.dart` and `Core.g.kt` files, run the command:

```sh
dart run pigeon --input pigeons/core_api.dart
```

## Limitations of Pigeon

The biggest limitation of Pigeon is that you cannot import other files from
the Pigeon file, which means that *all* the data structures passed between
Flutter and Native must be declared in a sigle file.
I would have liked to make the Pigeon file more modular, but unfortunately
it's not possible.

Another limitation is that the members of the classes that you define in the
Pigeon file cannot have default values. To mitigate this limitation, it's
still possible to have nullable members, and not mark those members as
`required` in the constructor.

All the functions from Flutter to Native are async.

## Architecture of the API in CoreHostApi (Native)

Let's first take a look at `TalkjsCoreFlutterPlugin.kt`:

### Data classes

The auto generated classes might have the same members and look identical to
the classes already defined in the TalkJS Core library, but in Kotlin they are
treated as completely different and incompatible classes.
Let's take as an example `UserSnapshot`:
The `UserSnapshot` defined in `Core.g.kt` is a different class compared
to `com.talkjs.core.UserSnapshot`.
Now, Flutter uses `UserSnapshot` as defined in `Core.g.kt`, but all of
TalkJS Core uses `com.talkjs.core.UserSnapshot`.
In order to convert from `com.talkjs.core.UserSnapshot` to `UserSnapshot`
there is a function called `makeUserSnapshot`.

This applies to all the data structures defined in the Pigeon file, *except*
for ContentBlock & friends (the Entity Tree stuff).

Considering that the Entity Tree stuff is a multitude of classes with
non-trivial hierarchy, and also considering that all of these classes are
JSON-serializable, I decided to bypass the whole Pigeon conversions, and
convert them to JSON when passing them to/from Native.
This has the tradeoff that I needed to implement the JSON (de)serialization
for those classes on the Dart side, but on the Native side I get JSON
(de)serialization and mapping to the correct classes for free.

### API

Each class that we expose from TalkJS Core (sessions, users, conversations, etc...)
live in a `MutableMap<Long, *class*>`. For example, users live in a `MutableMap<Long, UserRef>`.
I call the `Long` that indexes each map a `handle`, and the idea is that each
function that creates a new object (for example `session.user`) return a `Long` (that
will be an `int` in Dart), that is the handle of the newly created object.
Also, each function has the handle as the first parameter, for example
`session.user` passes the handle to the session as the first parameter.

## Architecture of the API in Flutter

Each class family lives in its own file (for class family I'm referring, for
example in `user_ref.dart` lives not only the `UserRef` class, but also
`UserSubscription` and `UserOnlineSubscription`).

Each class has a private constructor (`UserRef._`) that is called by the
function that provides it (for example `session.user`).

Each method of the class is a thin wrapper to the native API.

### Subscription snapshots

Considering that subscription snapshots arrive from the Native part, in
`api.dart` we have a `Map<int, Function>` for each subscription, in the same
spirit as the Native part.

