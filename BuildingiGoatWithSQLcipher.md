# Introduction #

In iGoat (1.x and 2.x), there is an exercise on secure local data storage. In it, a simple SQLite database is used to store some login credentials. However, as you find out in the exercise, a SQLite database file provides no file-level encryption to protect sensitive data. So, to solve the exercise, you are instructed to use SQLcipher to encrypt the database file.

SQLcipher (see http://sqlcipher.net for more info) uses AES-256 to encrypt a database file, but is otherwise an exact extension of SQLite. The AES library is contained in the Internet standard OpenSSL code (see http://openssl.org).

Both SQLcipher and OpenSSL are included in iGoat's src tree, but require a few simple steps in order to compile and execute correctly using Xcode.

Once the iGoat app has been modified to use SQLcipher, follow the detailed instructions below to get your database to encrypt. Note, if you do this wrong, iGoat will still execute, and no warning will be given that your database is NOT being encrypted. Be sure to verify that the credentials.sqlite file is properly encrypted before proceeding to the next exercise.

# Details #

Building iGoat (or any iOS app) with SQLcipher requires the following steps:
  * Include the source trees for OpenSSL and SQLcipher. They are included with iGoat in the ~/lib folder, or you can download them from http://sqlcipher.net and http://openssl.org. (See http://sqlcipher.net/ios-tutorial/ for guidance on what files to download.)
  * If you are downloading the sources, be sure to also grab openssl-xcode, which is an Xcode project description for building openssl properly. It is available from http://github.com/sjlombardo/openssl-xcode
  * Regardless of which src you're using, drag the sqlcipher.xcodeproj and openssl.xcodeproj project files into your iGoat (or other) project. They should appear in Xcode as subsidiary projects within your iGoat project.
  * In Xcode Preferences, go into the Source Trees tab, and add a setting for OPENSSL\_SRC with a display name of OPENSSL\_SRC and a path of $wherever\_you\_put\_OPENSSL. Do likewise for SQLCIPHER\_SRC.
  * In the iGoat project, select the iGoat target and the "Build Phases" tab, where there should be drop-down tables for "Target Dependencies" and "Link Binary WIth Libraries".
  * Add target dependencies for "crypto (openssl)" and "sqlcipher (sqlcipher)".
  * Add binaries to link for "libsqlcipher.a" and "libcrypto.a".
  * Remove the "libsqlite3.dylib" binary if present.
  * Now click on the "Build Settings" tab, which should be just to the left of the "Build Phases" tab.
  * Select "All" (as opposed to "Basic") and search for "Other C Flags".
  * Add a new "Release" flag (which should already contain "-DNS\_BLOCK\_ASSERTIONS=1") of "-DSQLITE\_HAS\_CODEC".

If all goes well, iGoat should now compile and build with both OpenSSL and SQLcipher in place now. Run the exercise again, and verify that the database is being properly encrypted.

And, as we note in the iGoat source, NEVER encrypt a database exactly as we've done in the exercise (with the password hard coded in the source code)! NEVER EVER EVER do this! Seriously. Don't do it.

Key management turns out to be the most difficult part of the problem. The crypto is easy. So, how would you securely set a crypto key for the database?

# Note for iGoat Contributors #

If you plan to make and commit changes to the iGoat source tree, don't point the OPENSSL\_SRC and SQLCIPHER\_SRC paths to the corresponding directories within in the iGoat repository (in the /lib dir). Instead, you should either...

A) Copy (don't cut or "mv") the directories to a location _outside_ of the iGoat repository, or...

B) Download the sources from the sites mentioned above and untar them _outside_ of the iGoat repository.

Then, be sure to point OPENSSL\_SRC and SQLCIPHER\_SRC to the corresponding directories.

If you point to the source directories _within_ the iGoat repository, Mercurial will notice the new files created during the build process (object files, for example) and identify them as not being tracked. We don't want that! Build artifacts don't belong in the repository.

That's all!