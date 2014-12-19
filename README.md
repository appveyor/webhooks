webhooks
========

Git and Mercurial server-side webhooks for triggering AppVeyor builds

## Installing Mercurial hook

Mercurial hook is called on `changegroup` event - this is run after a group of changesets has been brought into the repository from elsewhere. See [this article](http://hgbook.red-bean.com/read/handling-repository-events-with-hooks.html) for more details about Mercurial hooks.

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
