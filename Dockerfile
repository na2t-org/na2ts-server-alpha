# Step 1: Building the Frontend.
FROM node:16.10.0 as frontend-build
#RUN npm install -g yarn
WORKDIR /app

# Installing deps before anything else, can cache this.
COPY frontend/package.json frontend/yarn.lock ./
RUN yarn install

COPY frontend ./
# Apply the build time hacks (Yes we need to do this after adding all the file.).
COPY docker/build.sh ./build.sh
RUN chmod +x ./build.sh && ./build.sh

RUN yarn build


# Step 2 : Final Container for Deployment
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-slim-2021-10-02
WORKDIR /app
COPY backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir --upgrade -r /app/requirements.txt

COPY docker/start.sh ./start.sh
RUN chmod +x ./start.sh

COPY docker/prestart.sh ./prestart.sh
RUN chmod +x ./prestart.sh

COPY docker/prod.sh ./prod.sh
RUN chmod +x ./prod.sh && ./prod.sh

COPY --from=frontend-build /app/build ./frontend/
COPY backend ./

CMD ["./start.sh"]