# Accesslint::Ci

Runs accesslint-cli in CircleCI and comments on GitHub pull requests with new
accessibility issues.

accesslint-ci will crawl a host site and run accessibility assertions on the
pages. If there are any new accessibility issues, accesslint-ci will comment on
the pull request that initiated the build in CircleCI.

[View an example](https://github.com/accesslint/bourbon.io/pull/1)

## Installation

### Command line (without CircleCI and GitHub)

1. `npm install -g accesslint-cli`
1. `gem install accesslint-ci`
1. `accesslint-ci scan --skip-ci <url>`

### Circle CI

1. Set up your CircleCI environment (API tokens for CircleCI and GitHub, artifacts)
1. Install dependencies (nodejs, `accesslint-cli`, `accesslint-ci`)
1. Start a development server
1. Run `accesslint-ci scan <development server e.g. http://localhost:3000>`

In your `circle.yml` file:

```
general:
  artifacts:
    - "tmp"

machine:
  environment:
    CIRCLE_TOKEN: <CircleCI API token>
    ACCESSLINT_GITHUB_TOKEN: <GitHub Personal Access Token>
  node:
    version: 6.1.0

dependencies:
  override:
    - npm install -g accesslint-cli
    - gem install accesslint-ci

test:
  post:
    - bundle exec rails server -d -p 3000
    - accesslint-ci scan http://localhost:3000
```

### TravisCI, Jenkins, etc.

AccessLint CI only works in CircleCI right now. See https://github.com/accesslint/accesslint-ci/issues/15

## License

AccessLint CI is Copyright © 2016 thoughtbot, inc. It is free software, and may be
redistributed under the terms specified by the [MIT License](http://opensource.org/licenses/MIT).

## About thoughtbot

![thoughtbot](https://thoughtbot.com/logo.png)

AccessLint is maintained and funded by thoughtbot.

We love open source software!
See [our other projects][community] or
[hire us][hire] to design, develop, and grow your product.

[community]: https://thoughtbot.com/tools?utm_source=github+accesslint
[hire]: https://thoughtbot.com/hire-us?utm_source=github+accesslint
