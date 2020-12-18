# MD5 Dart
### Usage
The program is a primitive terminal. 
Everything that you enter is recognized as text for hashing,
except for a couple of cases.
To enter the command, you need to mask it with **\\** symbol.
Possible use cases:
```
\path path_to_file
\exit
```
In the first case, the file will be converted to _base64_ and 
its hash will be calculated. In the second case, the program 
will be terminated.
### Assembly
If you need an **exe** file, then make it using the following 
command (if you have Dart installed):
```
dart2native bin\main.dart -o path_to_save_file
```