#!/bin/bash

# Kafka SSL证书生成脚本（使用OpenSSL）
# 用于本地开发环境的自签名证书

CERT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STORE_PASSWORD="kafkassl"

echo "生成Kafka SSL证书..."
echo "证书目录: $CERT_DIR"
echo "密钥库密码: $STORE_PASSWORD"

# 清理旧证书
rm -f "$CERT_DIR"/kafka.server.keystore.jks
rm -f "$CERT_DIR"/kafka.server.truststore.jks
rm -f "$CERT_DIR"/ca-key.pem
rm -f "$CERT_DIR"/ca-cert.pem
rm -f "$CERT_DIR"/server-key.pem
rm -f "$CERT_DIR"/server-cert.pem
rm -f "$CERT_DIR"/.srl

# 1. 生成CA私钥和证书
openssl genrsa -out "$CERT_DIR"/ca-key.pem 2048
openssl req -new -x509 -key "$CERT_DIR"/ca-key.pem -days 365 \
  -out "$CERT_DIR"/ca-cert.pem \
  -subj "/CN=Kafka CA/OU=Dev/O=Local/L=City/ST=State/C=US"

# 2. 生成服务器私钥
openssl genrsa -out "$CERT_DIR"/server-key.pem 2048

# 3. 生成证书签名请求
openssl req -new -key "$CERT_DIR"/server-key.pem \
  -out "$CERT_DIR"/server-req.pem \
  -subj "/CN=localhost/OU=Dev/O=Local/L=City/ST=State/C=US" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

# 4. 使用CA签名服务器证书
openssl x509 -req -in "$CERT_DIR"/server-req.pem \
  -CA "$CERT_DIR"/ca-cert.pem \
  -CAkey "$CERT_DIR"/ca-key.pem \
  -CAcreateserial \
  -out "$CERT_DIR"/server-cert.pem \
  -days 365

# 5. 将证书和私钥转换为PKCS12格式
openssl pkcs12 -export \
  -in "$CERT_DIR"/server-cert.pem \
  -inkey "$CERT_DIR"/server-key.pem \
  -chain -CAfile "$CERT_DIR"/ca-cert.pem \
  -name kafka \
  -out "$CERT_DIR"/kafka.server.keystore.p12 \
  -passout pass:"$STORE_PASSWORD"

# 6. 将CA证书导入信任库
openssl pkcs12 -export \
  -nokeys \
  -in "$CERT_DIR"/ca-cert.pem \
  -out "$CERT_DIR"/kafka.server.truststore.p12 \
  -passout pass:"$STORE_PASSWORD"

# 7. 如果系统有Java，转换为JKS格式（可选）
if command -v keytool &> /dev/null; then
  echo "检测到Java，转换为JKS格式..."
  
  # 转换keystore
  keytool -importkeystore \
    -deststorepass "$STORE_PASSWORD" \
    -destkeypass "$STORE_PASSWORD" \
    -destkeystore "$CERT_DIR"/kafka.server.keystore.jks \
    -srckeystore "$CERT_DIR"/kafka.server.keystore.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass "$STORE_PASSWORD" \
    -alias kafka \
    -noprompt
  
  # 转换truststore
  keytool -importkeystore \
    -deststorepass "$STORE_PASSWORD" \
    -destkeypass "$STORE_PASSWORD" \
    -destkeystore "$CERT_DIR"/kafka.server.truststore.jks \
    -srckeystore "$CERT_DIR"/kafka.server.truststore.p12 \
    -srcstoretype PKCS12 \
    -srcstorepass "$STORE_PASSWORD" \
    -alias CARoot \
    -noprompt
else
  echo "未检测到Java，使用PKCS12格式"
fi

# 清理临时文件
rm -f "$CERT_DIR"/server-req.pem
rm -f "$CERT_DIR"/.srl

echo "证书生成完成！"
echo "PKCS12格式:"
echo "  密钥库: $CERT_DIR/kafka.server.keystore.p12"
echo "  信任库: $CERT_DIR/kafka.server.truststore.p12"
if [ -f "$CERT_DIR"/kafka.server.keystore.jks ]; then
  echo "JKS格式:"
  echo "  密钥库: $CERT_DIR/kafka.server.keystore.jks"
  echo "  信任库: $CERT_DIR/kafka.server.truststore.jks"
fi
