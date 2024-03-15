#!/usr/bin/env node

const { writeFileSync } = require("fs");
const { createAppAuth } = require("@octokit/auth-app");

const TOKEN_FILENAME = "/tmp/github-token";
const DOCKER_CONFIG_FILENAME = "/tmp/docker-config.json";
const REGISTRY = "ghcr.io";

const auth = createAppAuth({
  appId: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY,
});

auth({
  type: "installation",
  installationId: process.env.INSTALLATION_ID,
}).then(({ token }) => {
  writeFileSync(TOKEN_FILENAME, token);
  writeFileSync(
    DOCKER_CONFIG_FILENAME,
    JSON.stringify({
      auths: {
        [REGISTRY]: {
          auth: Buffer.from(`unused:${token}`).toString("base64"),
        },
      },
    })
  );
});
