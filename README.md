# sharefile-ruby

Easily manage your ShareFile account with ruby 

# Usage

````
require 'sharefile-ruby'
````

### Connect

````
myaccount = ShareFileService.new("yoursubdomain", "youremail", "yourpassword")
````

### Where am I?
 
````
root = myaccount.root_folder
````
`root` is now a `ShareFolder` object that is the root of your sharefile account

### What do we have here?

```` 
root.fetch_children
mystuff = root.children
```` 
`mystuff` is now a list of `ShareFolder` and `ShareFile` objects in the root.

### Search
 
````
results = myaccount.search("superimportantfile.txt")
````
`results` is now a list of `ShareFolder` and `ShareFile` objects matching your search, according to ShareFile.

### Parents

`ShareFolder` and `ShareFile` objects have a `parent` and a `grandparent` if lineage allows:
````
results.each do |r|
	puts "#{r.displayname}'s parent is #{r.parent.displayname}\n"
	puts "#{r.displayname}'s grandparent is #{r.grandparent.displayname}\n"
end
````

## Users

````
mypeeps = myaccount.employees
clientry = myaccount.clients
````
you now have two lists of `ShareUser` objects with your employees and clients

#### Create new user
````
new_kid = ShareUser.create(myaccount.subdomain, myaccount.authid, "Johnnie", "McFastfingerson", "johnnie@email.com")
````
OR (if you're not into the whole brevity thing):
````
new_kid = ShareUser.create(myaccount.subdomain, myaccount.authid, "Johnnie", "McFastfingerson", "johnnie@email.com", true, {"company"=>"myCompany", "createfolders"=>true, "usefilebox"=>true, "manageusers"=>true, "isadmin"=>true, "password"=>"correcthorsebatterystaple"})
````
where `true` after the email address sets `new_kid` as employee. The arguments in the hash are optional; you can specify any subset of these. Default is `false` on everything, with null (ShareFile-generated) password

Boring legal stuff
------------------

Copyright (c) 2012, Anton Avguchenko

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.