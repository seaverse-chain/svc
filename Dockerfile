FROM ethereum/client-go:v1.11.5

COPY genesis.json.template /genesis.json.template

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 8545 8546 30303

ENTRYPOINT ["/entrypoint.sh"]
