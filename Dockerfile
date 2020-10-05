FROM haskell:8.10.2-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack
ENV GHC=8.10.2
ENV DEBIAN_KEY=427CB69AAC9D00F2A43CAF1CBA3CBA3FFE22B574
ENV CABAL_INSTALL=3.2
ENV STACK=2.3.3
ENV STACK_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442
ENV STACK_RELEASE_KEY=2C6A674E85EE3FB896AFC9B965101FF31C5C154D

ENV PATH /usr/bin:/bin:/local/bin:/usr/local/bin:${HOME}/.cabal/bin:${HOME}/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin

RUN apt update && apt install -y wget sudo libicu-dev libncurses-dev libgmp-dev zlib1g-dev vim bash && \
    mkdir /projects ${HOME} && \
    mv /root/.stack /home/theia/.stack && \
    mkdir -p ${HOME}/.cabal && \
    curl https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/bin/ghcup && \
    chmod +x /usr/bin/ghcup 
    
RUN cabal update && \
    #cabal update --with-ghc ghc-tinfo6-8.6.4 && \
    #stack upgrade && \
    wget https://github.com/haskell/haskell-language-server/releases/download/0.4.0/haskell-language-server-Linux-8.10.2.gz && \
    wget https://github.com/haskell/haskell-language-server/releases/download/0.4.0/haskell-language-server-wrapper-Linux.gz && \
    gunzip haskell-language-server-Linux-8.10.2.gz -c > /usr/bin/haskell-language-server && chmod +x /usr/bin/haskell-language-server && \
    gunzip haskell-language-server-Linux-8.10.2.gz -c > /usr/bin/haskell-language-server-Linux-8.10.2 && chmod +x /usr/bin/haskell-language-server-Linux-8.10.2 && \
    gunzip haskell-language-server-wrapper-Linux.gz -c > /usr/bin/haskell-language-server-wrapper && chmod +x /usr/bin/haskell-language-server-wrapper && \
    wget https://github.com/sol/hpack/releases/download/0.34.2/hpack_linux.gz && gunzip hpack_linux.gz -c > /usr/bin/hpack && chmod +x /usr/bin/hpack && \
    rm -f *.gz && \
    git clone https://github.com/haskell/ghcide.git && cd ghcide && stack install && cd .. && \
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
