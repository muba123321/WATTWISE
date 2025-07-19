import admin from "firebase-admin";
import serviceAccount from "../serviceAccountKey.js";

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export { admin };
