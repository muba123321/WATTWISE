import { Schema, model } from "mongoose";

const PreferencesSchema = new Schema({
  isDarkMode: { type: Boolean, default: false },
  currency: { type: String, default: "$" },
  energyUnit: { type: String, default: "kWh" },
  notificationsEnabled: { type: Boolean, default: true },
  notificationTypes: { type: [String], default: ["Usage Alerts"] }
});

const UserSchema = new Schema({
  firebaseUid: { type: String, required: true, unique: true },
  email: { type: String, required: true, unique: true },
  firstName: String,
  lastName: String,
  photoUrl: String,
  isEmailVerified: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
  appliance: [{ type: Schema.Types.ObjectId, ref: "appliance" }],

  // ✅ Embed preferences directly
  preferences: PreferencesSchema,

  goals: [{ type: Schema.Types.ObjectId, ref: "Goal" }],
});

export default model("User", UserSchema);
