FROM ubuntu:16.04
MAINTAINER Exl Moto

SHELL ["/bin/bash", "-c"]

ADD . /usr/share/1010
WORKDIR /usr/share/1010
RUN ls -al

RUN apt-get update -qq > /dev/null
RUN apt-get install -y software-properties-common python-software-properties > /dev/null
RUN add-apt-repository ppa:beineri/opt-qt593-xenial -y > /dev/null
RUN apt-get update -qq > /dev/null
RUN apt-get -y install qt59base qt59tools qt59translations > /dev/null
RUN apt-get install -y gcc > /dev/null
RUN apt-get install -y g++ > /dev/null
RUN apt-get install -y git > /dev/null
RUN apt-get install -y build-essential autoconf libtool > /dev/null
RUN apt-get install -y libssl-dev > /dev/null
RUN apt-get install -y libgmp-dev > /dev/null
RUN apt-get install -y libgl1-mesa-dev > /dev/null
RUN apt-get install -y libboost-dev > /dev/null
RUN apt-get install -y libboost-system-dev > /dev/null
RUN apt-get install -y libboost-filesystem-dev > /dev/null
RUN apt-get install -y libboost-program-options-dev > /dev/null
RUN apt-get install -y libboost-thread-dev > /dev/null
RUN apt-get install -y libqrencode-dev > /dev/null
RUN apt-get install -y libminiupnpc-dev > /dev/null
RUN apt-get install -y libdb++-dev > /dev/null
RUN apt-get install -y curl wget imagemagick > /dev/null

RUN chmod +x src/leveldb/build_detect_platform
RUN rm -Rf src/secp256k1/
RUN git clone https://github.com/bitcoin-core/secp256k1 --depth 1 -b master src/secp256k1/
RUN chmod +x src/secp256k1/autogen.sh
RUN source /opt/qt*/bin/qt*-env.sh && qmake CONFIG+=release Ferrumcoin.pro
RUN make -j$(nproc)
RUN mkdir app_image/
RUN cp ferrumcoin-qt app_image/
RUN cp share/pixmaps/icon-app.png app_image/default.png || convert -size 256x256 xc:gray app_image/default.png
RUN wget -c -nv "https://github.com/probonopd/linuxdeployqt/releases/download/continuous/linuxdeployqt-continuous-x86_64.AppImage"
RUN chmod a+x linuxdeployqt-continuous-x86_64.AppImage
RUN unset QTDIR; unset QT_PLUGIN_PATH ; unset LD_LIBRARY_PATH
RUN ./linuxdeployqt-continuous-x86_64.AppImage --appimage-extract
RUN source /opt/qt*/bin/qt*-env.sh && VERSION=$(git rev-parse --short HEAD) ./squashfs-root/AppRun app_image/ferrumcoin-qt -bundle-non-qt-libs
RUN source /opt/qt*/bin/qt*-env.sh && VERSION=$(git rev-parse --short HEAD) ./squashfs-root/AppRun app_image/ferrumcoin-qt -appimage

RUN curl -sS --upload-file ./Application*.AppImage https://transfer.sh/ferrumcoin-Qt.AppImage
