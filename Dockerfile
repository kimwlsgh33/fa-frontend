# start with node:12.16.2 image
FROM node:12.16.2 as builder

# make directory
RUN mkdir /usr/src/app 
# set working directory
WORKDIR /usr/src/app 
# add `/usr/src/app/node_modules/.bin` to $PATH
ENV PATH /usr/src/app/node_modules/.bin:$PATH
# copy package.json
COPY package.json /usr/src/app/package.json
# install app dependencies ( at /usr/src/app )
RUN npm install --silent
#RUN npm install react-scripts@3.4.1 -g --silent

# copy app source code
COPY . /usr/src/app
# build app
RUN npm run build

# start with nginx:1.19 image
FROM nginx:1.19

# remove default nginx config
RUN rm -rf /etc/nginx/conf.d
# copy custom nginx config ( /conf/conf.d )
COPY conf /etc/nginx

# 위에서 생성한 앱의 빌드산출물을 
# nginx의 샘플 앱이 사용하던 폴더로 이동

# copy build result from builder
COPY --from=builder /usr/src/app/build /usr/share/nginx/html

# expose port 80
EXPOSE 80
# start nginx ( -g daemon off; , foreground )
CMD ["nginx", "-g", "daemon off;"]
