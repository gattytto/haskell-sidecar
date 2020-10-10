FROM haskell:8.10.2-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack
ENV GHC=8.10.2
ENV CABAL_INSTALL=3.2
ENV HLS=0.5.0
ENV HPACK=0.34.2

ENV PATH ${HOME}/.ghcup/bin:/usr/bin:/bin:/local/bin:/usr/local/bin:${HOME}/.cabal/bin:${HOME}/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin

RUN apt update && apt install -y wget sudo libicu-dev libncurses-dev libgmp-dev zlib1g-dev vim bash && apt remove -y ghc-${GHC} && \
    rm -rf /root/.stack && mkdir -p /projects ${HOME}/.stack ${HOME}/.cabal ${HOME}/.ghcup/bin && \
    curl https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/bin/ghcup && chmod +x /usr/bin/ghcup && \
    ghcup install ghc ${GHC} && cabal update && \
    wget https://github.com/haskell/haskell-language-server/releases/download/${HLS}/haskell-language-server-Linux-${GHC}.gz && \
    wget https://github.com/haskell/haskell-language-server/releases/download/${HLS}/haskell-language-server-wrapper-Linux.gz && \
    gunzip haskell-language-server-Linux-${GHC} -c > /usr/bin/haskell-language-server && chmod +x /usr/bin/haskell-language-server && \
    gunzip haskell-language-server-wrapper-Linux.gz -c > /usr/bin/haskell-language-server-wrapper && chmod +x /usr/bin/haskell-language-server-wrapper && \
    wget https://github.com/sol/hpack/releases/download/${HPACK}/hpack_linux.gz && gunzip hpack_linux.gz -c > /usr/bin/hpack && chmod +x /usr/bin/hpack && \
    rm -f *.gz && \
    git clone https://github.com/haskell/ghcide.git && cd ghcide && stack install --system-ghc --stack-yaml stack8101.yaml && cd .. && \
    rm -rf ghcide && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done 
    
    
ADD etc/entrypoint.sh /entrypoint.sh
ADD etc/settings.yaml /home/theia/.stack/config.yaml
RUN chown -R 1724:root /home/theia /home/theia/.cabal /home/theia/.stack /opt 

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
