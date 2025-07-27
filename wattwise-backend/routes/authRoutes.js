// routes/authRoutes.js
import { Router } from "express";
// Import auth controller methods

import auth from "../middlewares/auth.js";
import {
  register,
  login,
  getProfile,
  updateProfile,
  deleteAccount,
} from "../controllers/authController.js";

const router = Router();

// Register new user
router.post("/register", register);

// Login user
router.post("/login", login);

//get profile
router.get("/profile", auth, getProfile);

//update profile
router.put("/profileUpdate", auth, updateProfile);

// delete user
router.delete("/delete", auth, deleteAccount);

export default router;
