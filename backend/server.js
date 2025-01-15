const express = require("express");
const cors = require("cors");
const sessionRoutes = require("./routes/sessionRoutes");
const ivFlowRoutes = require("./routes/ivFlowRoutes");
const testRoutes = require("./routes/testRoutes");

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/sessions", sessionRoutes);
app.use("/api/ivflow", ivFlowRoutes);
app.use("/api/test", testRoutes);

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Internal Server Error" });
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
