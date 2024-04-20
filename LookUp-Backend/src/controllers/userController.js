const User = require("../models/userModel");
const Metadata = require("../models/metadataModel");

const signupUser = async (req, res) => {
    const { contactsDictionary, ownPhoneNumber, ownName } = req.body;
    let numbers = Object.keys(contactsDictionary);
    try {
        const user = await User.signup(ownPhoneNumber, numbers);
        for(number of numbers){
            const { birthdayMonth, birthdayDay, name, email, birthdayYear, phoneNumber } = contactsDictionary[number];
            const profile = Metadata.createMetadata(phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear);
        }
        Metadata.createMetadata(ownPhoneNumber);
        res.status(200).json({ user });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports = { signupUser };