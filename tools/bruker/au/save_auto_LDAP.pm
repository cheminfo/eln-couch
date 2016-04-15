//save_auto_LDAP for nmr4313l.epfl.ch
//this script replaces save and autosave for TS 3.x
//it includes the FID save - 22.8.14

#include <time.h>
#include <string.h>

char tempjdx[255];


char  pulprog[PATH_MAX];
int   parmode;


GETCURDATA


time_t now;
struct tm  *ts;
char toappend[255];



time(&now);
ts = localtime(&now);
strftime(toappend, sizeof(toappend), "%M%S", ts);

// Code to extract the current username from the file path on disk

char* cp = strrchr(disk, '/');
user[0] = 0;
if (cp  &&  cp > disk  &&  strcmp(cp + 1, "nmr") == 0) {
  char* cp2;
  *cp = 0;
  cp2 = strrchr(disk, '/');
  if (cp2) {
    strncpy(user, cp2 + 1, sizeof(user) - 1);
    user[sizeof(user) - 1] = 0;
  }
  *cp = '/';
}

if (user[0] == 0) Proc_err(DEF_ERR_OPT, "%s: %s", "Could not extract user name from", disk);

// End code



//FETCHPARS("USERA1", &username);
//FETCHPARS("USERA2", &sampleName);

FETCHPARS("PARMODE", &parmode);
FETCHPARS("PULPROG", &pulprog);

if (parmode == 1) {

	/* 2D processing for COSY*/
	if (strstr(pulprog,"cosygpppqf"))
		{
                XAU("proc_2dsym","");
		//XFB;
		//ERRORABORT
		//ABS2
		//ABS1
		//SYM
		}
    
	/* 2D processing for HSQC*/
	if (strstr(pulprog,"hsqcedetgpsisp2.3"))
	 {
	   XAU("proc_2dinv","");
  	 //XFB;
  	 //ERRORABORT;
  	 //ABS2;
  	 //ABS1;
	 }

/* 2D processing for TOCSY*/
        if (strstr(pulprog,"mlevphpp"))
         {
           XAU("proc_2dhom","");
         //XFB;
         //ERRORABORT;
         //ABS2;
         //ABS1;
         }








	/* 2D processing for HMBC*/
	if (strstr(pulprog,"hmbcgplpndqf")) 
 	 {
	    XAU("proc_2dpl","");
 	 }

        /* 2D processing for ROESYPHPR*/
        if (strstr(pulprog,"roesyphpr.2"))
         {
            XAU("proc_2dhom","");
         }




} else {
/* 1D */
  	XAU("proc_1d","");
}

//exports the FID as jcamp (otpion 0)
sprintf(tempjdx,"%s%s%s%s.fid.%s","/opt/data/jcamp/",user,"_",name,toappend);

{(void)sprintf(Hilfs_string, "tojdx \"%s\" %d %d \"%s\" \"%s\" \"%s\"", tempjdx, 0, 3, name, "BRUKER", user);
SETCURDATA;
AUERR=CPR_exec(Hilfs_string, WAIT_TERM);}

//exports the spectra as jcamp (2D option 1 and 1D option 2)
sprintf(tempjdx,"%s%s%s%s.jdx.%s","/opt/data/jcamp/",user,"_",name,toappend);
if (parmode == 1)
{
/* 2D */
{(void)sprintf(Hilfs_string, "tojdx \"%s\" %d %d \"%s\" \"%s\" \"%s\"", tempjdx, 1, 3, name, "BRUKER", user);
SETCURDATA;
AUERR=CPR_exec(Hilfs_string, WAIT_TERM);}
	} else {
{(void)sprintf(Hilfs_string, "tojdx \"%s\" %d %d \"%s\" \"%s\" \"%s\"", tempjdx, 2, 3, name, "BRUKER", user);
SETCURDATA;
AUERR=CPR_exec(Hilfs_string, WAIT_TERM);}
}
 
QUIT
