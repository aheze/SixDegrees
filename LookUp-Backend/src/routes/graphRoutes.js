const express = require("express");

const { getGraphPath, getGraph } = require("../controllers/graphController");

const router = express.Router();

router.get("/getPath", getGraphPath);
router.get("/getGraph", getGraph);

module.exports = router;