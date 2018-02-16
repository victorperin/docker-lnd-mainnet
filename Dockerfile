FROM golang:1.8

MAINTAINER Victor Perin <me@victorperin.ninja>

# Expose lnd ports (server, rpc).
EXPOSE 9735 10009

# Force Go to use the cgo based DNS resolver. This is required to ensure DNS
# queries required to connect to linked containers succeed.
ENV GODEBUG netdns=cgo

# Install glide to manage vendor.
RUN go get -u github.com/Masterminds/glide

# Grab and install the latest version of lnd and all related dependencies.
RUN git clone https://github.com/lightningnetwork/lnd $GOPATH/src/github.com/lightningnetwork/lnd

# Make lnd folder default.
WORKDIR $GOPATH/src/github.com/lightningnetwork/lnd

# Instll dependency and install/build lnd.
RUN glide install

RUN sed -i 's/var activeNetParams = bitcoinTestNetParams/var activeNetParams = bitcoinMainNetParams/g' chainparams.go
RUN echo 'var bitcoinMainNetParams = bitcoinNetParams{ Params: &bitcoinCfg.MainNetParams, rpcPort: "8334", }' >> chainparams.go

RUN go install . ./cmd/...
