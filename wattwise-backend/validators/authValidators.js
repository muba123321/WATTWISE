import { z } from "zod";

export const registerSchema = z.object({
  firstName: z.string().min(2, "firstName is required"),
  lastName: z.string().min(2, "lastName is required"),
  email: z.string().email("Invalid email"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});
