FROM nginx:alpine

# Copy exported web build into the default nginx web root
COPY ./Web/ /usr/share/nginx/html/

# Custom nginx config for MIME + caching
COPY ./Docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80