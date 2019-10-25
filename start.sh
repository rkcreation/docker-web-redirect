#!/bin/bash
if [ -z "$REDIRECT_TARGET" ]; then
	echo "Redirect target variable not set (REDIRECT_TARGET)"
	exit 1
else
	# Add https if not set
	if ! [[ $REDIRECT_TARGET =~ ^https?:// ]]; then
		REDIRECT_TARGET="https://$REDIRECT_TARGET"
	fi

	# Add trailing slash
	if [[ ${REDIRECT_TARGET:length-1:1} != "/" ]]; then
		REDIRECT_TARGET="$REDIRECT_TARGET/"
	fi

	echo "Redirecting HTTP requests to ${REDIRECT_TARGET}..."
fi

# Detect status code
STATUS_CODE=${REDIRECT_STATUS:-301}
STATUS_CODE_NGINX=permanent
IS_TRANSPARENT=0
if [[ "$STATUS_CODE" == "302" ]]; then
	STATUS_CODE_NGINX=redirect
elif [[ "$STATUS_CODE" == "transparent" ]]; then
	IS_TRANSPARENT=1
fi

# Enable status page
NGINX_STATUS_PAGE=""
if [[ "$ENABLE_STATUS_PAGE" == "1" ]]; then
	NGINX_STATUS_PAGE="location /nginx_status { stub_status; }"
fi

## Vhost config

# Transparent redirections (use proxy)
if [[ "${IS_TRANSPARENT}" == "1" ]]; then
	echo "Redirecting HTTP requests transparently..."
	cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen 80;
	${NGINX_STATUS_PAGE}
	location / {
		proxy_pass ${REDIRECT_TARGET};
		proxy_set_header Host \$host;
	}
}
EOF

# Visible redirections
else
	echo "Redirecting HTTP requests with status code ${STATUS_CODE}..."
	cat <<EOF > /etc/nginx/conf.d/default.conf
server {
	listen 80;
	${NGINX_STATUS_PAGE}
	location / {
		rewrite ^/(.*)\$ ${REDIRECT_TARGET}\$1 ${STATUS_CODE_NGINX};
	}
}
EOF
fi

exec nginx -g "daemon off;"
