#!/bin/bash

#set -euo pipefail

#!/bin/bash

# Install Docker
dpkg --configure -a
apt update
apt install docker.io uuid -y
# Create `coder` user
useradd coder --shell /bin/bash -G docker
# Set `coder`'s password
PW=`uuid -v1`
echo "coder:$PW" | chpasswd
# ensure `coder`'s home exists
mkdir -p /home/coder/projects
echo $PW > /home/coder/pw.txt
echo "coder   ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
# install minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube
install ./minikube /usr/local/bin/minikube
mkdir -p /home/coder/.ssh
cp /root/.ssh/authorized_keys /home/coder/.ssh
chown coder:root -R /home/coder



cat << EOF > /root/.tmux.conf
set -g mouse on
bind -Tcopy-mode WheelUpPane send -N1 -X scroll-up
bind -Tcopy-mode WheelDownPane send -N1 -X scroll-down
set -g status on
# Shift arrow to switch windows
bind -n S-Left  previous-window
bind -n S-Right next-window
bind c new-window -c "#{pane_current_path}"
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
# Automatically set window title
set-window-option -g automatic-rename on
set-option -g set-titles on
# THEME

#Variables
color_status_text="colour245"
color_window_off_status_bg="colour238"
color_light="white" #colour015
color_dark="colour232" # black= colour232
color_window_off_status_current_bg="colour254"


set -g status-bg white
set -g status-fg black
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green](#S) #(whoami) '

bind-key -T copy-mode MouseDragEnd1Pane send -X copy-pipe-and-cancel "pbcopy"

bind -T root F12  \
  set prefix None \;\
  set key-table off \;\
  set status-style "fg=$color_status_text,bg=$color_window_off_status_bg" \;\
  set window-status-current-format "#[fg=$color_window_off_status_bg,bg=$color_window_off_status_current_bg]$separator_powerline_right#[default] #I:#W# #[fg=$color_window_off_status_current_bg,bg=$color_window_off_status_bg]$separator_powerline_right#[default]" \;\
  set window-status-current-style "fg=$color_dark,bold,bg=$color_window_off_status_current_bg" \;\
  if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
  refresh-client -S \;\

bind -T off F12 \
  set -u prefix \;\
  set -u key-table \;\
  set -u status-style \;\
  set -u window-status-current-style \;\
  set -u window-status-current-format \;\
  refresh-client -S

wg_is_keys_off="#[fg=$color_light,bg=$color_window_off_indicator]#([ $(tmux show-option -qv key-table) = 'off' ] && echo 'OFF')#[default]"

set -g status-right "$wg_is_keys_off  $wg_user_host"

EOF

# touch done file in /root
touch /root/cloudinit.done