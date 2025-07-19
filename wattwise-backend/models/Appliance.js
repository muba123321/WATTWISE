// models/Appliance.js
import { Schema, model } from "mongoose";

const ApplianceSchema = new Schema({
  name: String,
  usageHoursPerDay: Number,
  powerRatingWatts: Number, // e.g., 100W
  user: { type: Schema.Types.ObjectId, ref: "User" },
});

export default model("Appliance", ApplianceSchema);
