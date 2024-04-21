const express = require("express");

const { getGraphPath, getGraph } = require("../controllers/graphController");

const router = express.Router();

router.get("/getPath", getGraphPath);
router.post("/getGraph", getGraph);

module.exports = router;