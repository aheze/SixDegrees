import { GoogleGenerativeAI } from "@google/generative-ai";
import similarity from "compute-cosine-similarity";
import { BioData } from "./userSchema";
import fetch from "node-fetch";
import { fetchWebsite } from "./fetchWebsite";
import dotenv from "dotenv";
dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY || "");

const model = genAI.getGenerativeModel({ model: "gemini-1.5-pro-latest" });
const embedding_model = genAI.getGenerativeModel({ model: "embedding-001" });

const GLOBAL_PROMPT_EXAMPLE_PARTS = [
  "input: name: Neel Redkar\nemail: neel.redkar@gmail.com\nbio (optional):\n=====\nLinks:\n\nhttps://neelr.dev/\nhttps://www.instagram.com/neelr01/\ntwitter.com/_neelr_\n=====\nDumps:\n",
  'Hello!NotebookRésumegithub / twitter / linkedin / insta / facebookHi, I’m Neel.Imagination is the living power and prime agent of all human perception.- Samuel Taylor Coleridgesome cool things i\'ve done:At 18 presented a completely independent research @ NeurIPS as one of the youngest researchers (funded by an EV Grant)Got a $25k scholarship for creating new AI algorithms to make artificial photosynthesis & carbon capture a reality (presented @ AAAI23)Raised $80k+ for various hackathons while also founding & raising for a startup using RL for a new approach to neuromodulation(for math nerds I also was the lead dev at the start for sinerider, a game supported by 3Blue1Brown, my fav)Now the youngest intern @ Notion (AI)!Currently a freshman at UCLA, lover of code, and avid exclamation mark (over?) user! As a philosophy nerd, I tend to research the boundaries of AI. Though a maker at heart, I am a (self) certified generalist—web dev, game dev, systems, & anime.It all started with an invitation to Next19—my first (not last) conference—which taught me one of my favorite ideas, "don’t let school take away from your education".Interested in interacting with the "real world", I became an active member of HackClub, organizing many events (including AngelHacks & the Summer of Making). IMO I made some cool projects too.Blasting off I gathered experiences—some crazy AI internships, took part in the worlds longest (3,502 mile-long) hackathon, and independent research on turning CO2 into fuel @ NeurIPS! I even created my first startup where we got funding!If you find any of this interesting, or just want to talk, hit me up with an email with something resembling my name [at] this domain! I’m trying to read more, so recommend me some books/music!Most recently caught "test"-ing @ neelr/MyWebsiteNotebook Posts!my "favorite" year recapped!12/31/2023 maybe favorite is just a word i shouldn\'t use as often#featured / #new years / #reflection / #articleucla so farrrr11/11/2023 a brief not so brief update on life#fun / #updatesKairos!!7/7/2023 I went to my first 🐀 camp (rationality is so very cool)#fun / #camp / #hackathonsone more day5/31/2023 what do you do when it really is the last day?#featured / #my take / #schoolFind me at Los Angeles where its 53°F and Mostly CloudySource | v1neelr listening \n\nHomeSearchExploreReels8MessagesNotificationsCreateProfile9+ThreadsMoreneelr01Edit profileView archiveAd tools13 posts1,871 followers1,915 followingNeel Redkarhe/himneelr01Pizza placeucla ‘27 | ai @ notionhackclub | anti-techbro | cookiesHMU if you want a funny jokeneelr.dev1.9K accounts reached in the last 30 days. View insights.ISEF!ZephyrNewPOSTSSAVEDTAGGED',
  "MetaAboutBlogJobsHelpAPIPrivacyConsumer Health PrivacyTermsLocationsInstagram LiteThreadsContact Uploading & Non-UsersMeta VerifiedEnglishAfrikaansالعربيةČeštinaDanskDeutschΕλληνικάEnglishEnglish (UK)Español (España)EspañolفارسیSuomiFrançaisעבריתBahasa IndonesiaItaliano日本語한국어Bahasa MelayuNorskNederlandsPolskiPortuguês (Brasil)Português (Portugal)РусскийSvenskaภาษาไทยFilipinoTürkçe中文(简体)中文(台灣)বাংলাગુજરાતીहिन्दीHrvatskiMagyarಕನ್ನಡമലയാളംमराठीनेपालीਪੰਜਾਬੀසිංහලSlovenčinaதமிழ்తెలుగుاردوTiếng Việt中文(香港)БългарскиFrançais (Canada)RomânăСрпскиУкраїнська© 2024 Instagram from Meta\non oxygen to roll back the clock:",
  "Iris, The Goo Goo Dolls0:13 / 4:49",
  'output: {\n  "bio": "Neel Redkar - UCLA \'27 | AI @ Notion | HackClub | Anti-techbro | Cookies enthusiast | Lover of code and anime | HMU for a funny joke!",\n  "tags": ["AI", "Notion", "HackClub", "UCLA", "Cookies", "Code", "Anime"],\n  "hobbies": ["Web development", "Game development", "Philosophy", "Reading", "Music"],\n  "potential_friends": "Neel might enjoy connecting with fellow AI enthusiasts, tech-savvy individuals passionate about innovation, philosophy buffs, and anyone with a great sense of humor!",\n  "links": ["https://neelr.dev/",\n   "https://www.instagram.com/neelr01/",\n  "https://twitter.com/_neelr_"\n  ]\n}',
];

