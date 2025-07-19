// validators/deviceValidator.js
import { z } from "zod";

export const addApplianceSchema = z.object({
  name: z.string().min(1, "Appliance name is required"),
  usageHoursPerDay: z.number().min(0.1, "Usage hours must be positive"),
  powerRatingWatts: z.number().min(1, "Power rating must be at least 1W"),
});
