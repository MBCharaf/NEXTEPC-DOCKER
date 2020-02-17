FROM test_image_nextepc:1.0 as builder

FROM node:10

# Create app directory
RUN mkdir /webui
# Copy from baseimage
COPY --from=builder /nextepc/webui /webui

WORKDIR /webui

RUN npm install

RUN npm audit fix --force


EXPOSE 3000

CMD [ "npm", "run" ,"dev"]
