import User from "../models/User.js";
import { errorHandler } from "../utils/errorHandler.js";

export const updatePreferences = async (req, res, next) => {
  try {
    const uid = req.user.uid;
    const updates = req.body; // validated on client

    const user = await User.findOneAndUpdate(
      { firebaseUid: uid },
      { $set: { preferences: updates } },
      { new: true }
    );

    if (!user) return next(errorHandler(404, "User not found"));

    res.status(200).json(user);
  } catch (err) {
    next(errorHandler(500, "Failed to update preferences"));
  }
};
