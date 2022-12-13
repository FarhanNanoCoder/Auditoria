const functions = require("firebase-functions");
const admin = require("firebase-admin");

// var serviceAccount = require("F:/Auditoria/App1.0/auditoria/serviceAccountKey.json");
admin.initializeApp(
//   credential: admin.credential.cert(serviceAccount)
);

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateNotificationItem = functions.firestore
.document('/notifications/{userId}/userNotifications/{notificationId}')
.onCreate(async(snaphot,context)=>{
   console.log('Notification created',snaphot.data());

   //getting the user
   const userId = context.params.userId;
   const userRef = admin.firestore().doc(`users/${userId}`);
   const userLiveDataRef = admin.firestore().doc(`liveData/${userId}`);
   const userLiveData = await userLiveDataRef.get();
   const doc = await userRef.get();

   //checking if they have the notification token
   const androidNotificationToken = 
   doc.data().androidNotificationToken;

   if(androidNotificationToken){
      sendNotification(androidNotificationToken,snaphot.data());
      const value = userLiveData.data()['recentNotifications']+1;
      await userLiveDataRef
      .update({'recentNotifications': value});
      console.log("recent notification updated", value);
   }else{
      console.log("No notification found for the user");
   }

   function sendNotification(androidNotificationToken,notificationItem){
      let body;

      switch(notificationItem.eventType){
         case "like":
            body = `${notificationItem.username} liked your post`;
            break;
         case "follow":
            body = `${notificationItem.username} has started following you`;
            break;
         case "followersPost":
            body = `${notificationItem.username} posted something. Check it out`;
            break;
         case "comment":
            body = `${notificationItem.username} commented on your post`;
            break;
         default:
            break;
      }

      const message ={
         notification : { 
            'body':body,
            'image':notificationItem.imageUrl,
         },
         token: androidNotificationToken,
         data : { recipient: userId }
      };

      admin.messaging().send(message)
      .then(response =>{
            console.log("Succesfully sent message", response);
         }
      ).catch(error=>{
         console.log("Error sending message", error);
      })
   }
})

//sends notification to all user followers
exports.onCreatePost = functions.firestore
.document('/allPosts/{postId}')
.onCreate(async(snaphot,context)=>{
   const postId = context.params.postId;
   const post = snaphot.data();
   const userId = post.uid;

   const followersRef = admin.firestore()
   .collection("allFollowers").doc(userId)
   .collection("userFollowers");
   
   const followers = await followersRef.get();

   console.log("Got all followers",followers.size);

   if(followers.size!=0){
      for(let i=0;i<followers.size;i++){
         const followerId = followers.docs[i].data()['uid'];
         const followerDoc = await admin.firestore().doc(`users/${followerId}`).get();
         const userDoc = await admin.firestore().doc(`users/${userId}`).get();
         if(followerDoc.exists){
            const notificationRef = admin.firestore()
            .collection("notifications")
            .doc(followerId)
            .collection("userNotifications");
            
            const did = notificationRef.doc().id.toString();
            await notificationRef.doc(did).set(
               {
                  'eventType':'followersPost',
                  'did': did,
                  'pid': postId,
                  'uid': userId,
                  'username':userDoc.data()['username'],
                  'imageUrl': post.imageUrl,
                  'isSeen':false,
                  'timestamp': Date.now(),

               }
            );
            console.log("Notification saved successfully", did);
         }else{
            await followers.docs[i].reference.delete();
         }
      }
   }

})

exports.onCreateComment = functions.firestore
.document('/postComments/{postId}/userComments/{commentId}')
.onCreate(async(context,snaphot)=>{

   const postId = context.params.postId;
   
   console.log("post id", postId);
   const comment = snaphot.data();

   const postDoc = await admin.firestore()
   .doc(`allPosts/${postId}`).get();
   console.log("Got the post");

   const commentedUser = await admin.firestore()
   .doc(`users/${comment.uid}`).get();
   console.log("Got the user commented");
   
   const ownerId = postDoc.data()['uid'];
   console.log("Got the post owner",ownerId);

   const notificationRef = admin.firestore()
            .collection("notifications")
            .doc(ownerId)
            .collection("userNotifications");

   const did = notificationRef.doc().id.toString();

   await notificationRef.doc(did).set(
       {
          'eventType':'comment',
          'did': did,
          'pid': postId,
          'uid': comment.uid,
          'username':commentedUser.data()['username'],
          'imageUrl': commentedUser.data()['photoUrl'],
          'isSeen':false,
          'timestamp': Date.now(),

       }
   );

})