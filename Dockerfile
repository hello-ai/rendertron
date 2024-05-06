FROM node:18-bullseye-slim


# ref: https://github.com/puppeteer/puppeteer/blob/main/docker/Dockerfile
# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chrome that Puppeteer
# installs, work.
RUN apt-get update \
  && apt-get install -y wget gnupg \
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
  && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] https://dl-ssl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 dbus dbus-x11 \
  --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# https://stackoverflow.com/questions/75251315/dependency-issue-installing-google-chrome-stable-through-ubuntu-docker
RUN wget --no-check-certificate --no-verbose http://archive.ubuntu.com/ubuntu/pool/main/libu/libu2f-host/libu2f-udev_1.1.4-1_all.deb \
  && apt update \
  && apt install -y ./libu2f-udev_1.1.4-1_all.deb \
  && rm ./libu2f-udev_1.1.4-1_all.deb

# If running Docker >= 1.13.0 use docker run's --init arg to reap zombie processes, otherwise
# uncomment the following lines to have `dumb-init` as PID 1
# ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.0/dumb-init_1.2.0_amd64 /usr/local/bin/dumb-init
# RUN chmod +x /usr/local/bin/dumb-init
# ENTRYPOINT ["dumb-init", "--"]

# Uncomment to skip the chromium download when installing puppeteer. If you do,
# you'll need to launch puppeteer with:
#     browser.launch({executablePath: 'google-chrome-stable'})
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true


WORKDIR /rendertron
COPY package*.json /rendertron/
RUN npm install

ENV SENTRY_AUTH_TOKEN=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

COPY . /rendertron
RUN npm run build

ENV NODE_ENV production

CMD ["npm", "run", "start"]

