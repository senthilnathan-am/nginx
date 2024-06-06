FROM nginx:stable-alpine
COPY html/ /usr/share/nginx/html
COPY mysite.template /etc/nginx/conf.d/mysite.template
COPY nginx.conf /etc/nginx/nginx.conf
CMD ["/bin/sh" , "-c" , "envsubst '${DOMAIN_NAME}'< /etc/nginx/conf.d/mysite.template > /etc/nginx/conf.d/default.conf && exec nginx -g 'daemon off;'"]
