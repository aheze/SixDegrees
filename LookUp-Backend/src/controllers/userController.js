const User = require("../models/userModel");
const Metadata = require("../models/metadataModel");
const mongoose = require("mongoose");

const signupUser = async (req, res) => {
    const { contactsDictionary, ownPhoneNumber, ownName } = req.body;
    let numbers = Object.keys(contactsDictionary);
    try {
        const user = await User.signup(ownPhoneNumber, numbers);
        for(number of numbers){
            const { birthdayMonth, birthdayDay, name, email, birthdayYear, phoneNumber } = contactsDictionary[number];
            Metadata.createMetadata(phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear);
        }
        Metadata.createMetadata(ownPhoneNumber, ownName);
        res.status(200).json({ user });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

async function clearCollections() {
    const collections = mongoose.connection.collections;
    await Promise.all(
        Object.values(collections).map(async (collection) => {
        await collection.deleteMany({}); // an empty mongodb selector object ({}) must be passed as the filter argument
        })
    );
}

const clearDB = async (req, res) => {
    try{
        await clearCollections();
        res.status(200).json({ "Message": "Clear DB Success" });
    }
    catch (error) {
        res.status(400).json({ error: error.message });
    }
}


module.exports = { signupUser, clearDB };