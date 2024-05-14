# How to use Framasoft’s patch to compile Mostlymatter

## New version

Create a new branch with the version you want to compile from the main branch of this version.

```bash
git checkout -b release-9.8.0 release-9.8
```

Reset the code to the version you want.

```bash
git reset --hard v9.8.0
```

Cherry-pick the commit containing the patch (see the commit on the branch master).

```bash
git cherry-pick 58bccbca34
```

NB: before the 9.8 version, the patch was different. See `release-9.7` branch.

Tag the new version (`limitless` is needed in the tag name for the CI to run)

```bash
git tag v9.8.0-limitless -m "v9.8.0-limitless"
```

Push to Gitlab

```bash
git push -u origin release-9.8.0
```

The CI will compile mostlymatter. Note that it will not be available as an artifact.

You can use the step of [.gitlab-ci.yml](.gitlab-ci.yml) to compile Mostlymatter without using the CI.

## Publish

The secrets are set with [Envkey](https://envkey.com/).

If you want to use a different envkey server than the one Framasoft uses, modify the [.envkey](.envkey) file.

You will need to set an `ENVKEY` CI variable in Gitlab.

In Envkey, you will need to set the following variables:

- `MINISIG_KEY`
- `MINISIG_PWD`
- `DEPLOYEMENT_KEY` (ssh private key encoded with base64)
- `DEPLOYEMENT_USER`
- `DEPLOYEMENT_HOST`

The CI will publish the compiled mostlymatter binary through sftp.
