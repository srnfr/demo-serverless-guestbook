# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

## Adaptations by srnfr
## modernization + securization + add ENV for serverless redis

FROM php:8.1-apache-bullseye

RUN apt update && apt install -y unzip

RUN pear channel-discover pear.nrk.io
RUN pear install nrk/Predis

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer
COPY composer.* ./ 
RUN composer install

# If the container's stdio is connected to systemd-journald,
# /proc/self/fd/{1,2} are Unix sockets and apache will not be able to open()
# them. Use "cat" to write directly to the already opened fds without opening
# them again.
RUN sed -i 's#ErrorLog /proc/self/fd/2#ErrorLog "|$/bin/cat 1>\&2"#' /etc/apache2/apache2.conf
RUN sed -i 's#CustomLog /proc/self/fd/1 combined#CustomLog "|/bin/cat" combined#' /etc/apache2/apache2.conf

ADD guestbook.php /var/www/html/guestbook.php
ADD controllers.js /var/www/html/controllers.js
## We want the index.html version referencing the original JS not the modified for netlify
ADD index.html.org /var/www/html/index.html
ADD composer.json /var/www/html/composer.json

ENV GET_HOSTS_FROM="env"
ENV REDIS_LEADER_SERVICE_HOST=""
ENV REDIS_LEADER_SERVICE_PORT=""
ENV REDIS_PASSWORD=""

EXPOSE 80
