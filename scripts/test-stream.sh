#!/bin/bash
# MediaMTX test script - kameralarni tekshirish uchun

# Rangli chiqish uchun
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}MediaMTX Server Test Script${NC}"
echo "-------------------------"

# Muhit faylini yuklash (agar mavjud bo'lsa)
if [ -f .env ]; then
  source .env
fi

# Serverning API porti
API_PORT=${API_PORT:-9997}
SERVER_HOST=${SERVER_HOST:-localhost}

# API holatini tekshirish
echo -e "${YELLOW}API holatini tekshirish...${NC}"
if curl -s "http://${SERVER_HOST}:${API_PORT}/v2/server/stats" > /dev/null; then
  echo -e "${GREEN}✓ API ishlayapti${NC}"
else
  echo -e "${RED}✗ API ishlamayapti${NC}"
  echo "Server ishga tushganligini va API porti to'g'ri ekanligini tekshiring"
  exit 1
fi

# Aktiv streamlarni ko'rish
echo -e "\n${YELLOW}Aktiv streamlarni tekshirish...${NC}"
STREAMS=$(curl -s "http://${SERVER_HOST}:${API_PORT}/v2/paths/list")
echo "$STREAMS"

# Stream holatlarini tekshirish
STREAM_COUNT=$(echo "$STREAMS" | grep -c '"source":')
echo -e "\n${YELLOW}Jami streamlar: ${NC}$STREAM_COUNT"

if [ $STREAM_COUNT -eq 0 ]; then
  echo -e "${YELLOW}Hozirda aktiv streamlar yo'q.${NC}"
  echo "Stream yuborish uchun quyidagi kommandani sinab ko'ring:"
  echo "ffmpeg -re -i video.mp4 -c copy -f rtsp rtsp://${SERVER_HOST}:${RTSP_PORT:-8554}/live/test"
else
  echo -e "${GREEN}✓ Streamlar mavjud${NC}"
fi

# HLS endpointlarini tekshirish
echo -e "\n${YELLOW}HLS endpointlarni tekshirish...${NC}"
HLS_PORT=${HLS_PORT:-8888}

for path in $(echo "$STREAMS" | grep -o '"path": "[^"]*' | cut -d'"' -f4); do
  echo -e "HLS URL: ${GREEN}http://${SERVER_HOST}:${HLS_PORT}/${path}/index.m3u8${NC}"
done

echo -e "\n${YELLOW}Monitoring URL:${NC}"
echo -e "API: ${GREEN}http://${SERVER_HOST}:${API_PORT}/v2/paths/list${NC}"
echo -e "Metrics: ${GREEN}http://${SERVER_HOST}:${API_PORT}/metrics${NC}"

echo -e "\n${GREEN}Test yakunlandi!${NC}"