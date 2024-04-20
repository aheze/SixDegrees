const express = require("express");

const { signupUser } = require("../controllers/userController");

const router = express.Router();

router.post("/signup", signupUser);

module.exports = router;