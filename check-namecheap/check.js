#!/usr/bin/env node
const USERNAME = "quriops";

let CACHED_IP = "";
async function getMyIp() {
  if (!CACHED_IP)
    CACHED_IP = await (
      await fetch("https://ifconfig.me", {
        headers: { "User-Agent": "curl/8.4.0" },
      })
    ).text();

  return CACHED_IP;
}

async function apiCall(command, params) {
  const MY_IP = await getMyIp();
  const API_KEY = process.env.API_KEY;

  const response = await (
    await fetch(
      `https://api.namecheap.com/xml.response?ApiUser=${USERNAME}&ApiKey=${API_KEY}&UserName=${USERNAME}&Command=${command}&ClientIp=${MY_IP}&${params}`
    )
  ).text();

  return response;
}

async function printDomains() {
  const response = await apiCall("namecheap.domains.getList");

  const matchAll = response.matchAll(/\s*<Domain ID="\d+" Name="([^"]+)"/g);
  const domains = [...matchAll].map((match) => match[1]);

  for (const domain of domains) {
    const [sld, tld] = domain.split(".");
    const response = await apiCall(
      "namecheap.domains.dns.getList",
      `SLD=${sld}&TLD=${tld}`
    );

    const nameservers = [
      ...response.matchAll(/<Nameserver>([^<]+)<\/Nameserver>/g),
    ].map((match) => match[1]);
    console.log(domain.padEnd(30), nameservers.join(", "));
  }
}

printDomains();
