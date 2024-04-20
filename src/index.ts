import express from "express";
import { fetchGemini, BioInput } from "./utils/geminiFetch";
import dotenv from "dotenv";
dotenv.config();

const app = express();
app.use(express.json());

app.get("/", async (req, res) => {
  res.send("wahoo fish tacos");
});

app.get("/api/generateDescription", async (req, res) => {
  // parse query json to BioInput
  let input: BioInput = {
    name: req.body.name as string,
    email: req.body.email as string,
    bio: req.body.bio as string,
    links: req.body.links as string[],
  };

  // fetch data from gemini
  let bioData = await fetchGemini(input);

  res.send(bioData);
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server is running on port " + PORT);
});
