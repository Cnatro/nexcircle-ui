# NexCircle - Huong Dan Du An

NexCircle la ung dung Flutter ho tro: Dang nhap, nhan tin real-time, quan ly danh ba, cuoc goi, va nhan thong bao push.

Cong nghe: Flutter 3.11.3 + Dart | REST API + WebSocket (STOMP) | Firebase | Clean Architecture

---

## Cau Truc Du An

```
lib/
├── main.dart
├── core/
│   ├── bootstrap/
│   │   ├── bootstrap_page.dart          Khoi dong app
│   │   └── my_app_flow.dart             Root navigator
│   ├── service/
│   │   ├── firebase_service.dart        Firebase init
│   │   └── notification_service.dart    Push notification handler
│   └── utils/
│       ├── shared_preferences.dart      Token va user storage
│       └── top_snackbar.dart            Toast UI
│
└── features/
    ├── auth/                            Login/Register
    │   ├── data/
    │   │   ├── datasources/user_remote_data_source.dart
    │   │   ├── models/user_model.dart
    │   │   └── repositories/user_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/user.dart
    │   │   ├── repositories/user_repository.dart
    │   │   └── usecases/login_usecase.dart
    │   └── presentation/pages/login_page.dart
    │
    ├── messaging/                       Real-time Chat
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── message_remote_datasource.dart
    │   │   │   └── message_socket_data_source.dart
    │   │   ├── models/
    │   │   └── repositories/message_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/message.dart
    │   │   ├── entities/conversation.dart
    │   │   └── usecases/get_messages_usecase.dart
    │   └── presentation/pages/chat_page.dart
    │
    ├── call/                            Cuoc goi
    │   ├── data/
    │   │   ├── datasources/call_remote_datasource.dart
    │   │   └── repositories/call_repository_impl.dart
    │   └── domain/
    │       └── usecases/initiate_call_usecase.dart
    │
    ├── contact/                         Danh ba
    ├── home/                            Trang chu
    └── other features
```

---

## Khoi Dong Ung Dung

```
1. main() - Load .env file

2. MyApp (MaterialApp) -> BootstrapPage

3. BootstrapPage - Chay initState():
   - FirebaseService.init()
   - NotificationService.init()
   - Khoi tao Dependencies (repositories, use cases)
   
4. Kiem tra Token (AppPreferences.hasToken()):
   - Neu co token -> Lay current user -> HomePage
   - Neu khong -> LoginPage

5. MyAppFlow - Root navigator
   - home: HomePage hoac LoginPage
   - routes: {'/register': RegisterPage}
```

---

## CHUC NANG 1: Xac Thuc (Login)

Luong hoat dong:

```
Buoc 1: User nhap username + password tren LoginPage

Buoc 2: Click Login button -> Goi LoginUseCase.execute()

Buoc 3: LoginUseCase goi UserRepository.login()

Buoc 4: UserRepository goi UserRemoteDataSource.login()
   - Gui HTTP POST den /users/login voi username + password
   - Server tra ve accessToken + User data

Buoc 5: UserRemoteDataSource nhan response:
   - Neu statusCode = 200:
     1. Lay accessToken tu response
     2. Luu token vao SharedPreferences (AppPreferences.saveToken())
     3. Goi getCurrentUser() voi Bearer token
     4. Luu User data vao SharedPreferences
     5. Return UserModel ve LoginPage
   - Neu statusCode != 200: Return null

Buoc 6: LoginPage nhan User object:
   - Neu User != null:
     1. setState() -> Tat loading
     2. Navigator.push HomePage
   - Neu User = null:
     1. Hien thong bao loi
```

Luu tru Token:

```
- Token luu trong SharedPreferences (local device storage)
- Moi lan goi API yeu cau Authorization, them Bearer token:
  Headers: {'Authorization': 'Bearer $token'}
  
- Khi logout:
  - AppPreferences.removeToken() -> Xoa token khoi SharedPreferences
  - Navigator.push LoginPage
  
- Kiem tra login status:
  - BootstrapPage goi AppPreferences.hasToken()
  - Neu true: Dung vao HomePage
  - Neu false: Dung vao LoginPage
```

---

## CHUC NANG 2: Thong Bao Push (Firebase Cloud Messaging)

Luong hoat dong:

```
Buoc 1: BootstrapPage goi NotificationService.init():
   - Xin quyen (requestPermission)
   - Tao notification channel (Android)
   - Setup listeners cho cac trang thai notification

Buoc 2: Firebase Server gui remoteMessage

Buoc 3a: APP DANG MO (Foreground):
   - FirebaseMessaging.onMessage.listen() nhan message
   - NotificationService hien local notification banner
   - Neu user click notification -> Goi _handleClick()

Buoc 3b: APP TAT NHUNG MO TU NOTIFICATION (Background):
   - FirebaseMessaging.onMessageOpenedApp.listen() nhan message
   - Automatically open related page

Buoc 3c: APP BI KILL (Killed State):
   - FirebaseMessaging.getInitialMessage() kiem tra message
   - Neu co message -> _handleData()

Luong chi tiet:

Firebase -> Notification Service
   |
   +-> Foreground (app mo)
   |    onMessage.listen() 
   |    -> _showLocalNotification()
   |    -> (User click) _handleClick()
   |
   +-> Background (app tat)
   |    onMessageOpenedApp.listen()
   |    -> _handleData()
   |    -> Automatically open page
   |
   +-> Killed (app bi kill)
        getInitialMessage()
        -> _handleData()
```

