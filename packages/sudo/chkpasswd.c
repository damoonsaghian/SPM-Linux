int main(char** args) {
	char* username = arg[0];
	char* prompt = args[1];
	char* passwd_hashed = "$(sed -n "/$username/p" /etc/shadow | cut -d ':' -f2 | cut -d '!' -f 2)";
	char* salt = "$(echo "$passwd_hashed" | grep -o '.*\$')";
	println("%s ", prompt);
	char* entered_passwd = ; // read a line as password
	println();
	char* entered_passwd_hashed = "$(MKPASSWD_OPTIONS="-S $salt" mkpasswd -s <<< "$entered_passwd")"
	if (entered_passwd_hashed == passwd_hashed)
		exit(0);
	else {
		exit(1);
	}
}
