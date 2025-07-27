import { Router } from "express";
import auth from "../middlewares/auth.js";
import { getConsumption, getCurrentPeriod, getPeriods, getHourly } from "../controllers/consumptionControllers.js";

const router = Router();
router.get("/", auth, getConsumption);
router.get("/current", auth, getCurrentPeriod);
router.get("/periods", auth, getPeriods);
router.get("/hourly", auth, getHourly);
export default router;
