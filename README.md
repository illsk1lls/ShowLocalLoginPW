# Show LOCAL Windows Login Passwords
 
ANTIVIRUS WILL FLAG THIS SCRIPT - THE AV IS DOING ITS JOB<br>
It is protecting the system login passwords!<br>
In MOST cases you will need to disable AV<br>

**Credit To:**<br>
JohnTheRipper - <a href="https://github.com/openwall/john">https://github.com/openwall/john</a><br>
Mimikatz - <a href="https://github.com/gentilkiwi/mimikatz">https://github.com/gentilkiwi/mimikatz</a><br>
7zip - <a href="https://www.7-zip.org/">https://www.7-zip.org/</a><br>
*The above pre-reqs are retrieved by the script automatically during execution, and removed when the script is complete*

Administrator rights are required as the script uses VSS to be able to do this on a live system

This works ONLY for local users. It will not work for MS accounts.

The script uses VSS to copy the SYSTEM and SAM registry hives to a temp folder, then Mimikatz performs a lsadump on the copied hives, and gets NTLM hashes for each local user.  JohnTheRipper is then used against the hashes in an attempt to reveal the passwords for each local user.  The amount of time required to reveal the password is related to the complexity of the password.  For simple passwords the script should work almost instantly.

### A good example of a real world use case:

Remote site has a non-domain machine, with multiple admin users, and one cannot sign in.  Your only options would be to either go onsite with a PE or password reset disk, or you could remotely create a new user, transfer the data, and delete the locked account.  With this you could attempt to reveal the other users passwords.  Then you would be able log into the other user and change the password or simply tell the client what it is.
