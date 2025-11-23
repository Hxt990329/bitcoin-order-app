# =================================================================
# Stage 1: Build the Angular application
# 使用与 CI/CD 流程一致的 Node.js 版本，并选择轻量的 alpine 版本
# =================================================================
FROM node:16-alpine AS builder

# 设置工作目录
WORKDIR /app

# 优化缓存：先只复制 package.json 和 package-lock.json
COPY package*.json ./

# 安装依赖。使用 npm ci 以获得更快、更可靠的安装
RUN npm ci

# 复制所有剩余的项目文件
COPY . .

# 使用 package.json 中定义的脚本来构建应用
RUN npm run build -- --configuration production

# =================================================================
# Stage 2: Serve the application using Nginx
# 使用轻量的 alpine 版本的 Nginx
# =================================================================
FROM nginx:alpine

# 关键修正：从 'builder' 阶段复制构建好的静态文件到 Nginx 的网站根目录
# 路径 /app/dist/bitcoin 与你的 angular.json 文件中的 outputPath 完全匹配
COPY --from=builder /app/dist/bitcoin /usr/share/nginx/html

# 为了让 Angular 的路由在 Nginx 中正常工作（刷新页面不报 404）
# 我们需要一个自定义的 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 暴露 80 端口
EXPOSE 80
