# shared-mime-info-file
A replacement for file(1) based on shared-mime-info

This project aims to be, as far as feasible, a POSIX conformant implementation of [file(1)](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/file.html). A secondary objective is to be a, once again as far as feasible, drop-in replacement for the file command used on virtually any Linux or BSD box out there, that is Ian Darwin’s one. That entails offering a version of libmagic. A last objective is to perform reasonably well. 
This program is written in Perl and uses Jaap Karssenberg’s [File::MimeInfo](http://search.cpan.org/dist/File-MimeInfo/lib/File/MimeInfo.pm) package available on CPAN.
