const mongoose = require("mongoose");
const { exists } = require("./userModel");
const Schema = mongoose.Schema;

const metadataSchema = new Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
  },
  name: {
    type: String,
    required: false,
  },
  email: {
    type: String,
    required: false,
  },
  birthdayMonth: {
    type: Number,
    required: false,
  },
  birthdayDay: {
    type: Number,
    required: false,
  },
  birthdayYear: {
    type: Number,
    required: false,
  },
});

metadataSchema.statics.createMetadata = async function (phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear) {
  if (!phoneNumber) {
    throw Error("Need Phone Number");
  }
  const existsInDB = await this.findOne({ phoneNumber });
  if (existsInDB) {
    return existsInDB;
  }
  if(!phoneNumber) phoneNumber = ""
  if(!name) name = ""
  if(!email) email = ""
  if(!birthdayMonth) birthdayMonth = ""
  if(!birthdayDay) birthdayDay = ""
  if(!birthdayYear) birthdayYear = ""
  const user = await this.create({ phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear });
  return user;
};

module.exports = mongoose.model("Metadata", metadataSchema);