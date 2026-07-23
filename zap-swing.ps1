# This script runs the ZAP Webswing image, which provides a web-based interface to ZAP.
# https://www.zaproxy.org/blog/2021-02-03-run-zap-without-java-using-docker-and-webswing/

# Remember to use "http://host.docker.internal:3000" as the target URL when running scans, since the ZAP container needs to access the host's services running in Docker.

# Access via http://localhost:8082/zap in your browser.
docker run --rm -u zap -p 8082:8080 -p 8090:8090 zaproxy/zap-stable zap-webswing.sh