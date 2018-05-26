FROM centos:7.3.1611

MAINTAINER ryuichit <https://github.com/ryuichit>

# Define a application directory
ENV HOME /usr/src/app
RUN mkdir -p $HOME
WORKDIR $HOME

# Install os packages
# gcc-c++   for mecab setup
# patch     for ipadic-neologd dict install
# which     for ipadic-neologd dict install
# file      for ipadic-neologd dict install
# openssl   for ipadic-neologd dict install
RUN yum install -y wget gcc-c++ make git patch which file openssl

# Install mecab
WORKDIR $HOME
RUN wget -O mecab-0.996.tar.gz 'https://drive.google.com/uc?export=downloa$&id=0B4y35FiV1wh7cENtOXlicTFaRUE' && \
    tar xvzf mecab-0.996.tar.gz && \
    rm mecab-0.996.tar.gz
WORKDIR mecab-0.996
RUN ./configure
RUN make
RUN make install

# Install mecab ipadic dict
WORKDIR $HOME
RUN wget -O mecab-ipadic-2.7.0-20070801.tar.gz 'https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM' && \
    tar xvzf mecab-ipadic-2.7.0-20070801.tar.gz && \
    rm mecab-ipadic-2.7.0-20070801.tar.gz
WORKDIR mecab-ipadic-2.7.0-20070801
RUN ./configure --enable-utf8-only --with-charset=utf8 --with-mecab-config=/usr/local/bin/mecab-config
RUN make
RUN make install

# Install mecab ipadic-neologd dict
WORKDIR $HOME
RUN rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
RUN yum install -y mecab mecab-ipadic mecab-devel
RUN git clone --depth 1 https://github.com/neologd/mecab-ipadic-neologd.git
WORKDIR mecab-ipadic-neologd
RUN ./bin/install-mecab-ipadic-neologd -n -y
RUN sed -i -e 's@^dicdir.*$@dicdir = /usr/local/lib/mecab/dic/mecab-ipadic-neologd@' /usr/local/etc/mecabrc

# Entry
WORKDIR $HOME
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["echo 機械学習 | mecab"]
