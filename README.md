# ShowLocalLoginPW

 Show LOCAL Windows Login Passwords
 
ANTIVIRUS WILL FLAG THIS SCRIPT - THE AV IS DOING IT JOB - It is protecting the system passwords!

**Credit To:**<br>
JohnTheRipper - <a href="https://github.com/openwall/john">https://github.com/openwall/john</a><br>
Mimikatz - <a href="https://github.com/gentilkiwi/mimikatz">https://github.com/gentilkiwi/mimikatz</a><br>
7zip - <a href="https://www.7-zip.org/">https://www.7-zip.org/</a><br>

Administrator rights are required as the script uses VSS to be able to do this on a live system

A good example of a real world use case:

	Remote site has a non domain machine, with alternate admin users, and one cannot sign in.  
	Your only options would be to either go onsite with a PE or password reset disk, or you could delete the account and transfer the data to a new user.
	With this you could attempt to reveal the other users passwords. Then you would be able log into the other user and change the password or simply tell the client what it is.