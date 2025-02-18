# Copyright 2019 The xridge kubestone contributors.
# Copyright 2021 Pratik raj .
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


# Builder image
FROM alpine:latest AS builder

RUN apk add --no-cache --update \
        autoconf \
        automake \
        build-base \
        git \
        libaio-dev \
        libtool \
        pkgconf

RUN git clone https://github.com/akopytov/sysbench.git --depth 1

WORKDIR /sysbench
RUN ./autogen.sh && \
    ./configure --without-mysql && \
    make -j && \
    make install


# Target image
FROM alpine:latest

RUN apk add --no-cache libaio libgcc
COPY --from=builder /usr/local/share/sysbench /usr/local/share/sysbench
COPY --from=builder /usr/local/bin/sysbench   /usr/local/bin/sysbench

ENTRYPOINT ["/usr/local/bin/sysbench"]
