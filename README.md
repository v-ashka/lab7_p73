# Laboratorium 7 - P7.3

## 1. Opracować Dockerfile na podstawie obrazu bazowego alpine, który:
> a. zawierać będzie skrypt o nazwie pluto.sh , który generować będzie informacje o dacie utworzenia oraz ilości dostępnej pamięci a następnie zapisywać te dane do pliku tekstowego o nazwie info.log.
> 
> b. pozwoli na umieszczenie pliku info.log na wolumenie, który podłączony ma być do systemu plików kontenera, w katalogu /logi
> 
> c. zdefiniuje sposób uruchomienia skryptu pluto.sh przy starcie kontenera.

Utworzony dockerfile:
```dockerfile
FROM alpine:latest
RUN apk add --no-cache bash
ADD pluto.sh /
RUN chmod 777 /pluto.sh
ENTRYPOINT [ "bash", "pluto.sh" ]
```
Skrypt pluto.sh, wypisujący datę oraz informacje dotyczące wolnej pamięci:
```sh
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


```
## 2. Zbudować obraz i nazwać go lab4docker
Do zbudowania obrazu wykorzystujemy poniższe polecenie, znajdując się w katalogu z utworzonymi wcześniej plikami
```bash
docker build -t lab4docker .
```
![image](https://user-images.githubusercontent.com/47278535/168426266-63477a26-b98c-49d1-bcce-09d4be7b2294.png)

## 3. Utworzyć volumen o nazwie RemoteVol wykorzystujący odpowiedni sterownik (plugin), by miejsce przechowywania danych znajdowało się na systemie macierzystym:
>b. dla studentów, których macierzystym systemem jest Windows – katalog udostępniany poprzez CIFS/SMB.

Pierwszym krokiem jest stworzenie wolumenu z określonymi parametrami:
```
docker volume create 
  --driver local
  --opt type=cifs
  --opt device=//192.168.0.10/logi
  --opt o=addr=192.168.0.10,username=MARCIN,password=12345,file_mode=0777,dir_mode=0777 --name RemoteVol
```

Właściwość `--opt type=cifs` określa z jakiego typu udostępniania korzystamy, dla użytkownika Windowsa jest to CIFS/SMB,
dalej mamy `--opt device=//xx.xx.xx.xx/path` jest to adres do naszej macierzystej maszyny wraz ze ścieżką,
następna właściwość `--opt o=addr=xx.xx.xx.xx,username=user,password=xxx,file_mode=0777,dir_mode=0777` odpowiada za ustalenie adresu IP maszyny rzeczywistej, nazwy użytkownika 
wraz z hasłem (to polecenie wymaga podania hasła, pomimo że użytkownik na którego logujemy się może nie mieć hasła, stąd czasami mogą występować pewne komplikacje),
kolejne właściwości odnoszą się do samego dostępu do pliku jak i folderu.
Właściwość `--name RemoteVol` jak można się domyślić odpowiada za nazwanie utworzonego wolumenu

W tym miejscu można odrazu utworzyć na maszynie macierzytej folder który będzie odbierał dane z kontenera, dla zadania
utworzono na dysku C: folder o nazwie `logi` i udostępniono go dla użytkownika podanego przy tworzeniu wolumenu
![image](https://user-images.githubusercontent.com/47278535/168426525-3b2c1612-8fa3-45ec-a534-9bbd1da6a1d3.png)

## 4. Uruchomić kontener o nazwie alpine4 na bazie zbudowanego obrazu lab5docker w taki sposób, by:
>a. podłączyć do niego utworzony wolumen RemoteVol w miejsce katalogu /logi w systemie plików kontenera.
>
>b. korzystając z informacji w podpunkcie E, dla tego kontenera ograniczyć ilość wykorzystywanej pamięci RAM do 512MB.

Do uruchomienia konternera o nazwie alpine4, użyto następującego polecenia:
```
docker run --name alpine4 -m 512m --mount source=RemoteVol,target=/logi lab4docker
```
Właściwość `-m` określa ograniczenie pamięci kontenera, dla naszego zadania ustalona wartość to 512MB
![image](https://user-images.githubusercontent.com/47278535/168426644-c65ebb7f-b80e-489b-a8c3-529b0c01da5b.png)

Osiągniętym rezultatem powinno być utworzenie się pliku `info.log` w udostępnionym przez nas folderze, wraz zawartością która była tworzona w pliku `pluto.sh`
![image](https://user-images.githubusercontent.com/47278535/168426698-ddd3fd07-c9c6-414e-8117-67fb3831dd7f.png)

## 5. Za pomocą poznanych narzędzi docker plugin ….., docker inspect ..., docker stats … itd. należy potwierdzić, że:
>a. skrypt pluto.sh generuje wymagane dane i umieszcza je w pliku info.log na wolumenie, który znajduje się w systemie plików na maszynie macierzystej.
>
>b. kontener alpine4 ma ograniczoną ilość pamięci RAM zgodnie z treścią zadania

Informacje z `docker inspect`
![image](https://user-images.githubusercontent.com/47278535/168426754-489d5f6d-bee2-4952-99f9-20420750b8e2.png)

Informacje dot. montowania
![image](https://user-images.githubusercontent.com/47278535/168426827-da983bda-2575-47ef-8380-1bb223e15a3a.png)

Informacje dotyczące używania pluto.sh, wykorzystując ENTRYPOINT
![image](https://user-images.githubusercontent.com/47278535/168426866-9db284df-5dc6-4099-9899-1db1af842bce.png)

Informacje dot. ograniczenia pamięci 
![image](https://user-images.githubusercontent.com/47278535/168426740-efb1ce68-543e-49a6-a2e1-401fabb47f23.png)

Statystyki działania konterna
![image](https://user-images.githubusercontent.com/47278535/168426995-0b8d83ce-43d2-4baf-aa19-aba9f912c3a7.png)


## 6. Jeśli do wykonania punktu 5 użyty zostanie (poza narzędziami z konsoli) narzędzie CADVISOR, będzie to podstawą do przyznania dodatkowych punktów za sprawozdania.

Widok uruchomionego kontenera, z widoku CADVISOR
![image](https://user-images.githubusercontent.com/47278535/168427267-94406173-c88f-465e-a7b7-838507168ddc.png)

![image](https://user-images.githubusercontent.com/47278535/168427301-07733e10-9f78-47b4-8530-64a81915df8f.png)
Możemy zatem zauważyć że oprócz limitu pamięci ram, można ustawić limit pamięci SWAP, która domyślnie ustawiła się na 1GB.
Poniżej możemy zauważyć również wykresy zużycia procesora, sieci, czy pamięci w trakcie kiedy uruchamiany jest skrypt `pluto.sh`

![image](https://user-images.githubusercontent.com/47278535/168427393-0e211328-a864-48ea-acdb-246f39ed74ea.png)

![image](https://user-images.githubusercontent.com/47278535/168427399-937ef525-c0eb-493a-8b4d-bf3b4b586043.png)

![image](https://user-images.githubusercontent.com/47278535/168427410-ea1aecf2-1b5f-405c-b7a8-391815e74867.png)

Oprócz tego CADVISOR pozwala na zobaczenie aktualnego typu plików systemu, wraz z zajętością tego miejsca

![image](https://user-images.githubusercontent.com/47278535/168427449-5bf9eedf-4a85-49e8-a4e8-93a0e5832656.png)







