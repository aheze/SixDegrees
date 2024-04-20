const express = require("express");

const { getGraphPath } = require("../controllers/graphController");

const router = express.Router();

router.get("/getPath", getGraphPath);

module.exports = router;