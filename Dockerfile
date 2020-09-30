FROM haskell:8.10.1-buster

ENV HOME=/home/theia
ENV STACK_ROOT=${HOME}/.stack
ENV GHC=8.10.2
ENV DEBIAN_KEY=427CB69AAC9D00F2A43CAF1CBA3CBA3FFE22B574
ENV CABAL_INSTALL=3.2
ENV STACK=2.3.3
ENV STACK_KEY=C5705533DA4F78D8664B5DC0575159689BEFB442
ENV STACK_RELEASE_KEY=2C6A674E85EE3FB896AFC9B965101FF31C5C154D

ENV PATH ${HOME}/.cabal/bin:${HOME}/.local/bin:/opt/cabal/${CABAL_INSTALL}/bin:/opt/ghc/${GHC}/bin:$PATH

RUN apt update && apt install -y wget && \
    mkdir /projects ${HOME} && \
    mkdir -p ${HOME}/.stack && \
    echo "allow-different-user: true" >> /home/theia/.stack/config.yaml && \
    echo "package-indices:" >> /home/theia/.stack/config.yaml && \
    echo "    - name: HackageOrig" >> /home/theia/.stack/config.yaml && \
    echo "      download-prefix: https://hackage.haskell.org/package/" >> /home/theia/.stack/config.yaml && \
    echo "      http: https://hackage.haskell.org/00-index.tar.gz" >> /home/theia/.stack/config.yaml && \
    echo "      hackage-security:" >> /home/theia/.stack/config.yaml && \
    echo "        keyids:" >> /home/theia/.stack/config.yaml && \
    echo "          - 0a5c7ea47cd1b15f01f5f51a33adda7e655bc0f0b0615baa8e271f4c3351e21d" >> /home/theia/.stack/config.yaml && \
    echo "          - 1ea9ba32c526d1cc91ab5e5bd364ec5e9e8cb67179a471872f6e26f0ae773d42" >> /home/theia/.stack/config.yaml && \
    echo "          - 280b10153a522681163658cb49f632cde3f38d768b736ddbc901d99a1a772833" >> /home/theia/.stack/config.yaml && \
    echo "          - 2a96b1889dc221c17296fcc2bb34b908ca9734376f0f361660200935916ef201" >> /home/theia/.stack/config.yaml && \
    echo "          - 2c6c3627bd6c982990239487f1abd02e08a02e6cf16edb105a8012d444d870c3" >> /home/theia/.stack/config.yaml && \
    echo "          - 51f0161b906011b52c6613376b1ae937670da69322113a246a09f807c62f6921" >> /home/theia/.stack/config.yaml && \
    echo "          - 772e9f4c7db33d251d5c6e357199c819e569d130857dc225549b40845ff0890d" >> /home/theia/.stack/config.yaml && \
    echo "          - aa315286e6ad281ad61182235533c41e806e5a787e0b6d1e7eef3f09d137d2e9" >> /home/theia/.stack/config.yaml && \
    echo "          - fe331502606802feac15e514d9b9ea83fee8b6ffef71335479a2e68d84adc6b0" >> /home/theia/.stack/config.yaml && \
    echo "        key-threshold: 3 # number of keys required" >> /home/theia/.stack/config.yaml && \
    echo "        ignore-expiry: true" >> /home/theia/.stack/config.yaml && \
    cabal update && \
    # Change permissions to let any arbitrary user
    for f in "${HOME}" "/etc/passwd" "/projects" "/opt" "/home/theia/.stack/config.yaml"; do \
      echo "Changing permissions on ${f}" && chgrp -R 0 ${f} && \
      chmod -R g+rwX ${f}; \
    done && \
    #cabal update --with-ghc ghc-tinfo6-8.6.4 && \
    #stack upgrade && \
    wget https://github.com/haskell/haskell-language-server/releases/download/0.4.0/haskell-language-server-Linux-8.10.2.gz && \
    wget https://github.com/haskell/haskell-language-server/releases/download/0.4.0/haskell-language-server-wrapper-Linux.gz && \
    gunzip haskell-language-server-Linux-8.10.2.gz -c > /usr/bin/haskell-language-server && chmod +x /usr/bin/haskell-language-server && \
    gunzip haskell-language-server-wrapper-Linux.gz -c > /usr/bin/haskell-language-server-wrapper && chmod +x /usr/bin/haskell-language-server-wrapper && \
    rm -f *.gz && \
    git clone https://github.com/haskell/ghcide.git && cd ghcide && cabal install && cd .. 
    
    
ADD etc/entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
CMD ${PLUGIN_REMOTE_ENDPOINT_EXECUTABLE}
