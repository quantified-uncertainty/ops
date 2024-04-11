#!/usr/bin/env node

const { writeFileSync } = require("fs");
const { createAppAuth } = require("@octokit/auth-app");

const TOKEN_FILENAME = "/tmp/github-token";

const auth = createAppAuth({
  appId: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY,
});

auth({
  type: "installation",
  installationId: process.env.INSTALLATION_ID,
}).then(({ token }) => {
  writeFileSync(TOKEN_FILENAME, token);
});
