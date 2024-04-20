// export a ts function that fetches the website and returns the html content w/ node-fetch
import fetch from "node-fetch";
import { JSDOM } from "jsdom";
import innerTextExport from "styleless-innertext";
import puppeteer from "puppeteer";

export async function fetchWebsite(url: string): Promise<string> {
  const browser = await puppeteer.launch({
    headless: false,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
  });
  const page = await browser.newPage();
  await page.goto(url, { waitUntil: "load" });
  await page.goto(url, { waitUntil: "domcontentloaded" });
  await page.goto(url, { waitUntil: "networkidle0" });
  await page.goto(url, { waitUntil: "networkidle2" });

  const text = await page.evaluate(() => document.body.innerText);

  const allImageLinks = await page.evaluate(() => {
    const images = Array.from(document.getElementsByTagName("img"));
    return images.map((image) => image.src);
  });

  await browser.close();

  return `${text}\n${allImageLinks.join("\n")}`;
}

/* export async function fetchWebsite(url: string): Promise<string> {
  const response = await fetch(url);
  const text = await response.text();

  // dom parser to parse the html content and return the text
  const dom = new JSDOM(text);
  const innerText = innerTextExport(dom.window.document.body);

  console.log(innerText);

  return innerText;
}
 */
