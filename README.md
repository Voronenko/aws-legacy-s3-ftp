
## Typical ftp session
```sh

ftp localhost 2121
..user ftpuploader
...password ftpuploader

ftp> passive
Passive mode on.

ftp> binary
200 Type set to binary

ftp> put userguide.pdf
local: userguide.pdf remote: userguide.pdf
227 Entering Passive Mode (172,19,0,5,195,162)
150 Using transfer connection
226 Closing transfer connection
186902 bytes sent in 0.01 secs (29.2059 MB/s)

ftp> ls
227 Entering Passive Mode (172,19,0,5,195,109)
150 Using transfer connection
-rw-r--r-- 1 ftp ftp       186902 Sep 18 20:48 userguide.pdf
226 Closing transfer connection

```

## Validating files on file backend

```sh

ls $PWD/data/srv-sftp-go/data/ftpuploader/
2021-09-18 22:48:26     186902 userguide.pdf

```


## Validating files on s3 backend
```sh

aws s3 ls s3://aws-legacy-s3-ftp
2021-09-18 22:48:26     186902 userguide.pdf

```

## Demo credentials

### Admin web panel

http://localhost:8090/web/admin/login/

demo user provisioned:

admin/admin

### Client web panel

http://localhost:8090/web/client/login/

demo user provisioned:

ftpuploader/ftpuploader

