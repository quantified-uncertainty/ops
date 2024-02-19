#!/usr/bin/env node

import chalk from "chalk";
/**
 * To run this script, you'll need to:
 * 1. Whitelist your IP in https://ap.www.namecheap.com/settings/tools/apiaccess/
 * 2. Grab API key from https://ap.www.namecheap.com/settings/tools/apiaccess/ that page and send it in API_KEY env variable.
 */
import { program } from "commander";

const USERNAME = "quriops";

const PROVIDERS = {
  digitalocean: [
    "ns1.digitalocean.com",
    "ns2.digitalocean.com",
    "ns3.digitalocean.com",
  ],
  vercel: ["ns1.vercel-dns.com", "ns2.vercel-dns.com"],
};

function findProviderName(nameservers) {
  nameservers = nameservers.toSorted();
  for (const [key, value] of Object.entries(PROVIDERS)) {
    if (nameservers.join(",") === value.toSorted().join(",")) {
      return key;
    }
  }
}

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

  {
    let match = response.match(/<Error .*>(.*)<\/Error>/);
    if (match) {
      throw new Error(match[1]);
    }
  }

  return response;
}

async function printNameservers() {
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

    let providerName = findProviderName(nameservers) ?? "UNKNOWN";
    const color = providerName === "digitalocean" ? chalk.green : chalk.red;

    console.log(
      chalk.blue(domain.padEnd(30)),
      color(providerName.padEnd(15)),
      nameservers.join(", ")
    );
  }
}

async function updateNameservers(domain, nameservers) {
  const [sld, tld] = domain.split(".");
  const response = await apiCall(
    "namecheap.domains.dns.setCustom",
    `SLD=${sld}&TLD=${tld}&NameServers=${nameservers.join(",")}`
  );
}

program.command("print").action(printNameservers);

program
  .command("update")
  .argument("<domain>", "Domain to update")
  .argument("<provider>", "DNS provider")
  .action(async (domain, provider) => {
    const nameservers = PROVIDERS[provider];
    if (!nameservers) {
      throw new Error("Unknown provider provider");
    }
    console.log(domain, nameservers);
    await updateNameservers(domain, nameservers);
  });

program.parse();
