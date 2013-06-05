#ifndef	_JIMDIRENT_H
#define	_JIMDIRENT_H

# ifdef WIN32

#  include	<windows.h>
#  include	<errno.h>

typedef	long	off_t;
typedef	_ino_t	ino_t;

struct dirent
{
    ino_t   d_ino;
    off_t   d_off;
    unsigned short  d_reclen;
    char            d_name[MAX_PATH+1];
};

struct DIR
{
    bool  isFirst;		    // Signal that we have not yet found any files in a directory
    unsigned char   dirName[MAX_PATH+1];    // Storage for the current directory/file
    HANDLE	    fileHandle;		    // handle for the file/directory we find
    struct dirent   arthurDent;		    // Fixed dirent entry

} ;

#  define	opendir	    jimopendir
#  define	readdir	    jimreaddir
#  define	closedir    jimclosedir

#  define	DIRDELIM    '\\'

DIR		* opendir   (const char *);
struct dirent	* readdir   (DIR *);
int		  closedir  (DIR *);

# else

#  include	<dirent.h>
#  include	<errno.h>
#  define	DIRDELIM    '/'

# endif

#endif
