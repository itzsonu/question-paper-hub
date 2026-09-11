import express from "express";
import cors from "cors";
import { checkDatabaseConnection } from "./database";

// Create Express application
const app = express();

// Allow frontend to communicate with backend
app.use(cors());

// Allow JSON data in requests
app.use(express.json());

// Basic test route
app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "Question Paper Hub API is running",
  });
});

app.get("/api/health/database", async (req, res) => {
  try {
    await checkDatabaseConnection();
    res.json({ success: true, message: "Database connection is healthy" });
  } catch {
    res.status(503).json({
      success: false,
      message: "Database connection is unavailable",
    });
  }
});

export default app;
