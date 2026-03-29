## How to Contribute

Pull requests are welcome in this repository.

## Local installation

The easiest way to use a local copy to test out changes is to use npm.

1. fork the repository and clone it on your machine
2. `cd` into it
3. `npm install -g .`
4. reload zsh: `zsh`

Any change you make to the prompt will be active after reloading zsh.

## Release process

1. Update `package.json` and `CHANGELOG.md`.
2. Commit the release changes and create a version tag such as `v1.5.3`.
3. Push the commit and tag to GitHub.
4. GitHub Actions will validate the tagged revision, create a GitHub release, and publish to npm when `NPM_TOKEN` is available.
