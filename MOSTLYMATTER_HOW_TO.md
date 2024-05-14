# How to use Framasoft’s patch to compile Mostlymatter

## Setup the repository

```bash
git clone https://framagit.org/framasoft/framateam/mostlymatter.git
cd mostlymatter
git remote add upstream https://github.com/mattermost/mattermost.git
```

## New version

Refresh you local repository.
```bash
git fetch -p --all
```

Set some env vars.
```bash
export NEW_VERSION=10.5.1
```

As you will need to cherry-pick some commits (the main fork commit and a fix-patch commit), you will need to go on an old release branch.
```bash
export OLD_VERSION=10.5.0
```

```bash
export BASE_VERSION=$(echo "$NEW_VERSION" | sed -e "s/\.[^.]\+$//")
git checkout "release-$OLD_VERSION"
git log --graph  --abbrev-commit --date=relative \
        --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr by %an)%Creset' \
        --max-count=3
```

Note the commits you’ll need (usually, the two first commits).

Go to the main branch of the version you want and reset the code to this version, then create a new branch with the version you want to compile from the main branch of this version.
```bash
git branch | grep -q "release-$BASE_VERSION\$" &&
    git checkout "release-$BASE_VERSION" ||
    git checkout -b "release-$BASE_VERSION" "upstream/release-$BASE_VERSION"

git reset --hard "v$NEW_VERSION"
git checkout -b "release-$NEW_VERSION" "release-$BASE_VERSION"
```

Cherry-pick the commits (use the oldest first!).

```bash
for i in 4b3d29da 056a5f8c
do
    git cherry-pick "$i"
done
```

If you compile a bugfix version (ex: `10.5.1`, using the commits of the `10.5.0` version), you should be just fine 
But if you compile a new version (ex: `10.6.0`), there is a lot of chances that you need to fix the `limitless.patch` file.

To test the patch:
```bash
git apply limitless.patch &&
    echo -e "\033[0;36mPatch applied successfully\033[0;36m" &&
    rm -rf server/cmd/mostlymatter &&
    git checkout -- server
```

If the patch does not apply, fix it. The fix is usually those steps:

- remove the `server/.golangci.yml` part of the patch
- manually apply this part (it’s mostly replacing `mattermost` by `mostlymatter` in this file)
- `git apply limitless.patch`
- `git add server`
- `git diff --cached > limitless.patch`
- `git restore --staged -- server`
- `git checkout -- server`
- `rm -rf server/cmd/mostlymatter`
- `git add limitless.patch`
- `git commit --amend`

Now, you can retest the patch:
```bash
git apply limitless.patch &&
    echo -e "\033[0;36mPatch applied successfully\033[0;36m" &&
    rm -rf server/cmd/mostlymatter &&
    git checkout -- server
```

Tag the new version (`limitless` is needed in the tag name for the CI to run) and push to Gitlab:
```bash
git tag "v$NEW_VERSION-limitless" -m "v$NEW_VERSION-limitless"
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
