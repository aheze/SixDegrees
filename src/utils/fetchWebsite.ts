// export a ts function that fetches the website and returns the html content w/ node-fetch
import fetch from "node-fetch";
import { JSDOM } from "jsdom";

export async function fetchWebsite(url: string): Promise<string> {
  const response = await fetch(url);
  const text = await response.text();

  // dom parser to parse the html content and return the text
  const dom = new JSDOM(text);
  const { document } = dom.window;

  console.log(document.body.innerText);

  return document.body.innerText;
}
