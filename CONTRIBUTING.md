# Contributing to Lidless

Thank you for helping improve Lidless. This guide covers how to report problems, propose changes and get a pull request merged.

By participating, you agree to follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## Reporting bugs

Open an issue using the **Bug report** template and include:

- your Lidless version, macOS version and Mac model (Apple silicon or Intel)
- the steps that reproduce the problem
- the output of `pmset -g`

For security issues, follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Suggesting features

Lidless is intentionally a single-purpose utility. Feature requests that keep it small and focused are the most likely to be accepted. Open an issue using the **Feature request** template before starting work on anything substantial.

## Development

Requirements: macOS 13 or later and the Xcode Command Line Tools.

```sh
git clone https://github.com/iamsaad640/lidless.git
cd lidless
make sudoers   # once per machine
make           # builds build/Lidless.app
open build/Lidless.app
```

Quit any installed copy of Lidless first, otherwise two icons appear in the menu bar.

## Code guidelines

- Keep the app in a single source file with no third-party dependencies.
- The code must build without warnings in the Swift 6 language mode.
- Keep macOS 13 as the minimum supported version unless there is a strong reason to raise it.
- Match the existing style: four-space indentation, and comments only where the code cannot explain itself.
- Never widen the sudo rule beyond the two `pmset disablesleep` commands.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/) on a single line:

```text
type(scope): short summary
```

Common types are `feat`, `fix`, `docs`, `refactor`, `build` and `ci`. For example: `fix(menu): keep login item checkmark in sync`.

## Pull requests

1. Fork the repository and create a branch from `main`.
2. Keep each pull request focused on one change.
3. Make sure `make` succeeds. CI builds every pull request.
4. Add an entry under **Unreleased** in [CHANGELOG.md](CHANGELOG.md) for user-facing changes.
5. Describe what you tested, including your macOS version and Mac type.

## Releasing

Maintainers publish releases as follows:

1. Update `CFBundleShortVersionString` and `CFBundleVersion` in `Info.plist`.
2. Move the **Unreleased** entries in `CHANGELOG.md` under the new version.
3. Commit, then tag: `git tag -a vX.Y.Z -m "Lidless X.Y.Z"` and push the tag.
4. Run `make dist` and attach `build/Lidless-X.Y.Z.zip` to a GitHub release for the tag.
