// routes/applianceRoutes.js
import { Router } from "express";
// Import middleware and controller
import auth from "../middlewares/auth.js";
import {
  addAppliance,
  getUserAppliances,
  deleteAppliance,
  updateAppliance,
} from "../controllers/applianceController.js";

const router = Router();
// Add new appliance (requires authentication)
router.post("/add", auth, addAppliance);

// Get all user appliance (requires authentication)
router.get("/all", auth, getUserAppliances);

router.delete("/:id", auth, deleteAppliance);

router.put("/:id", auth, updateAppliance);

export default router;
