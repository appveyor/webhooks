AppVeyor webhooks
=================

> WARNING: This is pre-release software - "generic" Git and Mercurial repositories are not yet implemented in AppVeyor.

When you push new commits to your remote repository you want AppVeyor to instantly start a new build for these changes. Polling repositoris is bad. Fortunately, both Git and Mercurial support hooks - extensibility mechanism that allows calling custom scripts on various server-side events such as "code received". Hook script collects the information about commit(s) and send JSON request to AppVeyor to start a new build.

This repository contains Git and Mercurial server-side hooks for triggering AppVeyor builds. For maximum interoperability between Linux and Windows hooks are written in Ruby. There is only one external dependency - `json`.

## Installing Mercurial hook

Mercurial hook is called on `changegroup` event - this is run after a group of changesets has been brought into the repository from elsewhere. See [Mercurial hooks](http://hgbook.red-bean.com/read/handling-repository-events-with-hooks.html) for more details.

Hook can be installed system-wide for all repositories and per-repository. See [Mercurial configuration files](http://www.selenic.com/mercurial/hgrc.5.html) for more details.

To intall system-wide hook on Windows open (or create) `%USERPROFILE%\Mercurial.ini` and add the following:

```ini
[hooks]
changegroup.appveyor = ruby <path>\mercurial-changegroup.rb <webhook-url>
```

## Installing Git hook

Git hook is called on `post-receive` server-side event. See [Git hooks](http://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks) for more details. Server-side hooks are called on "bare" repositories only. Git hooks are located in `<repository_root>\hooks` directory.

To install Git hook copy `post-receive.rb` to `<repository_root>\hooks` directory as `post-receive` (remove `.rb` extension). On Linux set execute permissions on hook script file.

Git hook is configured through git configuration. To set webhook URL:

    git config appveyor.webhook <webhook-url>



## Fixing SSL in Ruby
- Download http://curl.haxx.se/ca/cacert.pem to `<download-folder>`
- `SET SSL_CERT_FILE=<download-folder>\cacert.pem`
