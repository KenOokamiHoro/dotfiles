#!/bin/sh
 export http_proxy=http://127.0.0.1:8118/
 export https_proxy=$http_proxy
 export ftp_proxy=$http_proxy
 export rsync_proxy=$http_proxy
 export no_proxy="localhost,localaddress,.localdomain.com"
