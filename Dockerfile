FROM nvidia/cuda:9.1-cudnn7-runtime

WORKDIR /

#Installing Python, Jupyter, Tensorflow, OpenAI Gym
###################################################
#1. installing python3
RUN apt-get update && \
	apt install -y --no-install-recommends python3-pip python3
#1.1 uppgrade pip3
RUN pip3 install --upgrade pip setuptools

#2. installing jupyter, and a bunch of Science Python Packages
RUN pip3 install jupyter pandas matplotlib scipy seaborn scikit-learn scikit-Image sympy cython patsy statsmodels cloudpickle dill numba bokeh

#3. Installing Tensorflow and Keras
RUN pip3 install tensorflow-gpu
RUN pip3 install keras

#4. installing OpenAI Gym (plus dependencies)
RUN pip3 install gym pyopengl
RUN apt-get install -y --no-install-recommends cmake ffmpeg pkg-config qtbase5-dev libqt5opengl5-dev libassimp-dev libpython3.5-dev libboost-python-dev libtinyxml-dev
WORKDIR /gym
ENV ROBOSCHOOL_PATH="/gym/roboschool"

#Installing bullet (the physics engine of roboschool) and its dependencies
RUN apt-get install -y --no-install-recommends git gcc g++ && \
	git clone https://github.com/openai/roboschool && \
	git clone https://github.com/olegklimov/bullet3 -b roboschool_self_collision && \
	mkdir bullet3/build && \
	cd    bullet3/build && \
	cmake -DBUILD_SHARED_LIBS=ON -DUSE_DOUBLE_PRECISION=1 -DCMAKE_INSTALL_PREFIX:PATH=$ROBOSCHOOL_PATH/roboschool/cpp-household/bullet_local_install -DBUILD_CPU_DEMOS=OFF -DBUILD_BULLET2_DEMOS=OFF -DBUILD_EXTRAS=OFF  -DBUILD_UNIT_TESTS=OFF -DBUILD_CLSOCKET=OFF -DBUILD_ENET=OFF -DBUILD_OPENGL3_DEMOS=OFF .. && \
	make -j4 && \
	make install

WORKDIR /gym/roboschool
RUN	pip3 install -e ./

WORKDIR /

RUN git clone --recursive https://github.com/openai/retro.git gym-retro && \
	cd gym-retro && \
	pip3 install -e .

#5. Installing X and xvfb so we can SEE the action using a remote desktop access (VNC)
# and because this is the last apt, let's clean up after ourselves
RUN apt-get install -y x11vnc xvfb fluxbox wmctrl && \
        apt-get clean

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888
# VNC Server
EXPOSE 5900

CMD jupyter notebook