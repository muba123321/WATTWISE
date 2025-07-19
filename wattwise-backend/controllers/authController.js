// controllers/authController.js
import User from "../models/User.js";
import { errorHandler } from "../utils/errorHandler.js"; // ✅ double-check your casing (Utils → utils)

export const register = async (req, res, next) => {
  try {
    console.log("🔐 Registering user:", req.body);
    const { email, uid, firstName, lastName, photoUrl, isEmailVerified, createdAt} = req.body;

    // Check if user already exists by Firebase UID
    let user = await User.findOne({ firebaseUid: uid });
    console.log("🔐 New user:", user);
    if (!user) {
      user = await User.create({
        email,
        firebaseUid: uid,
        firstName: firstName || "",
        lastName: lastName || "",
        photoUrl,
        isEmailVerified: isEmailVerified || false,
        // lastLogin: lastLogin ? new Date(lastLogin) : new Date(),
        createdAt: createdAt ? new Date(createdAt) : new Date(),
      });
    } else {
      const updates = {};
      if (user.isEmailVerified !== isEmailVerified) updates.isEmailVerified = isEmailVerified;
      if (user.firstName !== firstName) updates.firstName = firstName;
      if (user.lastName !== lastName) updates.lastName = lastName;
      if (user.photoUrl !== photoUrl) updates.photoUrl = photoUrl;
      if (Object.keys(updates).length > 0) {
        user = await User.findOneAndUpdate(
          { firebaseUid: uid },
          { $set: updates },
          { new: true } 
          );}
    }
    console.log("🔐 User registered:", user);
    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        photoUrl: user.photoUrl,
        isEmailVerified: user.isEmailVerified,
        // lastLogin: user.lastLogin,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    next(errorHandler(500, err.message));
  }
};

export const login = async (req, res, next) => {
  try {
     console.log("🔐 logining user:", req.user);
    const { uid, email, firstName, lastName, picture, createdAt} = req.user;
    const { isEmailVerified } = req.body; // ✅ Grab this from the body

    let user = await User.findOne({ firebaseUid: uid });
    console.log("🔐 Existing user:", user);
    if (!user) {
      user = await User.create({
        firebaseUid: uid,
        email,
        firstName: firstName || "",
        lastName: lastName || "",
        photoUrl: picture,
        isEmailVerified: isEmailVerified || false,
        //lastLogin: lastLogin ? new Date(lastLogin) : new Date(),
        createdAt: createdAt ? new Date(createdAt) : new Date(),
      });
    } else {
      const updates = {};
      if (user.isEmailVerified !== isEmailVerified) updates.isEmailVerified = isEmailVerified;
      if (user.firstName !== firstName) updates.firstName = firstName;
      if (user.lastName !== lastName) updates.lastName = lastName;
      if (user.photoUrl !== picture) updates.photoUrl = picture;
      if (Object.keys(updates).length > 0) {
        user =

          await User.findOneAndUpdate(
          { firebaseUid: uid },
          { $set: updates },
          { new: true }
        );
      }
    } 

    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        photoUrl: user.photoUrl,
        isEmailVerified: user.isEmailVerified,
        // lastLogin: user.lastLogin,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    next(errorHandler(500, err.message));
  }
};

export const getProfile = async (req, res, next) => {
  try {
    const user = await User.findOne({ firebaseUid: req.user.uid });

    if (!user) return next(errorHandler(404, "User not found"));

    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        photoUrl: user.photoUrl,
        isEmailVerified: user.isEmailVerified,
        // lastLogin: user.lastLogin,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    next(errorHandler(500, "Failed to fetch user profile"));
  }
};

// controllers/authController.js

export const updateProfile = async (req, res, next) => {
  try {
    const uid = req.user.uid;

    const updates = {};
    if (req.body.firstName) updates.firstName = req.body.firstName;
    if (req.body.lastName) updates.lastName = req.body.lastName;
    if (req.body.photoUrl) updates.photoUrl = req.body.photoUrl;

    const user = await User.findOneAndUpdate(
      { firebaseUid: uid },
      { $set: updates },
      { new: true }
    );

    if (!user) return next(errorHandler(404, "User not found"));

    res.status(200).json({
      success: true,
      user: {
        id: user._id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        photoUrl: user.photoUrl,
      },
    });
  } catch (err) {
    next(errorHandler(500, "Failed to update profile"));
  }
};

export const deleteAccount = async (req, res, next) => {
  try {
    const userId = req.user.id;
    await User.findByIdAndDelete(userId);
    res.status(200).json({ success: true, msg: "Account deleted" });
  } catch (err) {
    next(errorHandler(500, "Failed to delete account"));
  }
};
