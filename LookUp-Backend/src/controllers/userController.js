const User = require("../models/userModel");
const Metadata = require("../models/metadataModel");
const Analysis = require("../models/analysisModel");
const mongoose = require("mongoose");
var request = require('request');

// const signupUser = async (req, res) => {
//     const { contactsDictionary, ownPhoneNumber, ownName } = req.body;
//     let numbers = Object.keys(contactsDictionary);
//     try {
//         const user = await User.signup(ownPhoneNumber, numbers);
//         for(number of numbers){
//             const { birthdayMonth, birthdayDay, name, email, birthdayYear, phoneNumber } = contactsDictionary[number];
//             Metadata.createMetadata(phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear);
//         }
//         Metadata.createMetadata(ownPhoneNumber, ownName);
//         res.status(200).json({ user });
//     } catch (error) {
//         res.status(400).json({ error: error.message });
//     }
// };

const signupUser = async (req, res) => {
    const { contactsDictionary, ownPhoneNumber, ownName, email, bio, links } = req.body;
    let numbers = Object.keys(contactsDictionary);
    try {
        const user = await User.signup(ownPhoneNumber, numbers);
        for(number of numbers){
            const { birthdayMonth, birthdayDay, name, email, birthdayYear, phoneNumber } = contactsDictionary[number];
            Metadata.createMetadata(phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear);
        }
        Metadata.createMetadata(ownPhoneNumber, ownName);
        res.status(200).json({ user });
        if(!email || !bio || !link) return;
        console.log("calling AI server");
        var options = {
            'method': 'GET',
            'url': 'http://209.38.175.25:8888/api/generateDescription',
            'headers': {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              "name": ownName,
              "email": email,
              "bio": bio,
              "links": links
            })
          };
          request(options, function (error, response) {
            if (error) throw new Error(error);
            if(!response.body) return;
            let analysis = JSON.parse(response.body);
            Analysis.createAnalysis(ownPhoneNumber, analysis.bio, analysis.hobbies)
            console.log("created analysis");
          });

    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const linkUser = async (req, res) => {
    const { sourceUser, destinationUser } = req.body;
    try {
        const src = await User.findOne({phoneNumber: sourceUser});
        let contacts = src.contacts;
        contacts.push(destinationUser);
        await User.findOneAndUpdate({phoneNumber: src},{$set: {'contacts':contacts}});
        res.status(200).json({ user });
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const getAnalysis = async (req, res) => {
    const { phoneNumber } = req.body;
    try {
        const analysis = Analysis.findOne({phoneNumber: phoneNumber});
        if(!analysis) {
            res.status(200).json({"analysis" : "none"});
            return;
        }
        res.status(200).json({ "analysis": analysis });
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


module.exports = { signupUser, clearDB, linkUser, getAnalysis };