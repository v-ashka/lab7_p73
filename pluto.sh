#!/bin/bash
plik="logi/info.log"
dataUtworzenia=`date +%F`
czasUtworzenia=`date +%T`
dostepnaPamiec=`cat /sys/fs/cgroup/memory/memory.limit_in_bytes`
pamiecUzyta=`cat /sys/fs/cgroup/memory/memory.usage_in_bytes` 
dostepnaPamiecMB=$(( $dostepnaPamiec / 1024 / 1024 ))
pamiecUzytaMB=$(( $pamiecUzyta / 1024 / 1024  ))

wolnaPamiec=$(( $dostepnaPamiecMB - $pamiecUzytaMB ))
if [ -d ./logi ] 
then
    echo "Plik $plik istnieje, dodaje do logow..."
else 
    mkdir logi && touch logi/info.log
    echo "Utworzono plik $plik, dodaje do logow..."
fi
echo "Utworzono: $dataUtworzenia $czasUtworzenia || Ustawiona pamiec: $dostepnaPamiecMB MB, Ilosc uzytej pamieci: $(( $pamiecUzyta / 1024 )) kB, Ilosc wolnej pamieci: $wolnaPamiec MB" >> $plik

