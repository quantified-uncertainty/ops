This small docker image is used for obtaining `GITHUB_TOKEN` in Argo Workflows CI jobs.

If you ever need to rebuild this image, look for `build-github-credentials-obtainer` Argo Workflow.

Link to the published package: https://github.com/quantified-uncertainty/ops/pkgs/container/github-credentials-obtainer

This image requires three env vars:

- `PRIVATE_KEY` for the GitHub app that will generate the token
- `APP_ID` of that app
- `INSTALLATION_ID` for app-org installation pair

It will create a `/tmp/github-token` file with a plain string containing the token (note that the token is short-lived, it will expire in 1 hour).
