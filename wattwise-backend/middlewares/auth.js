// middlewares/auth.js
import { getAuth } from "firebase-admin/auth";
import { errorHandler } from "../utils/errorHandler.js";

export default async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith("Bearer ")) {
    return next(errorHandler(403, "Authorization token missing"));
  }

  const token = authHeader.split(" ")[1];
  console.log("🛂 Received Firebase token:", token);
  try {
    const decoded = await getAuth().verifyIdToken(token);
    console.log("🛂 Decoded Firebase token:", decoded);
    req.user = {
      uid: decoded.uid,
      email: decoded.email,
      name: decoded.name,
      picture: decoded.picture,
    };
    next();
  } catch (err) {
    return next(errorHandler(403, "Invalid or expired Firebase token"));
  }
};
