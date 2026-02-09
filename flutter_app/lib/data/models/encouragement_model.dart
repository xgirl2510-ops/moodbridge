import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, template, voice, sticker }
enum ReactionType { thanks, feelingBetter, wantToChat }

class EncouragementModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String? senderCheckinId;
  final String? receiverCheckinId;
  
  // Message content
  final MessageType messageType;
  final String? content;
  final String? templateId;
  final String? mediaUrl;
  
  // Status
  final bool isRead;
  final DateTime? readAt;
  
  // Reaction
  final ReactionType? reaction;
  final DateTime? reactionAt;
  
  // Timestamps
  final DateTime createdAt;
  
  // Denormalized sender info
  final String senderAnonymousId;
  final String? senderDisplayName;
  final String? senderAvatarUrl;

  EncouragementModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.senderCheckinId,
    this.receiverCheckinId,
    this.messageType = MessageType.text,
    this.content,
    this.templateId,
    this.mediaUrl,
    this.isRead = false,
    this.readAt,
    this.reaction,
    this.reactionAt,
    required this.createdAt,
    required this.senderAnonymousId,
    this.senderDisplayName,
    this.senderAvatarUrl,
  });

  factory EncouragementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    MessageType messageType;
    switch (data['messageType']) {
      case 'template':
        messageType = MessageType.template;
        break;
      case 'voice':
        messageType = MessageType.voice;
        break;
      case 'sticker':
        messageType = MessageType.sticker;
        break;
      default:
        messageType = MessageType.text;
    }

    ReactionType? reaction;
    if (data['reaction'] != null) {
      switch (data['reaction']) {
        case 'thanks':
          reaction = ReactionType.thanks;
          break;
        case 'feeling_better':
          reaction = ReactionType.feelingBetter;
          break;
        case 'want_to_chat':
          reaction = ReactionType.wantToChat;
          break;
      }
    }

    return EncouragementModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      senderCheckinId: data['senderCheckinId'],
      receiverCheckinId: data['receiverCheckinId'],
      messageType: messageType,
      content: data['content'],
      templateId: data['templateId'],
      mediaUrl: data['mediaUrl'],
      isRead: data['isRead'] ?? false,
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
      reaction: reaction,
      reactionAt: (data['reactionAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      senderAnonymousId: data['senderAnonymousId'] ?? 'User#0000',
      senderDisplayName: data['senderDisplayName'],
      senderAvatarUrl: data['senderAvatarUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    String messageTypeStr;
    switch (messageType) {
      case MessageType.template:
        messageTypeStr = 'template';
        break;
      case MessageType.voice:
        messageTypeStr = 'voice';
        break;
      case MessageType.sticker:
        messageTypeStr = 'sticker';
        break;
      default:
        messageTypeStr = 'text';
    }

    String? reactionStr;
    if (reaction != null) {
      switch (reaction!) {
        case ReactionType.thanks:
          reactionStr = 'thanks';
          break;
        case ReactionType.feelingBetter:
          reactionStr = 'feeling_better';
          break;
        case ReactionType.wantToChat:
          reactionStr = 'want_to_chat';
          break;
      }
    }

    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderCheckinId': senderCheckinId,
      'receiverCheckinId': receiverCheckinId,
      'messageType': messageTypeStr,
      'content': content,
      'templateId': templateId,
      'mediaUrl': mediaUrl,
      'isRead': isRead,
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'reaction': reactionStr,
      'reactionAt': reactionAt != null ? Timestamp.fromDate(reactionAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'senderAnonymousId': senderAnonymousId,
      'senderDisplayName': senderDisplayName,
      'senderAvatarUrl': senderAvatarUrl,
    };
  }

  /// Get sender display name
  String get displayName => senderDisplayName ?? senderAnonymousId;
}
