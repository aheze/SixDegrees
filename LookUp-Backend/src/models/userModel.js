const mongoose = require("mongoose");
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
        throw Error("Number already in use");
    }
  const user = await this.create({ phoneNumber, contacts });
  return user;
};

module.exports = mongoose.model("User", userSchema);