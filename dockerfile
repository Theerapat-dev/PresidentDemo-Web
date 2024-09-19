# ขั้นตอนที่ 1: สร้างภาพสำหรับ Angular app
FROM node:16.20.2 as builder
WORKDIR /app
COPY package*.json ./
RUN npm install --legacy-peer-deps
COPY . .
RUN npm run build -- --output-hashing=none --verbose > build.log 2>&1 || (cat build.log && exit 1)

# ขั้นตอนที่ 2: สร้างภาพสำหรับ OWASP ZAP
FROM lefisius/dockerbuild
WORKDIR /zap
COPY . /zap
RUN chmod +x /zap/zap.sh
EXPOSE 8081
ENTRYPOINT ["/zap/zap.sh"]

# ขั้นตอนที่ 3: รวม Angular build กับ Nginx
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY --from=builder /app/build.log /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
