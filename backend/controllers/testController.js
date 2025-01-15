exports.testAPI = (req, res) => {
  res.status(200).json({
    status: "success",
    message: "API is working",
  });
};
