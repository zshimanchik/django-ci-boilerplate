FROM nginx:1.11.6

RUN rm -rf /etc/nginx/nginx.conf
COPY nginx.prod.conf /etc/nginx/nginx.conf

RUN mkdir -p /app
COPY static /app/static

CMD ["nginx", "-g", "daemon off;"]
