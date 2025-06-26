const express = require("express");
const { testAPI } = require("../controllers/testController");

const router = express.Router();

router.get("/", testAPI);

module.exports = router;
