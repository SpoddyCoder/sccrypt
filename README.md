# Super-Simple, Zero-Cost, Github-Based Secrets Management
`sccrypt` is a simple tool to encrypt files in a way suitable for committing to a github repo. Or for any other reason really.

This means they can be pulled via the github API if required - since they are all encrypted on the way in, they must be decrypted on the way out.

In most cases you'll want to add the secrets directly in the project repo for convenience. But ofc you can clone/fork this repo and add secrets in a central location.

This project is not your nanny - it doesn't presently guard against comitting an unencrypted secret.
So don't do that. You're gonna have a bad time if you do that.
(Tip: the `-c` flag helps avoid this)

## Configure & Install
* Clone this repo
* Create your encryption key & set tight perms
  ```bash
  openssl rand -hex 32 > ~/.sccrypt.key
  chmod 400 ~/.sccrypt.key
  ```
  * Obviously you want to put this in a very safe place for backup too - a password manager is a good choice.
* Optional install and upgrade
  ```bash
  sudo cp -f sccrypt.sh /usr/local/bin/sccrypt
  ```
* By default the tool looks for the key at `~/.sccrypt.key`
* You can specify a custom location using the `SCCRYPT_KEY_FILE` environment variable
  * `export SCCRYPT_KEY_FILE="/custom/path/to/my.key"`
  * Tip: add this to your `.bashrc` or `.zshrc` for permanent use

## Usage
```bash
sccrypt <-e|-d> [-c|-i] <file>
```
* The tool outputs the encrypted / decrypted `file` to stdout by default
* Use `-c` flag to create `file.sccrypt` when encrypting (keeps original `file`) or create decrypted `file` when decrypting `.sccrypt` files
* Use `-i` flag to modify `file` in-place
* Use `-v` flag to show version number
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
* Typically the `-c` flag is most useful...
  * Your secret files are already gitignored
  * `sccrypt -e -c .env` and then `git add .env.sccrypt`
  * After cloning repo, simply `sccrypt -d -c .env.sccrypt` to create the secret `.env` that your project needs to run

## TODO's
* Add a rotation mechanism
* Add a git workflow to check for un-encrypted secrets about to be committed

---

## Similar Projects
This here is the KISS version - but there are a number of other projects that do this in a more robust and fully featured way, you should probably use them.

* https://github.com/getsops/sops
* https://github.com/AGWA/git-crypt
* https://github.com/sobolevn/git-secret
* https://github.com/wincent/git-cipher
* https://github.com/erkkah/git-private
