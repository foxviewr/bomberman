# Stage 1: Build the app
FROM node:20-alpine as builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Stage 2: Run the app with Node
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/.output .output
COPY --from=builder /app/node_modules node_modules
COPY --from=builder /app/package.json .
EXPOSE 3000
CMD ["node", ".output/server/index.mjs"] 