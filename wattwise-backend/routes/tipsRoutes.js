import { Router } from "express";
import { getTips, getRandomTip, getTipsByAppliance } from "../controllers/tipsControllers.js";

const router = Router();
router.get("/", getTips);
router.get("/random", getRandomTip);
router.get("/appliance/:applianceType", getTipsByAppliance);
export default router;