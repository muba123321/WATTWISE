import { Router } from "express";
import auth from "../middlewares/auth.js";
import { getReadings, addReading, updateReading, deleteReading } from "../controllers/meterControllers.js";

const router = Router();
router.get("/", auth, getReadings);
router.post("/", auth, addReading);
router.put("/:id", auth, updateReading);
router.delete("/:id", auth, deleteReading);
export default router;
