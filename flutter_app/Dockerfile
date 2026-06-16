# ============================================================
# flutter_app/Dockerfile  —  Build Flutter web, serve with nginx
# ------------------------------------------------------------
# Stage 1 builds the web bundle; stage 2 serves it on port 8070.
# Note: the Flutter build image is large and the first build is
# slow — that's normal for compiling Flutter web in Docker.
# ============================================================

# ---------- Stage 1: build ----------
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Cache dependencies first
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copy the rest and build
COPY . .
RUN flutter pub get
RUN flutter build web --release

# ---------- Stage 2: serve ----------
FROM nginx:alpine

# SPA-friendly config that listens on 8070
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the compiled web app
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8070
CMD ["nginx", "-g", "daemon off;"]
