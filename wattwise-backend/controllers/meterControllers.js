import MeterReading from "../models/MeterReading.js";
import { errorHandler } from "../utils/errorHandler.js";

export const getReadings = async (req, res, next) => {
  try {
    const readings = await MeterReading.find({ user: req.user.id });
    res.status(200).json(readings);
  } catch (err) {
    next(errorHandler(500, "Failed to fetch meter readings"));
  }
};

export const addReading = async (req, res, next) => {
  try {
    const reading = await MeterReading.create({ ...req.body, user: req.user.id });
    res.status(201).json(reading);
  } catch (err) {
    next(errorHandler(500, "Failed to add meter reading"));
  }
};

export const updateReading = async (req, res, next) => {
  try {
    const { id } = req.params;
    const reading = await MeterReading.findOneAndUpdate(
      { _id: id, user: req.user.id },
      req.body,
      { new: true }
    );
    if (!reading) return next(errorHandler(404, "Meter reading not found"));
    res.status(200).json(reading);
  } catch (err) {
    next(errorHandler(500, "Failed to update meter reading"));
  }
};

export const deleteReading = async (req, res, next) => {
  try {
    const { id } = req.params;
    const reading = await MeterReading.findOneAndDelete({ _id: id, user: req.user.id });
    if (!reading) return next(errorHandler(404, "Meter reading not found"));
    res.status(200).json({ success: true });
  } catch (err) {
    next(errorHandler(500, "Failed to delete meter reading"));
  }
};
