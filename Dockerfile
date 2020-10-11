FROM haskell:8.8.4-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack
ENV GHC=8.8.4
ENV CABAL_INSTALL=3.2
ENV HLS=0.5.0
ENV HPACK=0.34.2

ARG user=theia
ARG group=theia
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group} && \
    useradd -u ${uid} -g ${group} -s /bin/sh -m ${user} 

ENV PATH ${HOME}/.ghcup/bin:/usr/bin:/bin:/local/bin:/usr/local/bin:${HOME}/.cabal/bin:${HOME}/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin

RUN apt update && apt install -y wget sudo libicu-dev libncurses-dev libgmp-dev zlib1g-dev vim bash && \
    #apt remove -y ghc-${GHC} && \
    rm -rf /root/.stack && mkdir -p /projects ${HOME}/.stack ${HOME}/.cabal && \
    #${HOME}/.ghcup/bin && \
    cd ${HOME} && \
    #curl https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/bin/ghcup && chmod +x /usr/bin/ghcup && \
    #ghcup install ghc ${GHC} && ghcup set ${GHC} && 
    wget https://github.com/haskell/haskell-language-server/releases/download/${HLS}/haskell-language-server-Linux-${GHC}.gz && \
    wget https://github.com/haskell/haskell-language-server/releases/download/${HLS}/haskell-language-server-wrapper-Linux.gz && \
    gunzip haskell-language-server-Linux-${GHC} -c > /usr/bin/haskell-language-server && chmod +x /usr/bin/haskell-language-server && \
    gunzip haskell-language-server-wrapper-Linux.gz -c > /usr/bin/haskell-language-server-wrapper && chmod +x /usr/bin/haskell-language-server-wrapper && \
    wget https://github.com/sol/hpack/releases/download/${HPACK}/hpack_linux.gz && gunzip hpack_linux.gz -c > /usr/bin/hpack && chmod +x /usr/bin/hpack && \
    rm -f *.gz && \
    chgrp -R ${gid} ${HOME} && \
    chmod -R g+rwX ${HOME} && \
    chown -R ${user}:${group} ${HOME} && \
    # Change permissions to let any arbitrary user
    for f in "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done 
USER theia  

RUN git clone https://github.com/haskell/ghcide.git && cd ghcide && stack install --system-ghc --stack-yaml stack8101.yaml && cd .. && \
    git clone https://github.com/phoityne/ghci-dap.git && git clone https://github.com/phoityne/haskell-dap.git && git clone https://github.com/hspec/hspec && \
    cd haskell-dap && stack build --system-ghc && stack install --system-ghc && cd .. && \
    cd ghci-dap && stack build --system-ghc && stack install --system-ghc && cd .. && \
    cd hspec && cabal install --lib && cabal install hspec-discover && cd .. && \
    rm -rf haskell-dap ghci-dap hspec ghcide && \
    #stack install haskell-dap ghci-dap haskell-debug-adapter && \
    # Change permissions to let any arbitrary user
    cabal update
    
USER root    

ADD etc/entrypoint.sh /entrypoint.sh
ADD etc/settings.yaml /home/theia/.stack/config.yaml
RUN chown -R 1724:root /home/theia /home/theia/.cabal /home/theia/.stack /opt 

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
