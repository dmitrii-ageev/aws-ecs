# Here is an example: https://cristian.livadaru.net/switching-mailservers-with-nginx-mail-proxy/
FROM nginx

RUN apt update
RUN apt install -y openssl curl
RUN mkdir -p /etc/pki/tls/certs
RUN mkdir -p /etc/pki/tls/private
RUN openssl req -newkey rsa:4096 -nodes -keyout /etc/pki/tls/private/example.com.key -x509 -days 365 \
                -out /etc/pki/tls/certs/example.com.crt \
                -subj "/C=US/ST=NRW/L=Earth/O=CompanyName/OU=IT/CN=www.example.com/emailAddress=email@example.com"

COPY config/nginx.conf /etc/nginx/nginx.conf

# Expose ports
EXPOSE 25 110 143
