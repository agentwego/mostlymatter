![](mostlymatter/logo_with_white_background-small.png) Mostlymatter is a fork of [Mattermost](https://mattermost.com) meant to remove the users and messages limits.

[Mattermost](https://mattermost.com) is an open source platform for secure collaboration across the entire software development lifecycle. Mattermost is written in Go and React and runs as a single Linux binary with MySQL or PostgreSQL.

Please go to <https://github.com/mattermost/mattermost/> for installation instructions.

## Differences between Mostlymatter and Mattermost

Our fork is limited to the backend (the binary), we don’t modify the front-end and we don’t provide compiled version of the other tools of Mattermost (like `mmctl`).

We multiplied the limits in `server/channels/app/limits.go` by 1,000.

The user limits should be 5,000,000 and 11,000,000.

We replaced the name `Mattermost` by `Mostlymatter` (and `mattermost` by `mostlymatter`) in the server strings (logging, help pages…) to avoid confusion between our the official build and our own but we kept the copyright comments.

The modifications are contained in the file [`limitless.patch`](limitless.patch).

To apply our modifications and compile Mostlymatter, please have a look at [MOSTLYMATTER_HOW_TO.md](MOSTLYMATTER_HOW_TO.md).

## Get Mostlymatter binaries

Go to <https://packages.framasoft.org/projects/mostlymatter/> to get the binaries you want.

Follow the instructions on top of the page to verify the binaries you downloaded.

## License

See the [LICENSE file](LICENSE.txt) for license rights and limitations.

## License of Mostlymatter’s logo

[CC-By-NC v4.0](https://creativecommons.org/licenses/by-nc/4.0/deed.en) [Geoffrey Dorne](https://geoffreydorne.com)
