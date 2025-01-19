FROM dart:stable AS build

WORKDIR /app

COPY pubspec.* /app/
RUN dart pub get

COPY . /app/

ARG SECRET_COFFEE
ARG SECRET_FESTIVITIES
RUN flutter build web --release \
    --dart-define=SECRET1=${SECRET_COFFEE} \
    --dart-define=SECRET2=${SECRET_FESTIVITIES}

FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]