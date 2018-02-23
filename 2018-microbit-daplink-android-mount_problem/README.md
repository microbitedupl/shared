This repository holds information related to Microbit flashing via DAPLink UMS using Android OS as repoted in [1].
DAPLink seems to be detected as corrupted drive by Android and OS offers to format the drive..

# Resources

* [usb_dumps/](usb_dumps/) contains USB dumps after Microbit attach to Android device,  corruption report, format offer and start. Dumps were made with Beagle480 USB Analyzer.
* [disk_images/](disk_images/) contains Mass Storage Disk Image Dumps made with DD utility.

# Analysis

Some initial analysis of filesystem bytes are provided below. Seems valid FAT16 bare disk with no MBR. Comparison of FAT32 required fields is also presented to show filesystem cannot be misinterpreted as FAT32..

```
00000000: EB 3C 90 4D 53 44 30 53  34 2E 31 00 02 08 01 00  .<.MSD0S4.1.....

          ^^ ^^ ^^                                          BC_jmpBoot: BOOT JUMP
                   ^^ ^^ ^^ ^^ ^^  ^^ ^^ ^^                 BS_OEMName: MSDOS4.1
                                            ^^ ^^           BPB_BytsPerSec: BYTES PER SECTOR: 0x0200 (512)
                                                  ^^        BPB_SecPerClus: SECTORS PER CLUSTER: 8
                                                     ^^ ^^  BPB_RsvdSecCnt: RESERVED SECTORS COUNT: 1 

00000010: 02 20 00 00 00 F8 41 00  01 00 01 00 00 00 00 00  . ....A.........

          ^^                                                BPB_NumFATs: FAT DATA STRUCTURES COUNT: 2
             ^^ ^^                                          BPB_RootEntCnt: ROOT ENTRIES COUNT: 0x0002 (2).
                                                             NOTE: FAt16 SHOULD USE VALUE 512!
                   ^^ ^^                                    BPB_TotSec16 = 0. Total sector count on the volume.
                                                             If 0 then BPB_TotSec32 must be non zero!
                                                             For FAT32 this must be 0. For FAT16 this value contains sector count and BPB_TotSect32=0 if total sector count fits in 0x10000.
                         ^^                                 BPB_Media = 0xF8 (fixed non-removable).
                                                             NOTE: 0xF0 is used for removable.
                            ^^ ^^                           BPB_FATSz16 = 0x0041 (61). Sectors count occupied by one FAT.
                                                             NOTE: On FAT32 volume BPB_FATSz32 must be zero.
                                   ^^ ^^                    BPB_SecPerTrk = 0x0001. Sectors per track geometry.
                                         ^^ ^^              BPB_NumHeads = 0x0001.
                                               ^^ ^^ ^^ ^^  BPB_HiddSec = 0. Count of hidden sectors preceeding partition with FAT volume.

00000020: 80 00 02 00 00 00 29 74  19 02 27 44 41 50 4C 49  ......)t..'DAPLI
         
          ^^ ^^ ^^ ^^ ------------------------------------  BPB_TotSec32 = 0x00020080 (131200).

---------------------------------------------------------   WARNING: FAT12/FAT16 and FAT32 STARTS TO DIFFER HERE!

 --- FAT12/FAT16 ---

00000020: 80 00 02 00 00 00 29 74  19 02 27 44 41 50 4C 49  ......)t..'DAPLI

                      ^^ ---------------------------------  BS_DrvNum = 0 (floppy disk). 0x80 is a hard disk.
                         ^^ ------------------------------  BS_Reserved1 = 0.
                            ^^ ---------------------------  BS_BootSig = 0x29 (41). Signature stating that three fields in boot sector are present.
                               ^^  ^^ ^^ ^^ - - - - - - -   BS_VolID = 0x27021974. Volume serial number.
                                            ^^ ^^ ^^ ^^ ^^  BS_VolLab[0:4] = "DAPLI".

00000030: 4E 4B 2D 44 4E 44 46 41  54 31 36 20 20 20 00 00  NK-DNDFAT16   ..

          ^^ ^^ ^^ ^^ ^^ ^^ ..............................  BS_VolLab[5:7] = "NK-DND".
                            ^^ ^^  ^^ ^^ ^^ ^^ ^^ ^^ .....  BS_FilSysType = "FAT16   ". 
 --- FAT32 ---

00000020: 80 00 02 00 00 00 29 74  19 02 27 44 41 50 4C 49  ......)t..'DAPLI

                      ^^ ^^ ^^ ^^.........................  BPB_FATSz32 = 0x74290000 (1948844032). INVALID!
                                   ^^ ^^..................  BPB_ExtFlags = 0x0219 (537 / 1000011001).
                                                             bits[0:3] = 1001. active FAT (mirroring must be disabled).
                                                             bits[4:6] = 001. reserved.
                                                             bits[7] = 0 (FAT is mirrored into all FATs). 1 would mean only one FAT active specified in bits[0:3].
                                                             bits[8:15] = 10. reserved. INVALID!
                                         ^^ ^^............  BPB_FSVer = 0x4427 (17447). Major:Minor fs version.
                                                             NOTE: Should be 0:0 otherwise OS may not mount volume.
                                               ^^ ^^ ^^ ^^  BPB_RootClus = 0x494C5041. Usually = 2.Number of the first cluster of the root directory. INVALID!

00000030: 4E 4B 2D 44 4E 44 46 41  54 31 36 20 20 20 00 00  NK-DNDFAT16   ..

          ^^ ^^...........................................  BPB_FSInfo = 0x4B4E (19278). FS Info sector number.
                ^^ ^^.....................................  BPB_BkBootSec = 0x442D. Bootsector copy in the reserved area sector number.
                      ^^ ^^ ^^ ^^  ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^  BPB_Reserved. 

00000040: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................

          ^^..............................................  BS_DrvNum = 00. On FAT32 should be 0.
             ^^...........................................  BS_Reserved1 = 0. INVALID!
                ^^........................................  BS_BootSig = 0. INVALID!
                   ^^ ^^ ^^ ^^............................  BS_VolID = 0. INVALID!
                               ^^  ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^  BS_VolLab[0:8] = 0. INVALID!

00000050: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................

          ^^ ^^...........................................  BS_VolLab[9:10] = 0. INVALID!
                ^^ ^^ ^^ ^^ ^^ ^^  ^^ ^^..................  BS_FilSysType = 0. Should be always "FAT32   ". INVALID!

----------------------------------------------------------  END OF FAT16/FAT32 COMPARISON

000000E0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000000F0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
...


000083E0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000083F0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00008400: F8 FF FF FF FF FF FF FF  00 00 00 00 00 00 00 00  ................


00008410: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00008420: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................


000105F0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00010600: 4D 49 43 52 4F 42 49 54  20 20 20 28 00 00 00 00  MICROBIT   (....
00010610: 00 00 00 00 00 00 41 8E  BB 32 00 00 00 00 00 00  ......A..2......
00010620: 4D 49 43 52 4F 42 49 54  48 54 4D 01 00 00 00 00  MICROBITHTM.....
00010630: 76 48 76 48 00 00 DC 83  76 48 02 00 24 01 00 00  vHvH....vH..$...
00010640: 44 45 54 41 49 4C 53 20  54 58 54 01 00 00 00 00  DETAILS TXT.....
00010650: 76 48 76 48 00 00 DC 83  76 48 03 00 B5 01 00 00  vHvH....vH......
00010660: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00010670: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................


000109E0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000109F0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00010A00: 3C 21 64 6F 63 74 79 70  65 20 68 74 6D 6C 3E 0D  <!doctype html>.
00010A10: 0A 3C 21 2D 2D 20 6D 62  65 64 20 50 6C 61 74 66  .<!-- mbed Platf
00010A20: 6F 72 6D 20 57 65 62 73  69 74 65 20 61 6E 64 20  orm Website and 
00010A30: 41 75 74 68 65 6E 74 69  63 61 74 69 6F 6E 20 53  Authentication S
00010A40: 68 6F 72 74 63 75 74 20  2D 2D 3E 0D 0A 3C 68 74  hortcut -->..<ht
00010A50: 6D 6C 3E 0D 0A 3C 68 65  61 64 3E 0D 0A 3C 6D 65  ml>..<head>..<me
00010A60: 74 61 20 63 68 61 72 73  65 74 3D 22 75 74 66 2D  ta charset="utf-
00010A70: 38 22 3E 0D 0A 3C 74 69  74 6C 65 3E 6D 62 65 64  8">..<title>mbed
00010A80: 20 57 65 62 73 69 74 65  20 53 68 6F 72 74 63 75   Website Shortcu
00010A90: 74 3C 2F 74 69 74 6C 65  3E 0D 0A 3C 2F 68 65 61  t</title>..</hea
00010AA0: 64 3E 0D 0A 3C 62 6F 64  79 3E 0D 0A 3C 73 63 72  d>..<body>..<scr
00010AB0: 69 70 74 3E 0D 0A 77 69  6E 64 6F 77 2E 6C 6F 63  ipt>..window.loc
00010AC0: 61 74 69 6F 6E 2E 72 65  70 6C 61 63 65 28 22 68  ation.replace("h
00010AD0: 74 74 70 73 3A 2F 2F 77  77 77 2E 6D 69 63 72 6F  ttps://www.micro
00010AE0: 62 69 74 2E 63 6F 2E 75  6B 2F 64 65 76 69 63 65  bit.co.uk/device
00010AF0: 3F 6D 62 65 64 63 6F 64  65 3D 39 39 30 30 30 32  ?mbedcode=990002
00010B00: 34 33 22 29 3B 0D 0A 3C  2F 73 63 72 69 70 74 3E  43");..</script>
00010B10: 0D 0A 3C 2F 62 6F 64 79  3E 0D 0A 3C 2F 68 74 6D  ..</body>..</htm
00010B20: 6C 3E 0D 0A 00 00 00 00  00 00 00 00 00 00 00 00  l>..............
00010B30: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................


000119E0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000119F0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00011A00: 23 20 44 41 50 4C 69 6E  6B 20 46 69 72 6D 77 61  # DAPLink Firmwa
00011A10: 72 65 20 2D 20 73 65 65  20 68 74 74 70 73 3A 2F  re - see https:/
00011A20: 2F 6D 62 65 64 2E 63 6F  6D 2F 64 61 70 6C 69 6E  /mbed.com/daplin
00011A30: 6B 0D 0A 55 6E 69 71 75  65 20 49 44 3A 20 39 39  k..Unique ID: 99
00011A40: 30 30 30 30 30 30 33 31  33 32 34 65 34 35 30 30  00000031324e4500
00011A50: 35 39 39 30 31 39 30 30  30 30 30 30 36 32 30 30  5990190000006200
00011A60: 30 30 30 30 30 30 39 37  39 36 39 39 30 31 0D 0A  00000097969901..
00011A70: 48 49 43 20 49 44 3A 20  39 37 39 36 39 39 30 31  HIC ID: 97969901
00011A80: 0D 0A 41 75 74 6F 20 52  65 73 65 74 3A 20 30 0D  ..Auto Reset: 0.
00011A90: 0A 41 75 74 6F 6D 61 74  69 6F 6E 20 61 6C 6C 6F  .Automation allo
00011AA0: 77 65 64 3A 20 31 0D 0A  4F 76 65 72 66 6C 6F 77  wed: 1..Overflow
00011AB0: 20 64 65 74 65 63 74 69  6F 6E 3A 20 30 0D 0A 44   detection: 0..D
00011AC0: 61 70 6C 69 6E 6B 20 4D  6F 64 65 3A 20 49 6E 74  aplink Mode: Int
00011AD0: 65 72 66 61 63 65 0D 0A  49 6E 74 65 72 66 61 63  erface..Interfac
00011AE0: 65 20 56 65 72 73 69 6F  6E 3A 20 30 32 34 33 0D  e Version: 0243.
00011AF0: 0A 42 6F 6F 74 6C 6F 61  64 65 72 20 56 65 72 73  .Bootloader Vers
00011B00: 69 6F 6E 3A 20 30 32 34  33 0D 0A 47 69 74 20 53  ion: 0243..Git S
00011B10: 48 41 3A 20 36 34 30 65  31 64 37 66 63 38 66 61  HA: 640e1d7fc8fa
00011B20: 64 33 66 33 38 65 63 65  34 64 30 36 30 34 39 64  d3f38ece4d06049d
00011B30: 32 38 33 30 64 61 62 39  62 30 62 33 0D 0A 4C 6F  2830dab9b0b3..Lo
00011B40: 63 61 6C 20 4D 6F 64 73  3A 20 31 0D 0A 55 53 42  cal Mods: 1..USB
00011B50: 20 49 6E 74 65 72 66 61  63 65 73 3A 20 4D 53 44   Interfaces: MSD
00011B60: 2C 20 43 44 43 2C 20 48  49 44 0D 0A 42 6F 6F 74  , CDC, HID..Boot
00011B70: 6C 6F 61 64 65 72 20 43  52 43 3A 20 30 78 30 39  loader CRC: 0x09
00011B80: 39 62 36 38 37 62 0D 0A  49 6E 74 65 72 66 61 63  9b687b..Interfac
00011B90: 65 20 43 52 43 3A 20 30  78 61 61 39 39 65 33 32  e CRC: 0xaa99e32
00011BA0: 66 0D 0A 52 65 6D 6F 75  6E 74 20 63 6F 75 6E 74  f..Remount count
00011BB0: 3A 20 30 0D 0A 00 00 00  00 00 00 00 00 00 00 00  : 0.............
00011BC0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00011BD0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
```

[1] https://github.com/ARMmbed/DAPLink/issues/269
