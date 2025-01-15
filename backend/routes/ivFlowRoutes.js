const express = require("express");
const router = express.Router();
const { updateIVFlowData } = require("../controllers/ivFlowController");

// Route to update IV flow data
router.post("/", updateIVFlowData);

module.exports = router;
