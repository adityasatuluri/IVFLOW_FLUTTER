const express = require("express");
const {
  startSession,
  stopSession,
} = require("../controllers/sessionController");

const router = express.Router();

router.post("/startsession", startSession);
router.post("/stopsession/:sessionId", stopSession);

module.exports = router;
