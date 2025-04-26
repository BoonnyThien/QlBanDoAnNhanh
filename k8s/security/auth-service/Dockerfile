FROM node:18
WORKDIR /app
COPY server.js .
COPY package.json .
RUN npm install express jsonwebtoken
CMD ["node", "server.js"]