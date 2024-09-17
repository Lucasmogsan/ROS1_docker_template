# ROS distribution to use as default
ARG ROS_DISTRO=noetic

###############################################################################################
# Base Image (stable) #
# Contains ONLY core dependencies
###############################################################################################

# Base image from https://hub.docker.com/r/osrf/ros/tags    (desktop-full for full ROS with GUI etc.)
FROM osrf/ros:${ROS_DISTRO}-desktop-full as base    
ENV ROS_DISTRO=${ROS_DISTRO}
SHELL ["/bin/bash", "-c"]

# Install bare minimum system dependencies
RUN apt-get update && apt-get install -y \
  cmake \
  g++ \
  git \
  python3-catkin-tools \
  python3-pip \
  wget \
  vim \
  nano \
  iputils-ping \
  python3-vcstool \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Minimal Python dependencies (only core libraries)
RUN pip3 install --upgrade pip \
&& pip3 install \
  numpy \
  rospkg \
  catkin_pkg

# Workspace setup (underlay/base that is not to be modified)
RUN mkdir -p /underlay_ws/src
WORKDIR /underlay_ws/src
COPY dependencies.repos .
RUN vcs import < dependencies_underlay.repos \
&& rosdep update \
&& rosdep install -y --from-paths src --ignore-src

RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
&& catkin init \
&& catkin build --no-status --parallel $(nproc)

# Remove display warnings
RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
ENV NO_AT_BRIDGE 1

# Set up the work directory and entrypoint
WORKDIR /underlay_ws
COPY ./docker/entrypoint.sh /

# Alias python3 as python
RUN ln -s /usr/bin/python3 /usr/bin/python

ENTRYPOINT [ "/entrypoint.sh" ]

###############################################################################################
# Overlay Image (frequently changed) #
# Contains project-specific dependencies and source code
###############################################################################################
FROM base as overlay

# Install additional apt packages (project-specific)
RUN apt-get update && apt-get install -y \
  ros-${ROS_DISTRO}-cv-bridge \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install additional Python dependencies (project-specific)
RUN pip3 install scipy

RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
&& rosdep install --from-paths src --ignore-src -r -y

# Create the overlay workspace
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
&& mkdir -p /overlay_ws/src \
&& cd /overlay_ws \
&& catkin init

# Copy the source code (of submodules) into the overlay workspace
COPY ../packages/ /overlay_ws/src

# Build the overlay workspace
RUN source /opt/ros/${ROS_DISTRO}/setup.bash \
&& catkin build --no-status --parallel $(nproc)

# Run entrypoint
WORKDIR /overlay_ws
COPY ./docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]


################################################################################################
# Development Image #
# Tools used only in development are installed here
################################################################################################
FROM overlay as dev

# Install additional apt packages (project-specific)
RUN apt-get update && apt-get install -y \
  gdb \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install additional Python dependencies (project-specific)
RUN pip3 install scikit-learn

# Dev container arguments
ARG USERNAME=devuser
ARG UID=1000
ARG GID=${UID}

# Install extra tools for development
RUN apt-get update && apt-get install -y --no-install-recommends \
 gdb gdbserver nano

# Create new user and home directory
RUN groupadd --gid $GID $USERNAME \
 && useradd --uid ${GID} --gid ${UID} --create-home ${USERNAME} \
 && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME} \
 && mkdir -p /home/${USERNAME} \
 && chown -R ${UID}:${GID} /home/${USERNAME}

# Set the ownership of the overlay workspace to the new user
RUN chown -R ${UID}:${GID} /overlay_ws/ /underlay_ws/

# Set the user and source entrypoint in the user's .bashrc file
USER ${USERNAME}
RUN echo "source /entrypoint.sh" >> /home/${USERNAME}/.bashrc