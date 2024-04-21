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
  bio: {
    type: String
  },
  hobbies: {
    type: [String]
  },
});

analysisModel.statics.createAnalysis = async function (phoneNumber, bio, hobbies) {
  if (!phoneNumber) {
    throw Error("All fields must be filled");
  }
  const existsInDB = await this.findOne({ phoneNumber });
  if (existsInDB) {
    return existsInDB;
  }
  const analysis = await this.create({ phoneNumber, bio, hobbies });
  return analysis;
};

module.exports = mongoose.model("Analysis", analysisModel);