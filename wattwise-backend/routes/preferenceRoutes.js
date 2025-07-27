import { Router } from "express";
import auth from "../middlewares/auth.js";
import { updatePreferences } from "../controllers/preferencesControllers.js";

const router = Router();
router.put("/", auth, updatePreferences);

export default router;
