# `sccrypt` - Super Simple, Zero-Cost, Secrets Management in Github
Simple tool to encrypt files in a way suitable for committing to a github repo. Or for any other reason really.

This means they can be pulled via the github API if required - since they are all encrypted on the way in, they must be decrypted on the way out.

In most cases add the secrets / keys directly in the project repo for convenience. But ofc you can clone/fork this repo and add secrets in a central location.

This project is not your nanny - it doesn't presently guard against comitting an unencrypted secret.
So don't do that. You're gonna have a bad time if you do that.
(Tip: the `-c` flag helps avoid this)

## Configure & Install
* Create the encryption key
  * `openssl rand -hex 32 > ~/.sccrypt.key`
  * Set tight perms `chmod 600 ~/.sccrypt.key`
  * Obviously you want to put this in a very safe place too - a password manager is a good choice.
* Optional install and upgrade...
```bash
sudo cp -f sccrypt.sh /usr/local/bin/sccrypt
```

## Usage
```bash
sccrypt [-e|-d] [-c|-i] <file>
```
* The tool outputs the encrypted / decrypted `file` to stdout by default
* Use `-c` flag to create `file.sccrypt` when encrypting (keeps original `file`) or create decrypted `file` when decrypting `.sccrypt` files
* Use `-i` flag to modify `file` in-place
* Examples...
```bash
# encrypt/decrypt to stdout
sccrypt -e file                    
sccrypt -d file

# creates file.sccrypt
sccrypt -e -c file
# creates file from file.sccrypt
sccrypt -d -c file.sccrypt

# encrypt/decrypt the file in-place
sccrypt -e -i file
sccrypt -d -i file

# save to different file
sccrypt -e file > file.encrypted
sccrypt -d file.encrypted > file
```
* Typically the `-c` flag is most useful..
  * Your secret files are already gitignored
  * `sccrypt -e -c .env` and then `git add .env.sccrypt`
  * After cloning repo, simply `sccrypt -d -c .env.sccrypt` to create the secret `.env` that your project needs to run

## TODO's
* Add a way to specify an alternate encryption key location
* Add a rotation mechanism
* Add a git workflow to check for un-encrypted secrets about to be committed

---

## Similar Projects
This here is the KISS version - but there are a number of projects that do this in a more robust and fully featured way, you should probably use them.

* [SOPS](https://github.com/getsops/sops)
* [git-crypt](https://github.com/AGWA/git-crypt)
* [git-secret](https://github.com/sobolevn/git-secret)
* [git-cipher](https://github.com/wincent/git-cipher)
* [git-private](https://github.com/erkkah/git-private)
