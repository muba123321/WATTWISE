import { Router } from "express";
import auth from "../middlewares/auth.js";
import { getGoals, createGoal, updateGoal, deleteGoal } from "../controllers/goalControllers.js";

const router = Router();
router.get("/", auth, getGoals);
router.post("/", auth, createGoal);
router.put("/:id", auth, updateGoal);
router.delete("/:id", auth, deleteGoal);

export default router;
