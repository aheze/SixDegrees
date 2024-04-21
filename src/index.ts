import express from "express";
import { fetchGemini, getSimilarity, BioInput } from "./utils/geminiFetch";
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

app.get("/api/similarity", async (req, res) => {
  const person1 = req.body.person1 as string;
  const person2 = req.body.person2 as string;

  const similarity = await getSimilarity(person1, person2);

  res.send(similarity);
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log("Server is running on port " + PORT);
});
