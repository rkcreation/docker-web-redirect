#!/bin/bash
if [ -z "$REDIRECT_TARGET" ]; then
	echo "Redirect target variable not set (REDIRECT_TARGET)"
	exit 1
else
	# Add http if not set
	if ! [[ $REDIRECT_TARGET =~ ^https?:// ]]; then
		REDIRECT_TARGET="http://$REDIRECT_TARGET"
	fi

	# Add trailing slash
	if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
		REDIRECT_TARGET="$REDIRECT_TARGET/"
	fi

	echo "Redirecting HTTP requests to ${REDIRECT_TARGET}..."
fi

STATUS_CODE=${REDIRECT_STATUS:-301}
STATUS_CODE_NGINX=permanent
if [[ "$STATUS_CODE" == "302" ]]; then
	STATUS_CODE_NGINX=redirect
fi

echo "Redirecting HTTP requests with status code ${STATUS_CODE}..."
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen 80;
	location /nginx_status {
        stub_status;
    }
	location / {
		rewrite ^/(.*)\$ $REDIRECT_TARGET\$1 ${STATUS_CODE_NGINX};
	}
}
EOF

exec nginx -g "daemon off;"
