# How to use Framasoft’s patch to compile Mostlymatter

## New version

```bash
export NEW_VERSION=9.10.0
```

```bash
export BASE_VERSION=$(echo "$NEW_VERSION" | sed -e "s/\.[^.]\+$//")
```

Create a new branch with the version you want to compile from the main branch of this version.

```bash
git checkout -b "release-$NEW_VERSION" "release-$BASE_VERSION"
```

Reset the code to the version you want.

```bash
git reset --hard "v$NEW_VERSION"
```

Cherry-pick the commit containing the patch (see the commit on the branch master).

```bash
git cherry-pick 58bccbca34
```

NB: before the 9.8 version, the patch was different. See `release-9.7` branch.

Tag the new version (`limitless` is needed in the tag name for the CI to run)

```bash
git tag "v$NEW_VERSION-limitless" -m "v$NEW_VERSION-limitless"
```

Push to Gitlab

```bash
git push -u origin "release-$NEW_VERSION"
```

The CI will compile mostlymatter. Note that it will not be available as an artifact.

You can use the step of [.gitlab-ci.yml](.gitlab-ci.yml) to compile Mostlymatter without using the CI.

## Publish

The secrets are set in GitLab CI variables :

- `MINISIG_KEY`
- `MINISIG_PWD`
- `DEPLOYEMENT_KEY` (ssh private key encoded with base64)
- `DEPLOYEMENT_USER`
- `DEPLOYEMENT_HOST`

The CI will publish the compiled mostlymatter binary through sftp.
