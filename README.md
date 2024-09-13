# GetHash - Кроссплатформенное (linux/windows/...) вычисление хеш сумм различными алгоритмами.

При разработке использовался код библиотек https://github.com/Xor-el/HashLib4Pascal

Отправной точкой разработки явилось то что в gtkHash не были найдены современные GOST алгоритмы.

![изображение](https://github.com/user-attachments/assets/f018017c-49b2-4fad-bcc9-246be0b29795)

![изображение](https://github.com/user-attachments/assets/d5656892-40cd-4c73-ac9d-07099f37f43e)

![изображение](https://github.com/user-attachments/assets/e0004f30-19c3-4b06-97be-8cdbbfa95208)

RPM, RPMS для ОС Альт - http://altrepo.ru/

Windows - https://github.com/x09/gethash/releases/tag/v1.0

![изображение](https://github.com/user-attachments/assets/2cfb2a7e-b3f2-4b88-998f-21e99b89238d)

# Консольная версия
````
[anton@dell GetHash]$ gethash-cli
Usage: gethash-cli [PARAMETER(S)]… [FILE(S)]
Print checksums.

  -h, --help      this help
  -l, --list      list all algorithms
  -a  --algo      specify the algorithm used
  -f  --file      file or files for proccesing

Report any bugs to https://github.com/x09/gethash
````

````
[anton@dell GetHash]$ gethash-cli -l
Supported algoritms:
1) BLAKE2B_256
2) BLAKE2B_512
3) BLAKE2S_128
4) BLAKE2S_256
5) GOST
6) GOST3411_2012_256
7) GOST3411_2012_512
8) HAVAL_3_128
9) HAVAL_4_128
10) HAVAL_5_128
11) KECCAK_224
12) KECCAK_256
13) KECCAK_288
14) KECCAK_384
15) KECCAK_512
16) MD5
17) RIPEMD_128
18) RIPEMD_160
19) RIPEMD_256
20) RIPEMD_320
21) SHA1
22) SHA2_256
23) SHA2_512
24) SHA3_224
25) SHA3_256
26) SHA3_512
27) TIGER2_3_128
28) TIGER2_3_160
29) TIGER2_3_192
30) TIGER2_4_128
31) TIGER2_4_160
32) TIGER2_4_192
33) TIGER2_5_128
34) TIGER2_5_160
35) TIGER2_5_192
36) TIGER3_128
37) TIGER3_160
38) TIGER3_192
39) TIGER4_128
40) TIGER4_160
41) TIGER4_192
42) TIGER5_128
43) TIGER5_160
44) TIGER5_192
````

````
[anton@dell GetHash]$ gethash-cli -a GOST3411_2012_256 -f /tmp/*.png 
CD31027CE865F682C8EE3F072A046807829060BE1597B416A99D3A3D36B84979 /tmp/1_2024-09-09_14-29.png
0B1A582028B21C265BE74B97B80AE4E31EB53FAD467D012B437DF1529E16BE77 /tmp/2_2024-09-09_14-30.png
7FCD1FCBDA35E43E865B63DD995CA44F86D28AD5C232FC6C01E50422172A570D /tmp/lpd_2024-09-10_16-20.png
````
