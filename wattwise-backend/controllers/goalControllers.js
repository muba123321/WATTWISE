import Goal from "../models/Goal.js";
import { errorHandler } from "../utils/errorHandler.js";

export const getGoals = async (req, res, next) => {
  try {
    const goals = await Goal.find({ user: req.user.id });
    res.status(200).json(goals);
  } catch (err) {
    next(errorHandler(500, "Failed to fetch goals"));
  }
};

export const createGoal = async (req, res, next) => {
  try {
    const data = { ...req.body, user: req.user.id };
    const goal = await Goal.create(data);
    res.status(201).json(goal);
  } catch (err) {
    next(errorHandler(500, "Failed to create goal"));
  }
};

export const updateGoal = async (req, res, next) => {
  try {
    const { id } = req.params;
    const goal = await Goal.findOneAndUpdate(
      { _id: id, user: req.user.id },
      req.body,
      { new: true }
    );
    if (!goal) return next(errorHandler(404, "Goal not found"));
    res.status(200).json(goal);
  } catch (err) {
    next(errorHandler(500, "Failed to update goal"));
  }
};

export const deleteGoal = async (req, res, next) => {
  try {
    const { id } = req.params;
    const goal = await Goal.findOneAndDelete({ _id: id, user: req.user.id });
    if (!goal) return next(errorHandler(404, "Goal not found"));
    res.status(200).json({ success: true });
  } catch (err) {
    next(errorHandler(500, "Failed to delete goal"));
  }
};
