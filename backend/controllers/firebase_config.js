const { initializeApp } = require("firebase/app");
const { getDatabase } = require("firebase/database");

const firebaseConfig = {
  apiKey: "AIzaSyD5QQt7HPAevwlgO9wMN8iHNrbNxx2bLak",
  databaseURL:
    "https://ivflow-50a87-default-rtdb.asia-southeast1.firebasedatabase.app/",
  projectId: "ivflow-50a87",
};

const app = initializeApp(firebaseConfig);
const database = getDatabase(app);

module.exports = database;
