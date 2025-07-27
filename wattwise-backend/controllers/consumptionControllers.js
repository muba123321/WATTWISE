import MeterReading from "../models/MeterReading.js";
import { errorHandler } from "../utils/errorHandler.js";

export const getConsumption = async (req, res, next) => {
  try {
    const readings = await MeterReading.find({ user: req.user.id }).sort("date");
    res.status(200).json(readings);
  } catch (err) {
    next(errorHandler(500, "Failed to fetch consumption data"));
  }
};

export const getCurrentPeriod = async (req, res, next) => {
  try {
    const last = await MeterReading.findOne({ user: req.user.id }).sort("-date");
    const first = await MeterReading.findOne({ user: req.user.id }).sort("date");
    res.status(200).json({ start: first, end: last });
  } catch (err) {
    next(errorHandler(500, "Failed to fetch current period"));
  }
};

export const getPeriods = async (req, res, next) => {
  try {
    const readings = await MeterReading.find({ user: req.user.id }).sort("date");
    res.status(200).json(readings); // You can group by month on client side
  } catch (err) {
    next(errorHandler(500, "Failed to fetch periods"));
  }
};

export const getHourly = async (req, res, next) => {
  // Placeholder: For now, return last 24 readings
  try {
    const readings = await MeterReading.find({ user: req.user.id })
      .sort("-date")
      .limit(24);
    res.status(200).json(readings);
  } catch (err) {
    next(errorHandler(500, "Failed to fetch hourly consumption"));
  }
};
