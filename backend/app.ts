import express from "express";
import cors from "cors";

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

export default app;