import { Schema, model } from "mongoose";

const GoalSchema = new Schema({
  title: String,
  description: String,
  targetValue: Number,
  unit: String,
  startDate: Date,
  endDate: Date,
  type: { type: String, enum: ["reduction", "limit"], default: "reduction" },
  status: { type: String, enum: ["active", "completed", "failed"], default: "active" },
  currentValue: { type: Number, default: 0 },
  user: { type: Schema.Types.ObjectId, ref: "User" },
});

export default model("Goal", GoalSchema);
