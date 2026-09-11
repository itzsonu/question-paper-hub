import dotenv from "dotenv";
import app from "./app";

// Load environment variables
dotenv.config();

// Port comes from .env
// If PORT is not available, use 5000
const PORT = process.env.PORT || 5000;

// Start the server
app.listen(PORT, () => {
  console.log(`Backend server running on port ${PORT}`);
});
