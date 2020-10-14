FROM haskell:8.10.1-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack
ENV GHC=8.10.1
ENV CABAL_INSTALL=3.2
ENV HLS=0.5.0
ENV HPACK=0.34.2

ARG user=theia
ARG group=theia
ARG uid=1000
ARG gid=1000

ENV PATH ${HOME}/.ghcup/bin:/usr/bin:/usr/sbin:/bin:/local/bin:/usr/local/bin:${HOME}/.cabal/bin:${HOME}/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin

RUN groupadd -g ${gid} ${group} && \
    useradd -u ${uid} -g ${group} -s /bin/sh -m ${user} && \
    apt update && apt install -y wget sudo libicu-dev libncurses-dev libgmp-dev zlib1g-dev vim bash && \
    rm -rf /root/.stack && mkdir -p /projects ${HOME}/.stack/global-project ${HOME}/.cabal && \
    cd ${HOME} && \
    wget https://github.com/haskell/haskell-language-server/releases/download/${HLS}/haskell-language-server-Linux-${GHC}.gz && \
    wget https://github.com/haskell/haskell-language-server/releases/download/${HLS}/haskell-language-server-wrapper-Linux.gz && \
    gunzip haskell-language-server-Linux-${GHC} -c > /usr/bin/haskell-language-server && chmod +x /usr/bin/haskell-language-server && \
    gunzip haskell-language-server-wrapper-Linux.gz -c > /usr/bin/haskell-language-server-wrapper && chmod +x /usr/bin/haskell-language-server-wrapper && \
    wget https://github.com/sol/hpack/releases/download/${HPACK}/hpack_linux.gz && gunzip hpack_linux.gz -c > /usr/bin/hpack && chmod +x /usr/bin/hpack && \
    rm -f *.gz && \
    echo "packages: []" > ${HOME}/.stack/global-project/stack.yaml && \
    echo "resolver: ghc-${GHC}" >> ${HOME}/.stack/global-project/stack.yaml && \
    chgrp -R ${gid} ${HOME} && \
    chmod -R g+rwX ${HOME} && \
    chown -R ${user}:${group} ${HOME} 
    
USER theia  

RUN cd ${HOME} && \
    cabal update && \
    git clone https://github.com/haskell/ghcide.git && cd ghcide && stack install --system-ghc --stack-yaml stack8101.yaml && cd .. && \
    git clone https://github.com/phoityne/ghci-dap.git && git clone https://github.com/phoityne/haskell-dap.git && git clone https://github.com/hspec/hspec && \
    cd haskell-dap && stack build --system-ghc && stack install --system-ghc && cd .. && \
    cd ghci-dap && stack build --system-ghc && stack install --system-ghc && cd .. && \
    cd hspec && cabal install --lib && cabal install hspec-discover && cd .. && \
    rm -rf haskell-dap ghci-dap hspec ghcide 
    
USER root    

ADD etc/entrypoint.sh /entrypoint.sh
ADD etc/settings.yaml /home/theia/.stack/config.yaml
RUN for f in "/etc/passwd" "/projects" "/opt" "/home/theia"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done 

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
