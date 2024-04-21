const express = require("express");

const { signupUser, clearDB, linkUser, getAnalysis } = require("../controllers/userController");

const router = express.Router();

router.post("/signup", signupUser);
router.delete("/clear", clearDB);
router.post("/link", linkUser);
router.post("/getAnalysis", getAnalysis);

module.exports = router;