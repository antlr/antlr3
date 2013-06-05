#ifdef WIN32
#include    <java.hpp>



/** Windows implementation of opendir, behave like UNIX opendir
 */
DIR *
jimopendir(const char * directory)
{
	int	      fileFlags;
	DIR	    * doh;

	// Ensure that we have been supplied with a directory
	//
	fileFlags = GetFileAttributes((LPCSTR)directory);

	if (fileFlags == INVALID_FILE_ATTRIBUTES)
	{
		// Something was drastically wrong with this path
		//
		errno	= ENOENT;
		return	NULL;
	}
	if (( fileFlags & FILE_ATTRIBUTE_DIRECTORY) == 0)
	{
		// This is not a valid directory path, so return NULL
		//
		errno	= ENOTDIR;
		return NULL;
	}

	// OK, so it seems to be a directory, allocate a DIR structure
	//
	doh	= (DIR *)User::JavaTraits::AllocPolicyType::alloc(sizeof(DIR));

	if (doh == NULL)
	{
		// Could not allocate the memory for this.
		//
		errno	= EINVAL;
		return	NULL;
	}

	// We have allocated our structure, so fill it in
	//
	doh->isFirst    = true;	// We have not called FindFirst yet
	sprintf((char *)(doh->dirName), "%s%s*",
		directory, 
		(directory[strlen((const char *) directory)-1] == '\\' ? "" : "\\")); // Don't duplicate delimiter

	return doh;
}

static	WIN32_FIND_DATAA	fResults;

struct dirent *
readdir( DIR * doh)
{
    if (doh == NULL)
    {
	// Invalid input
	//
	return	NULL;
    }

    while(1)
    {
	// First time through, we supply the text, after that the current handle
	//
	if (doh->isFirst )
	{
	    doh->fileHandle	= FindFirstFile((LPCSTR)doh->dirName, &fResults);

	    if (doh->fileHandle == INVALID_HANDLE_VALUE)
	    {
		// Well then..
		//
		return  NULL;   // Nothing there
	    }
	    doh->isFirst = false;
	}
	else
	{
	    // Already been through once, so just ask for the next
	    // handle etc.
	    //
	    if (FindNextFileA(doh->fileHandle, &fResults) == 0)
	    {
	        return	NULL;  // Nothing left
	    }
	}

	// HIdden files are not welcome here
	//
	if ((fResults.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN) == FILE_ATTRIBUTE_HIDDEN)
	{
	    continue;   // Skip this one and try for a next
	}
    

	strcpy(doh->arthurDent.d_name, (const char *)fResults.cFileName);   // Install the file name
	return &(doh->arthurDent);					    // Return the dirent structure
    }

}

int
closedir(DIR * doh)
{
	if (doh == NULL)
	{
		return -1;
	}
	else
	{
		if	(doh->fileHandle != NULL)
		{
			FindClose(doh->fileHandle);
		}
		User::JavaTraits::AllocPolicyType::free(doh);
	}
	return 0;
}



#endif
