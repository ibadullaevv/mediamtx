#!/bin/bash
# MediaMTX Setup Script

# Rangli chiqish uchun
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}MediaMTX Server O'rnatish Skripti${NC}"
echo "--------------------------------"

# Fayllar mavjudligini tekshirish
if [ ! -f docker-compose.yml ]; then
  echo -e "${RED}Xato: docker-compose.yml fayli topilmadi${NC}"
  exit 1
fi

if [ ! -f mediamtx.yml ]; then
  echo -e "${RED}Xato: mediamtx.yml fayli topilmadi${NC}"
  exit 1
fi

# .env faylini tayyorlash
if [ ! -f .env ] && [ -f .env.example ]; then
  echo -e "${YELLOW}Environment faylini yaratish...${NC}"
  cp .env.example .env
  echo -e "${GREEN}✓ .env fayli yaratildi${NC}"
  echo -e "${YELLOW}Iltimos, .env faylini o'zingizga moslab tahrirlang${NC}"
fi

# HLS papkasini yaratish
echo -e "${YELLOW}HLS ma'lumotlar papkasini yaratish...${NC}"
mkdir -p hls_data
echo -e "${GREEN}✓ hls_data papkasi yaratildi${NC}"

# Script fayllarini bajariluvchi qilish
echo -e "${YELLOW}Script fayllarini bajariluvchi qilish...${NC}"
if [ -d scripts ]; then
  chmod +x scripts/*.sh
  echo -e "${GREEN}✓ Script fayllari bajariluvchi qilindi${NC}"
fi

# Docker Compose o'rnatilganini tekshirish
echo -e "${YELLOW}Docker Compose tekshirish...${NC}"
if docker compose version &> /dev/null; then
  echo -e "${GREEN}✓ Docker Compose o'rnatilgan${NC}"
else
  echo -e "${RED}✗ Docker Compose topilmadi${NC}"
  echo "Iltimos, Docker va Docker Compose o'rnating:"
  echo "Ubuntu: sudo apt install docker.io docker-compose-plugin"
  echo "CentOS: sudo yum install docker docker-compose-plugin"
  exit 1
fi

# Serverini ishga tushirish
echo -e "${YELLOW}MediaMTX serverini ishga tushirish...${NC}"
docker-compose up -d

# Natija tekshirish
if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ MediaMTX serveri muvaffaqiyatli ishga tushirildi${NC}"

  # Muhit faylini yuklash (agar mavjud bo'lsa)
  if [ -f .env ]; then
    source .env
  fi

  # Port sozlamalari
  RTSP_PORT=${RTSP_PORT:-8554}
  RTMP_PORT=${RTMP_PORT:-1935}
  HLS_PORT=${HLS_PORT:-8888}
  API_PORT=${API_PORT:-9997}

  echo -e "\n${YELLOW}Server manzillari:${NC}"
  echo -e "RTSP: ${GREEN}rtsp://localhost:${RTSP_PORT}${NC}"
  echo -e "RTMP: ${GREEN}rtmp://localhost:${RTMP_PORT}${NC}"
  echo -e "HLS:  ${GREEN}http://localhost:${HLS_PORT}${NC}"
  echo -e "API:  ${GREEN}http://localhost:${API_PORT}${NC}"

  echo -e "\n${YELLOW}Sinab ko'rish uchun:${NC}"
  echo -e "  scripts/test-stream.sh"

  echo -e "\n${YELLOW}Loglarni ko'rish:${NC}"
  echo -e "  docker logs -f ${CONTAINER_NAME:-mediamtx}"
else
  echo -e "${RED}✗ Serverini ishga tushirishda xatolik yuz berdi${NC}"
fi

echo -e "\n${GREEN}O'rnatish yakunlandi!${NC}"