FROM ubuntu:rolling

# environment variables
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:jonathonf/vim && \
    apt-get update 

RUN apt-get install -y python vim-nox-py2 git wget fontconfig tzdata locales

RUN cp /usr/share/zoneinfo/America/Los_Angeles /etc/localtime && \
    dpkg-reconfigure locales && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

WORKDIR /root 
ENV HOME /root

ENV LC_ALL en_US.UTF-8

RUN mkdir -p $HOME/.vim/pack/Dockerfile/start && cd  $HOME/.vim/pack/Dockerfile/start && git init && echo \
https://github.com/joonty/vdebug \
https://github.com/tpope/vim-fugitive \
https://github.com/scrooloose/nerdtree \
https://github.com/low-ghost/nerdtree-fugitive \
https://github.com/ctrlpvim/ctrlp.vim \
https://github.com/vim-airline/vim-airline \
https://github.com/vim-airline/vim-airline-themes \
https://github.com/scrooloose/syntastic \
|xargs -n1 git submodule add

ADD vimrc $HOME/.vimrc

ENV TERM=screen-256color

EXPOSE 9000

ENTRYPOINT ["vim"]
