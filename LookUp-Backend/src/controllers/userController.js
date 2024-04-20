const User = require("../models/userModel");

const signupUser = async (req, res) => {
    console.log(req.body);
    const { phoneNumber } = req.body;
    try {
        const user = await User.signup(phoneNumber);
        res.status(200).json({ user });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { signupUser };