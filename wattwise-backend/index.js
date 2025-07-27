// app.js
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import authRoutes from "./routes/authRoutes.js";
import applianceRoutes from "./routes/applianceRoutes.js";
import preferenceRoutes from "./routes/preferenceRoutes.js";
import consumptionRoutes from "./routes/consumptionRoutes.js";
import goalRoutes from "./routes/goalRoutes.js";
import meterRoutes from "./routes/meterRoutes.js";
import tipsRoutes from "./routes/tipsRoutes.js";
import dbConnection from "./config/server.js";
import "./config/firebase.js";

dotenv.config();

const app = express();

dbConnection();

app.use(cors());
app.use(express.json());

app.use("/api/auth", authRoutes);
app.use("/api/appliance", applianceRoutes);
app.use("/api/user/preferences", preferenceRoutes);
app.use("/api/meter-readings", meterRoutes);
app.use("/api/consumption", consumptionRoutes);
app.use("/api/tips", tipsRoutes);
app.use("/api/goals", goalRoutes);

app.use((err, req, res, next) => {
  console.error(err);
  const statusCode = err.statusCode || 500;
  const message = err.message || "Internal Server Error";
  res.status(statusCode).json({
    success: false,
    statusCode,
    message,
  });
});

app.listen(process.env.PORT, '0.0.0.0',() =>
  console.log(`Server is running on port ${process.env.PORT}`)
);
