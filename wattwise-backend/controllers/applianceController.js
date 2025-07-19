// controllers/applianceController.js
import Appliance from "../models/Appliance.js";
import { addApplianceSchema } from "../validators/applianceValidators.js";
import { handleValidationError, errorHandler } from "../utils/errorHandler.js";

export const addAppliance = async (req, res, next) => {
  try {
    // Step 1: Validate data
    const data = handleValidationError(addApplianceSchema, req.body);

    const { name, usageHoursPerDay, powerRatingWatts } = data;

    // Optional safety check
    if (!name || !usageHoursPerDay || !powerRatingWatts) {
      return next(errorHandler(400, "All fields are required"));
    }

    // Step 2: Create appliance
    const appliance = await Appliance.create({
      name,
      usageHoursPerDay,
      powerRatingWatts,
      user: req.user.id,
    });

    res.status(201).json({ success: true, data: appliance });
  } catch (err) {
    next(err);
  }
};

export const getUserAppliances = async (req, res, next) => {
  try {
    const appliance = await Appliance.find({ user: req.user.id });
    res.status(200).json({ success: true, data: appliances });
  } catch (err) {
    next(err);
  }
};

export const deleteAppliance = async (req, res, next) => {
  try {
    const { id } = req.params;
    const appliance = await Appliance.findOneAndDelete({
      _id: id,
      user: req.user.id,
    });

    if (!appliance)
      return next(errorHandler(404, "Appliance not found or unauthorized"));

    res.status(200).json({ success: true, msg: "Appliance deleted" });
  } catch (err) {
    next(errorHandler(500, "Failed to delete Appliance"));
  }
};

export const updateAppliance = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, usageHoursPerDay, powerRatingWatts } = req.body;

    const appliance = await Appliance.findOneAndUpdate(
      { _id: id, user: req.user.id },
      { name, usageHoursPerDay, powerRatingWatts },
      { new: true }
    );

    if (!appliance)
      return next(errorHandler(404, "Appliance not found or unauthorized"));

    res.status(200).json({ success: true, data: appliance });
  } catch (err) {
    next(errorHandler(500, "Failed to update Appliance"));
  }
};
