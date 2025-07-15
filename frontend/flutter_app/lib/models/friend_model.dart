class FriendModel {
  final String id;
  final String userId;
  final String friendId;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime createdAt;

  FriendModel({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      friendId: json['friend_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

class FriendRequestModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String status;
  final String? senderName;
  final DateTime createdAt;
  final DateTime updatedAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.senderName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      senderName: json['sender_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'sender_name': senderName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SendFriendRequestModel {
  final String receiverId;

  SendFriendRequestModel({required this.receiverId});

  Map<String, dynamic> toJson() {
    return {'receiver_id': receiverId};
  }
}

class RespondToFriendRequestModel {
  final String requestId;
  final String action; // 'accept' or 'reject'

  RespondToFriendRequestModel({required this.requestId, required this.action});

  Map<String, dynamic> toJson() {
    return {'request_id': requestId, 'action': action};
  }
}

class SearchUserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;

  SearchUserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
    );
  }

  String get fullName => '$firstName $lastName';
}

class GetFriendsResponseModel {
  final List<FriendModel> friends;

  GetFriendsResponseModel({required this.friends});

  factory GetFriendsResponseModel.fromJson(List<dynamic> json) {
    return GetFriendsResponseModel(
      friends: json.map((item) => FriendModel.fromJson(item)).toList(),
    );
  }
}

class GetFriendRequestsResponseModel {
  final List<FriendRequestModel> requests;

  GetFriendRequestsResponseModel({required this.requests});

  factory GetFriendRequestsResponseModel.fromJson(List<dynamic> json) {
    return GetFriendRequestsResponseModel(
      requests: json.map((item) => FriendRequestModel.fromJson(item)).toList(),
    );
  }
}

class SearchUsersResponseModel {
  final List<SearchUserModel> users;

  SearchUsersResponseModel({required this.users});

  factory SearchUsersResponseModel.fromJson(List<dynamic> json) {
    return SearchUsersResponseModel(
      users: json.map((item) => SearchUserModel.fromJson(item)).toList(),
    );
  }
}
