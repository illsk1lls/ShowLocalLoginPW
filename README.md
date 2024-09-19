# Show LOCAL Windows Login Passwords
 
ANTIVIRUS WILL FLAG THIS SCRIPT - THE AV IS DOING ITS JOB - It is protecting the system login passwords! In MOST cases you will need to disable AV to use this script.

**Credit To:**<br>
JohnTheRipper - <a href="https://github.com/openwall/john">https://github.com/openwall/john</a><br>
Mimikatz - <a href="https://github.com/gentilkiwi/mimikatz">https://github.com/gentilkiwi/mimikatz</a><br>
7zip - <a href="https://www.7-zip.org/">https://www.7-zip.org/</a><br>

Administrator rights are required as the script uses VSS to be able to do this on a live system

This works ONLY for local users. It will not work for MS accounts.

### A good example of a real world use case:

Remote site has a non domain machine, with alternate admin users, and one cannot sign in.  Your only options would be to either go onsite with a PE or password reset disk, or you could remotely create a new user, transfer the data, and delete the locked account.  With this you could attempt to reveal the other users passwords. Then you would be able log into the other user and change the password or simply tell the client what it is.