interface BioInput {
  name: string;
  email: string;
  bio: string;
  links: string[];
}

const fetchGemini = async (input: BioInput): Promise<BioData> => {
  let dumps = "";
  const images = [];

  for (let link of input.links) {
    const [text, links] = await fetchWebsite(link);
    dumps += text;
    images.push(...links);
  }

  const uniqueImageLinks = [...new Set(images)];

  console.log(uniqueImageLinks);

  for (let imageLink of uniqueImageLinks) {
    dumps.replaceAll(imageLink, "");
  }

  for (let link of uniqueImageLinks) {
    console.log(link);
    try {
      const response = await fetch(link);
      const buffer = await response.buffer();

      const mimeType = response.headers.get("content-type") || "image/jpeg";

      images.push({
        inlineData: {
          data: buffer.toString("base64"),
          mimeType: mimeType,
        },
      });
    } catch (e) {
      console.error(e);
    }
  }

  let prompt_content = [
    `input:
    name: ${input.name}
    email: ${input.email}
    bio (optional): ${input.bio}
    =====
    Links:
    ${input.links.map((link) => `\n${link}`).join("")}
    =====
    Dumps:
    ${dumps}
    =====
    Images:
    `,
    ...images,
    `

    Fill in everything with as much as possible as a json. NO COMMENTS OR OTHER TEXT. add comments about the images in the bio/tags/hobbies

    interface BioData {
        bio: string;
        tags: string[];
        hobbies: string[];
        potential_friends: string;
        links: string[];
      }
    `,
    "output: ",
  ];

  console.log(uniqueImageLinks);

  const result = await model.generateContent([
    ...GLOBAL_PROMPT_EXAMPLE_PARTS,
    ...prompt_content,
  ]);
  let response = await result.response;
  let text = response.text();

  // remove ```json from the start and ``` from the end if present
  text = text.replace("```json", "").replace("```", "");

  console.log(text);

  let unstructuredData: any = JSON.parse(text);

  let bioData: BioData = {
    bio: unstructuredData.bio || "No bio found",
    tags: unstructuredData.tags || [],
    hobbies: unstructuredData.hobbies || [],
    potential_friends:
      unstructuredData.potential_friends || "No potential friends found",
    links: Object.values(unstructuredData.links) || [],
  };

  return bioData;
};

const getSimilarity = async (person1: string, person2: string) => {
  let prompt_content = [
    `input:
    take the two people and output a blurb describing how similar they are + common interests

    think spotify wrapped but for people—keep it to ~3 sentences

    person1: ${person1}
    person2: ${person2}
    `,
    "output: ",
  ];

  const result = await model.generateContent([...prompt_content]);
  let response = await result.response;
  let text = response.text();

  const embeddings_person1 = (await embedding_model.embedContent(person1))
    .embedding.values;
  const embeddings_person2 = (await embedding_model.embedContent(person2))
    .embedding.values;

  let sim = similarity(embeddings_person1, embeddings_person2);

  return {
    similarity: sim,
    description: text,
  };
};

export { fetchGemini, getSimilarity, BioInput };
