const express = require("express");

const { signupUser, clearDB } = require("../controllers/userController");

const router = express.Router();

router.post("/signup", signupUser);
router.delete("/clear", clearDB);

module.exports = router;