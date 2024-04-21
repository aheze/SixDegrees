const mongoose = require("mongoose");
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
  if(!phoneNumber) phoneNumber = "";
  if(!name) name = "";
  if(!email) email = "";
  if(!birthdayMonth) birthdayMonth = "";
  if(!birthdayDay) birthdayDay = "";
  if(!birthdayYear) birthdayYear = "";
  if (existsInDB) {
    if(!existsInDB.birthdayMonth) await this.findOneAndUpdate({phoneNumber: phoneNumber},{$set: {'birthdayMonth':birthdayMonth}});
    if(!existsInDB.birthdayDay) await this.findOneAndUpdate({phoneNumber: phoneNumber},{$set: {'birthdayDay':birthdayDay}});
    if(!existsInDB.birthdayYear) await this.findOneAndUpdate({phoneNumber: phoneNumber},{$set: {'birthdayYear':birthdayYear}});
    if(!existsInDB.email) await this.findOneAndUpdate({phoneNumber: phoneNumber},{$set: {'email':email}});
    if(!existsInDB.name) await this.findOneAndUpdate({phoneNumber: phoneNumber},{$set: {'name':name}});
    return existsInDB;
  }
  const user = await this.create({ phoneNumber, name, email, birthdayMonth, birthdayDay, birthdayYear });
  return user;
};

module.exports = mongoose.model("Metadata", metadataSchema);