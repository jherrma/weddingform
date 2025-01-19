FROM nginx:alpine

COPY build/web /usr/share/nginx/html
COPY assets/dotenv /usr/share/nginx/html/assets/dotenv

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]