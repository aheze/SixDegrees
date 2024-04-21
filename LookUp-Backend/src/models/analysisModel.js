const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const analysisModel = new Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  name: {
    type: String
  },
  bio: {
    type: String
  },
  hobbies: {
    type: [String]
  },
});

analysisModel.statics.createAnalysis = async function (phoneNumber, name, bio, hobbies) {
  if (!phoneNumber) {
    throw Error("All fields must be filled");
  }
  const existsInDB = await this.findOne({ phoneNumber });
  if (existsInDB) {
    return existsInDB;
  }
  const analysis = await this.create({ phoneNumber, name, bio, hobbies });
  return analysis;
};

module.exports = mongoose.model("Analysis", analysisModel);