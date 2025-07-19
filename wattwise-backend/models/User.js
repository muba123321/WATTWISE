// models/User.js
import { Schema, model } from "mongoose";

const UserSchema = new Schema({
  firebaseUid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  firstName: String,
  lastName: String,
  photoUrl: String,
  isEmailVerified: { type: Boolean, default: false },
  // lastLogin: { type: Date},
  createdAt: { type: Date, default: Date.now },
  appliance: [{ type: Schema.Types.ObjectId, ref: "appliance" }],
});

export default model("User", UserSchema);
