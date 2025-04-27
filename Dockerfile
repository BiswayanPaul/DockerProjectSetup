# start from a minimal Node.js Alpine image
FROM node:18-alpine AS build-env
WORKDIR /app

# install dependencies exactly as locked
COPY package.json package-lock.json ./
RUN npm ci

# copy the rest of the source code and build the app
COPY . .
RUN npm run build

# now create a fresh image for running only the production build
FROM node:18-alpine
WORKDIR /app

# pull in the build output and production modules
COPY --from=build-env /app/.next ./.next
COPY --from=build-env /app/public ./public
COPY --from=build-env /app/node_modules ./node_modules
COPY --from=build-env /app/package.json ./package.json

# set production mode and expose default Next.js port
ENV NODE_ENV=production
EXPOSE 3000

# launch Next.js server
CMD ["npm", "run", "start"]
