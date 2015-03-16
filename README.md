# shared-mime-info-file
A replacement for file(1) based on shared-mime-info

This project aims to be a, as far as feasible, POSIX conformant implementation of file(1). A secondary objective is to be a, once again as far as feasible, drop-in replacement for the file command used on virtually any Linux or BSD box out there, that is Ian Darwin's one. That entails offering a version of libmagic. A last objective is to perform reasonably well. 
This program will be written in Perl and use Jaap Karssenberg's File::MimeInfo? package available on CPAN.
