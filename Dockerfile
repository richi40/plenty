# ---------------------
# hostos is centos7.3
# ---------------------

FROM nvidia/cuda:8.0-cudnn5-devel-centos7

# ------------
# adding user
# ------------
#RUN useradd -m plenty
#RUN echo "plenty ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/plenty
#USER plenty

# ---------------------------------
# install packages on centos
# ---------------------------------
RUN yum -y install epel-release && yum clean all
RUN yum -y update && yum clean all
RUN yum -y install wget sudo vim python-pip && yum clean all
RUN pip install --upgrade pip

# --------------
# install pyenv
# --------------
RUN yum -y install gcc zlib-devel bzip2 bzip2-devel readline readline-devel \
                   sqlite sqlite-devel openssl openssl-devel git && yum clean all
RUN git clone git://github.com/yyuu/pyenv.git .pyenv
ENV HOME /home/plenty
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# ------------------------
# install juman++ server
# ------------------------
RUN rpm -ivh http://packages.groonga.org/centos/groonga-release-1.1.0-1.noarch.rpm
RUN yum -y install mecab mecab-devel mecab-ipadic && yum clean all

RUN wget -O juman7.0.1.tar.bz2 "http://nlp.ist.i.kyoto-u.ac.jp/DLcounter/lime.cgi?down=http://nlp.ist.i.kyoto-u.ac.jp/nl-resource/juman/juman-7.01.tar.bz2&name=juman-7.01.tar.bz2"
RUN bzip2 -dc juman7.0.1.tar.bz2  | tar xvf -
RUN cd juman-7.01 && ./configure && make && make install

RUN yum -y install python-devel && yum clean all
RUN wget https://sourceforge.net/projects/boost/files/boost/1.62.0/boost_1_62_0.tar.gz
RUN tar xvzf boost_1_62_0.tar.gz
RUN cd boost_1_62_0 && sh bootstrap.sh && ./b2 install -j2

RUN yum -y install ruby 
RUN wget http://lotus.kuee.kyoto-u.ac.jp/nl-resource/jumanpp/jumanpp-1.01.tar.xz
RUN tar xJvf jumanpp-1.01.tar.xz
RUN cd jumanpp-1.01/ && ./configure && make && make install
RUN sed -i -e "s/\('command'=>'jumanpp',\)/\1 'host'=>'localhost',/g" ./jumanpp-1.01/script/server.rb
RUN echo 'ruby jumanpp-1.01/script/server.rb --cmd "jumanpp -B 5" &' >> .bashrc

ENV LIBRARY_PATH /usr/lib64:$LIBRARY_PATH 
RUN yum -y install make
RUN wget http://www.phontron.com/kytea/download/kytea-0.4.7.tar.gz
RUN tar -xvf kytea-0.4.7.tar.gz
RUN cd kytea-0.4.7 && ./configure && make && make install
RUN pip install kytea

# ------------------------
# install mongodb
# ------------------------
RUN echo -e "[mongodb-org-3.4]\nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/3.4/x86_64/\ngpgcheck=1\nenabled=1\ngpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc" > /etc/yum.repos.d/mongodb-org-3.4.repo
RUN yum -y install mongodb-org
RUN mkdir -p data/db
RUN echo '/usr/bin/mongod --dbpath /home/plenty/data/db &' >> .bashrc

# ----------------
# install python3
# ----------------
RUN yum -y install libX11-devel libXext-devel libXdmcp-devel
RUN pyenv install anaconda3-4.2.0
RUN pyenv global anaconda3-4.2.0
RUN pyenv rehash
RUN pip install --upgrade pip
RUN sed -i -e "s/Qt5Agg/Agg/g" .pyenv/versions/anaconda3-4.2.0/lib/python3.5/site-packages/matplotlib/mpl-data/matplotlibrc
RUN sed -i -e "s/Qt5Agg/Agg/g" .pyenv/versions/anaconda3-4.2.0/pkgs/matplotlib-1.5.3-np111py35_0/lib/python3.5/site-packages/matplotlib/mpl-data/matplotlibrc

# --------------------------------
# install modules on python
# --------------------------------
RUN yum -y install libxml2-devel libffi-devel python-devel libxslt-devel
RUN pip install scrapy
RUN pip install chainer
RUN pip install seaborn
RUN pip install -U scikit-learn
RUN pip install pystan
RUN pip install pymongo
RUN pip install nimfa

RUN wget https://github.com/mongodb/mongo-c-driver/releases/download/1.5.3/mongo-c-driver-1.5.3.tar.gz
RUN tar xzf mongo-c-driver-1.5.3.tar.gz
RUN cd mongo-c-driver-1.5.3 && ./configure && make && make install
RUN yum -y install cyrus-sasl-devel
ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH
RUN pip install monary

# -----------------
# setting japanese
# -----------------
RUN yum -y reinstall glibc-common && yum clean all
RUN localedef -v -c -i ja_JP -f UTF-8 ja_JP.UTF-8; echo "";
ENV LANG ja_JP.UTF-8
RUN rm -f /etc/localtime
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN pip install JapaneseTokenizer

# ------------------
# entry point
# ------------------
RUN echo 'export HOME=/share' >> .bashrc
RUN echo 'cd $HOME' >> .bashrc
ENTRYPOINT ["/bin/bash"]
