require("dotenv").config();
const { initializeApp } = require("firebase/app");
const { getDatabase } = require("firebase/database");
const { getFirestore } = require("firebase/firestore");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
const serviceAccount = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"), // Make sure to handle newlines in the private key
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
};

const adminApp = admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL, // Make sure to add this variable in your .env file
});

// Initialize Firebase Client SDK
const firebaseConfig = {
  apiKey: process.env.FIREBASE_API_KEY,
  authDomain: process.env.FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.FIREBASE_DATABASE_URL,
  projectId: process.env.FIREBASE_PROJECT_ID,
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.FIREBASE_APP_ID,
};
const clientApp = initializeApp(firebaseConfig);

// Get database instances
const adminDb = admin.database();
const clientDb = getDatabase(clientApp);

// Initialize Firestore (Admin and Client)
const adminFirestore = admin.firestore();
const clientFirestore = getFirestore(clientApp);

module.exports = {
  adminDb,
  clientDb,
  adminFirestore,
  clientFirestore,
  admin,
};
