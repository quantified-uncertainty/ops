This small docker image is used for obtaining `GITHUB_TOKEN` and `.docker/config.json` in Argo Workflows CI jobs.

I've built and uploaded it to QURI GitHub Container Registry by hand; it shouldn't change too often, so it shouldn't be a problem.

Link to the published package: https://github.com/quantified-uncertainty/ops/pkgs/container/github-credentials-obtainer

This image requires three env vars:

- `PRIVATE_KEY` for the GitHub app that will generate the token
- `APP_ID` of that app
- `INSTALLATION_ID` for app-org installation pair

It will create two files:

- `/tmp/github-token` with a plain string containing the token (note that the token is short-lived, it will expire in 1 hour)
- `/tmp/.docker/config.json` with docker config based on that token, useful for mounting it in kaniko
