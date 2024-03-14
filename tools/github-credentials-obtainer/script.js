const { writeFileSync } = "fs";
const { createAppAuth } = require("@octokit/auth-app");

const auth = createAppAuth({
  appId: process.env.APP_ID,
  privateKey: process.env.PRIVATE_KEY,
});

auth({
  type: "installation",
  installationId: process.env.INSTALLATION_ID,
}).then(({ token }) => {
  writeFileSync("github-token", token);
  writeFileSync(
    "docker-config.json",
    JSON.stringify({
      auths: {
        "ghcr.io": {
          auth: Buffer.from(`unused:${token}`).toString("base64"),
        },
      },
    })
  );
});
