const express = require("express");
const mongoose = require("mongoose");
const userRoutes = require("./routes/userRoutes");
const graphRoutes = require("./routes/graphRoutes");

const app = express();

mongoose
  .connect("mongodb+srv://lookup:lookup@cluster0.iv5bsvu.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
  .then(() => {
    if (process.env.NODE_ENV !== "test") {
      app.listen(80, () => {
        console.log(
          "connected to db & listening on port",
          80
        );
      });
      app.get("/", (req, res) => res.json("LookUp Server Online"));
    }
  })
  .catch((error) => {
    console.log(error);
  });

app.use(express.json());

app.use((req, res, next) => {
    console.log(req.path, req.method)
    next()
})

app.use("/user", userRoutes);
app.use("/graph", graphRoutes);
app.get("/", (req, res) => res.json("LookUp Server Online"));

module.exports = app;