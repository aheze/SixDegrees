// object type for user in typescript schema

/*

Example User Schema:

{
  "bio": "Neel Redkar - UCLA '27 | AI @ Notion | HackClub | Anti-techbro | Cookies enthusiast | Lover of code and anime | HMU for a funny joke!",
  "tags": ["AI", "Notion", "HackClub", "UCLA", "Cookies", "Code", "Anime"],
  "hobbies": ["Web development", "Game development", "Philosophy", "Reading", "Music"],
  "potential_friends": "Neel might enjoy connecting with fellow AI enthusiasts, tech-savvy individuals passionate about innovation, philosophy buffs, and anyone with a great sense of humor!",
  "links": [
   "https://neelr.dev/",
   "https://www.instagram.com/neelr01/",
   "https://twitter.com/_neelr_"
  ]
}
*/

export interface BioData {
  bio: string;
  tags: string[];
  hobbies: string[];
  potential_friends: string;
  links: string[];
}
