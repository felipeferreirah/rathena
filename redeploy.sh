#!/usr/bin/env bash
set -e

echo "🧹 Limpando processos antigos..."
pkill -f login-server || true
pkill -f char-server || true
pkill -f map-server || true
pkill -f web-server || true
sleep 2
 
 

cd /root/endless/rathena

echo "🛑 Parando serviços existentes..."
./start-server.sh stop || true

echo "🧱 Atualizando binários..."
if [[ -f rathena-binaries.tar.gz ]]; then
  tar -xzvf rathena-binaries.tar.gz
  rm -f rathena-binaries.tar.gz
else
  echo "⚠️ Nenhum pacote encontrado (rathena-binaries.tar.gz)"
fi

echo "🚀 Reiniciando servidores rAthena..."
nohup ./start-server.sh start > redeploy.log 2>&1 < /dev/null & disown
sleep 5

echo "🔍 Últimas linhas do log:"
tail -n 15 redeploy.log || echo "Nenhum log gerado ainda."

echo "✅ Redeploy finalizado com sucesso!"
