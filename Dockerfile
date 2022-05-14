FROM alpine:latest
RUN apk add --no-cache bash
ADD pluto.sh /
RUN chmod 777 /pluto.sh
ENTRYPOINT [ "bash", "pluto.sh" ]

#docker volume create --driver local --opt type=cifs --opt device=//192.168.0.10/logi --opt o=addr=192.168.0.10,username=MARCIN,file_mode=0777,dir_mode=0777 --name RemoteVol
#docker run --name alpine4 -m 512m -it --mount source=RemoteVol,target=/logi lab4docker


