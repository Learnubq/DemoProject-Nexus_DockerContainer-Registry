FROM node:20-alpine

ENV MONGO_DB_USERNAME=admin \
    MONGO_DB_PWD=password

RUN mkdir -p /home/app

WORKDIR /home/app

COPY package.json package-lock.json ./

RUN npm install

COPY . /home/app

# Set ownership and permissions

RUN chown -R node:node /home/app

# Switch to node user

USER node

CMD ["node", "server.js"]
