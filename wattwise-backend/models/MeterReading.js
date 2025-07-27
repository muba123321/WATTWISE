
import { Schema, model } from "mongoose";

const MeterReadingSchema = new Schema({
  value: Number,
  unit: String,
  imageUrl: String,
  date: { type: Date, default: Date.now },
  user: { type: Schema.Types.ObjectId, ref: "User" },
});

export default model("MeterReading", MeterReadingSchema);
