# chat example
    A variation on the topic of chats. The main idea was to write a datasource providing a convenient interface for displaying the chat dialogue. The main requirements were: the availability of the changeset, lazy access from the database (also mapping in the background), tracking changes in the background, and the possibility of reuse. For greater performance, Texture (AsyncDisplayKit) was used in the UI part.

Project architecture: clean+mvvm

Main dependencies:
    - ReactiveSwift/ReactiveCocoa
    - Moya
    - Realm
    - Texture