Cac thanh phan:

```
- FirebaseMessaging: Nhan remote message tu Firebase server
- FlutterLocalNotificationsPlugin: Hien notification tren device
- NotificationChannel: Android notification channel (bat buoc)
- Payload: Data di kem notification khi user click
```

---

## CHUC NANG 3: Nhan Tin Real-time (WebSocket STOMP)

Luong hoat dong:

```
Buoc 1: ChatPage khoi tao socket connection trong initState():
   - Lay token tu AppPreferences
   - Lay userId tu AppPreferences
   - Goi MessageSocketDataSource.connect(token, conversationId)
   
Buoc 2: Socket ket noi WebSocket server thong qua STOMP protocol

Buoc 3: Load lich su tin nhan:
   - Goi MessageRemoteDataSource.getMessages()
   - Gui GET request den /messages api
   - Server tra ve list tin nhan (paging)
   - Display trong ChatPage

Buoc 4: Thiet lap listener cho message moi:
   - Goi socket.onMessage() -> tra ve Stream
   - Subscribe vao Stream
   - Moi khi co message moi -> setState() update UI

Buoc 5: User gui tin nhan:
   - Type text va click send button
   - Goi socket.sendMessage(content)
   - Gui qua WebSocket STOMP
   - Ngay lap tuc add message vao UI (optimistic update)

Buoc 6: Server nhan message:
   - Luu vao database
   - Phat message den tat ca participants thong qua socket
   - Gui Firebase notification neu recipients offline
   - Luu vao conversation history

Buoc 7: Participant B nhan message:
   - onMessage.listen() trigger
   - setState() cap nhat UI
   - Hien message moi trong chat list

Buoc 8: Cleanup khi thoat chat:
   - Goi _sub.cancel() (huy socket listener)
   - Goi socket.disconnect()
   - Dispose ChatPage
```

Chi tiet socket va API:

```
SOCKET (WebSocket STOMP):
- Connect: socket.connect(token, conversationId)
- Send: socket.sendMessage(content)
- Listen: socket.onMessage() -> Stream<SocketMessage>
- Disconnect: socket.disconnect()

REST API:
- Load message: GET /messages (pagination)
  Query params: conversationId, page, size
  Return: List<Message> (reversed order)

Flow tin nhan:
ChatPage (User A)
  |
  +-> socket.sendMessage(text)
      |
      +-> WebSocket Server
          |
          +-> Luu database
          +-> Phat Socket cho User B
          +-> GUI Firebase notification
  |
  <- socket.onMessage().listen() (nhan tu Server)
      |
      +-> setState() update messages
      +-> scrollToBottom()
```

---

## CHUC NANG 4: Cuoc Goi (Call)

Luong hoat dong:

```
Buoc 1: User A chon contact -> Click call button

Buoc 2: CallPage/Feature:
   - Tao call request voi recipient (User B)
   - Goi InitiateCallUseCase.execute()

Buoc 3: CallRemoteDataSource goi API:
   - Gui POST /calls/initiate
   - Body: {initiatorId, recipientId, callType}
   - Server tao call record

Buoc 4: Server gui notification den User B:
   - Firebase notification: "User A dang goi cho ban"
   - Include call metadata (callId, initiatorId, etc.)

Buoc 5: User B nhan notification:
   - Click -> App mo CallPage
   - Thay incoming call UI
   - Option: Accept hoac Reject

Buoc 6: Accept/Reject:
   - Accept: Goi API /calls/{callId}/accept -> Connect call
   - Reject: Goi API /calls/{callId}/reject -> End call

Luong:
User A -> Click Call Button
  |
  +-> InitiateCallUseCase
      |
      +-> CallRemoteDataSource.initiateCall()
          |
          +-> API POST /calls/initiate
              |
              +-> Server create call record
              |
              +-> Firebase notification -> User B
                  |
                  +-> Incoming call UI
                      |
                      +-> Accept/Reject
                          |
                          +-> API call\/{callId}/accept
                              |
                              +-> WebRTC/SIP connection
                              +-> Voice/Video call
```

---

## Tong Hop 4 Chuc Nang Chinh

Chuc nang | Cong nghe | Luong | Luu tru
---|---|---|---
Login | HTTP REST | POST /users/login -> save token -> check auth | SharedPreferences (device)
Notification | Firebase Cloud Messaging | Firebase server -> local notification -> user handle | N/A (Firebase)
Messaging | WebSocket STOMP + HTTP REST | socket.connect -> load history -> send msg -> listen -> update UI | Server database
Call | HTTP REST API | API initiate call -> Firebase notification -> Accept/Reject -> WebRTC | Server database

---

Phi Ban: 1.0.0 | Cap Nhat: 14/04/2026
