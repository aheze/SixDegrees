const mongoose = require("mongoose");
const { exists } = require("./metadataModel");
const Schema = mongoose.Schema;

const userSchema = new Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  contacts: {
    type: [String]
  }
});

userSchema.statics.signup = async function (phoneNumber, contacts) {
  if (!phoneNumber) {
    throw Error("All fields must be filled");
  }
  const existsInDB = await this.findOne({ phoneNumber });
  if (existsInDB) {
    return existsInDB;
  }
  const user = await this.create({ phoneNumber, contacts });
  return user;
};

module.exports = mongoose.model("User", userSchema);