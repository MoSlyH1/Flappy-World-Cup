FROM node:20-alpine

WORKDIR /app

# Copy backend package files
COPY backend/package*.json ./
RUN npm install --omit=dev

# Copy backend code
COPY backend/ ./

# Copy pre-built Flutter web files
COPY flutter_app/build/web ./public/web

EXPOSE 4000
CMD ["node", "server.js"]
