const express = require("express");
const mongoose = require("mongoose");
const userRoutes = require("./routes/userRoutes");

const app = express();

mongoose
  .connect("mongodb+srv://lookup:iwanttolookup@cluster0.3sjbfru.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
  .then(() => {
    if (process.env.NODE_ENV !== "test") {
      app.listen(4000, () => {
        console.log(
          "connected to db & listening on port",
          4000
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
app.get("/", (req, res) => res.json("LookUp Server Online"));

module.exports = app;