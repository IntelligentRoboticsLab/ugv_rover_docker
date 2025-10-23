# Recreate from: nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Labels observed on the image
LABEL com.nvidia.cudnn.version="8.9.6.50" \
      maintainer="NVIDIA CORPORATION <cudatools@nvidia.com>" \
      org.opencontainers.image.ref.name="ubuntu" \
      org.opencontainers.image.version="22.04"

# Environment captured from the container (some of these are
# already set by the base image; we set them explicitly to pin versions)
ENV NV_LIBNPP_DEV_VERSION="11.8.0.86-1" \
    NV_LIBNPP_DEV_PACKAGE="libnpp-dev-11-8=11.8.0.86-1" \
    NV_LIBCUBLAS_DEV_PACKAGE_NAME="libcublas-dev-11-8" \
    NV_LIBCUBLAS_DEV_VERSION="11.11.3.6-1" \
    NV_LIBCUBLAS_DEV_PACKAGE="libcublas-dev-11-8=11.11.3.6-1" \
    NV_CUDA_NSIGHT_COMPUTE_VERSION="11.8.0-1" \
    NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE="cuda-nsight-compute-11-8=11.8.0-1" \
    NV_LIBNCCL_DEV_PACKAGE_NAME="libnccl-dev" \
    NV_LIBNCCL_DEV_PACKAGE_VERSION="2.15.5-1" \
    NV_LIBNCCL_DEV_PACKAGE="libnccl-dev=2.15.5-1+cuda11.8" \
    LIBRARY_PATH="/usr/local/cuda/lib64/stubs" \
    NV_CUDNN_VERSION="8.9.6.50" \
    NV_CUDNN_PACKAGE_NAME="libcudnn8" \
    NV_CUDNN_PACKAGE="libcudnn8=8.9.6.50-1+cuda11.8" \
    NV_CUDNN_PACKAGE_DEV="libcudnn8-dev=8.9.6.50-1+cuda11.8"

# ------------------------------------------------------------
# 1. Install required OS packages and ROS 2 dependencies
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    openssh-server \
    xauth \
    x11-apps \
    locales \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------
# 1b. Setup for ssh and x11
# ------------------------------------------------------------

RUN mkdir -p /var/run/sshd
RUN ssh-keygen -A

RUN sed -i 's/#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?X11Forwarding .*/X11Forwarding yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?X11UseLocalhost .*/X11UseLocalhost yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?X11DisplayOffset .*/X11DisplayOffset 10/' /etc/ssh/sshd_config

# Set the root password at build time (override via --build-arg)
ARG ROOT_PASSWORD=uvarobolab
RUN echo "root:${ROOT_PASSWORD}" | chpasswd

EXPOSE 23

# ------------------------------------------------------------
# 2. Setup locale
# ------------------------------------------------------------
RUN locale-gen en_US en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Amsterdam

ENV UGV_MODEL=ugv_rover
ENV LDLIDAR_MODEL=ld19

RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime \
 && apt-get update \
 && apt-get install -y --no-install-recommends tzdata \
 && dpkg-reconfigure -f noninteractive tzdata \
 && apt-get install -y --no-install-recommends \
      locales curl gnupg2 lsb-release software-properties-common \
 && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# 3. Add the ROS 2 apt repository and key
# ------------------------------------------------------------
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \

    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# ------------------------------------------------------------
# 4. Install ROS 2 Humble Desktop
# ------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    python3-argcomplete \
    && rm -rf /var/lib/apt/lists/*

# Optional: tools for building ROS 2 workspaces
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    python3-pip \
    python3-rosdep \
    python3-vcstool \
    python3-colcon-common-extensions \
 && rm -rf /var/lib/apt/lists/*


# ------------------------------------------------------------
# 5. Auto-source ROS setup for all bash sessions
# ------------------------------------------------------------
# WORKDIR /home/ws/ugv_ws/src/ugv_else/apriltag_ros/apriltag/
# RUN echo "cmake -S . -B build -DCMAKE_BUILD_TYPE=Release" >> /etc/bash.bashrc
# RUN echo "cmake --build build --target install" >> /etc/bash.bashrc


# ------------------------------------------------------------
# 6. Set working directory
# ------------------------------------------------------------
# Ensure the working directory exists
RUN mkdir -p /home/ws
WORKDIR /home/ws

COPY requirements.txt /tmp/requirements.txt
RUN env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy python3 -m pip install --no-cache-dir -i https://pypi.org/simple -r /tmp/requirements.txt

RUN colcon build --packages-select apriltag apriltag_msgs apriltag_ros cartographer costmap_converter_msgs costmap_converter emcl2 explore_lite openslam_gmapping slam_gmapping ldlidar rf2o_laser_odometry robot_pose_publisher teb_msgs teb_local_planner vizanti vizanti_cpp vizanti_demos vizanti_msgs vizanti_server ugv_base_node ugv_interface

RUN colcon build --packages-select ugv_bringup ugv_chat_ai ugv_description ugv_gazebo ugv_nav ugv_slam ugv_tools ugv_vision ugv_web_app --symlink-install

RUN echo "source /opt/ros/humble/setup.bash" >> /etc/bash.bashrc
RUN echo "source /home/ws/ugv_ws/install/setup.bash" >> /etc/bash.bashrc

# --- Replace your bashrc line entirely ---
# RUN echo "source /home/ws/ugv_ws/install_additional_ros_humble_packages.sh" >> /etc/bash.bashrc
# ^^^ delete this

# --- If you want to keep using that file, COPY it and RUN it once (without sudo) ---
# But better: inline and consolidate below for clarity and caching.

# 1) Base OS prep (locale, universe, curl, etc.)
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      locales software-properties-common curl ca-certificates gnupg2 lsb-release; \
    locale-gen en_US en_US.UTF-8; \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8; \
    add-apt-repository -y universe; \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# 2) Add ROS 2 apt source (prefer *pinned* repo key instead of hitting GitHub API at build)
RUN set -eux; \
  curl -fsSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  | gpg --batch --yes --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg; \
  chmod a+r /usr/share/keyrings/ros-archive-keyring.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/ros2.list

# 3) Install ROS Humble + your extra stacks
RUN set -eux; \
    apt-get update; \
    # remove conflicting OpenCV first (as your script does)
    apt-get remove -y libopencv-dev || true; \
    apt-get install -y --no-install-recommends \
      ros-humble-desktop \
      ros-dev-tools \
      python3-colcon-clean \
      ros-humble-nav2-msgs ros-humble-map-msgs ros-humble-nav2-costmap-2d \
      ros-humble-rosbridge-suite ros-humble-nav2-bringup \
      ros-humble-usb-cam 'ros-humble-depthai-*' \
      'ros-humble-joint-state-publisher-*' \
      ros-humble-robot-localization ros-humble-imu-tools \
      ros-humble-cartographer-ros \
      ros-humble-apriltag ros-humble-apriltag-msgs ros-humble-apriltag-ros \
      ros-humble-ros-gz; \
    apt-get autoremove -y; \
    rm -rf /var/lib/apt/lists/*

# 4) Runtime conveniences: source only in interactive shells
RUN printf '\n# ROS env (interactive shells only)\ncase "$-" in *i*) . /opt/ros/humble/setup.bash 2>/dev/null || true; ;; esac\n' \
    >> /etc/bash.bashrc

