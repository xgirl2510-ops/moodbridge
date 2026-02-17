const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();
const db = getFirestore();

/**
 * When a new encouragement is created, send push notification to receiver.
 */
exports.onEncouragementCreated = onDocumentCreated(
  "encouragements/{docId}",
  async (event) => {
    const data = event.data?.data();
    if (!data) return;

    const receiverId = data.receiverId;
    const senderName = data.senderDisplayName || data.senderAnonymousId || "Ai đó";
    const content = data.content || "Bạn nhận được lời động viên mới!";

    // Get receiver's FCM token and push settings
    const receiverDoc = await db.collection("users").doc(receiverId).get();
    if (!receiverDoc.exists) return;

    const receiver = receiverDoc.data();
    const fcmToken = receiver.fcmToken;
    const pushEnabled = receiver.pushEnabled !== false; // default true

    if (!fcmToken || !pushEnabled) {
      console.log(`Skip push for ${receiverId}: token=${!!fcmToken}, enabled=${pushEnabled}`);
      return;
    }

    // Truncate content for notification
    const shortContent = content.length > 100 ? content.substring(0, 100) + "..." : content;

    const message = {
      token: fcmToken,
      notification: {
        title: `💙 ${senderName} gửi lời động viên`,
        body: shortContent,
      },
      data: {
        type: "encouragement",
        encouragementId: event.params.docId,
        senderId: data.senderId || "",
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    try {
      await getMessaging().send(message);
      console.log(`Push sent to ${receiverId} for encouragement ${event.params.docId}`);
    } catch (error) {
      console.error(`Failed to send push to ${receiverId}:`, error.message);
      // If token is invalid, remove it
      if (
        error.code === "messaging/invalid-registration-token" ||
        error.code === "messaging/registration-token-not-registered"
      ) {
        await db.collection("users").doc(receiverId).update({
          fcmToken: null,
        });
        console.log(`Removed invalid FCM token for ${receiverId}`);
      }
    }
  }
);

/**
 * When a reaction is added to an encouragement, notify the sender.
 */
const { onDocumentUpdated } = require("firebase-functions/v2/firestore");

exports.onEncouragementUpdated = onDocumentUpdated(
  "encouragements/{docId}",
  async (event) => {
    const before = event.data?.before?.data();
    const after = event.data?.after?.data();
    if (!before || !after) return;

    // Only trigger if reaction was just added
    if (before.reaction || !after.reaction) return;

    const senderId = after.senderId;
    const receiverName = "Người bạn động viên";

    let reactionText;
    switch (after.reaction) {
      case "thanks":
        reactionText = "❤️ đã cảm ơn bạn";
        break;
      case "feeling_better":
        reactionText = "💕 đã thả tim cho bạn";
        break;
      case "want_to_chat":
        reactionText = "💬 muốn kết nối với bạn";
        break;
      default:
        reactionText = "đã phản hồi lời động viên của bạn";
    }

    // Get sender's FCM token
    const senderDoc = await db.collection("users").doc(senderId).get();
    if (!senderDoc.exists) return;

    const sender = senderDoc.data();
    const fcmToken = sender.fcmToken;
    const pushEnabled = sender.pushEnabled !== false;

    if (!fcmToken || !pushEnabled) return;

    const message = {
      token: fcmToken,
      notification: {
        title: "💝 Phản hồi mới",
        body: `${receiverName} ${reactionText}`,
      },
      data: {
        type: "reaction",
        encouragementId: event.params.docId,
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: "default",
          },
        },
      },
    };

    try {
      await getMessaging().send(message);
      console.log(`Reaction push sent to ${senderId}`);
    } catch (error) {
      console.error(`Failed to send reaction push:`, error.message);
    }
  }
);
