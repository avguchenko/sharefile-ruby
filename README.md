# sharefile-ruby

Easily manage your ShareFile account with ruby 

### Installation

````
    require 'sharefile-ruby'
````

## Usage

### Connect

````
connection = ShareFileService.new("yoursubdomain", "youremail", "yourpassword")
````

### Where am I?
 
````
root = connection.root_folder
````
root is now a ShareFolder object that is the root of your sharefile account

### What do I have?

```` 
root.fetch_children
mystuff = root.children
```` 
mystuff is a list of ShareFolder and ShareFile objects in the root.

### Search
 
````
results = connection.search("superimportantfile.txt")
````
results is a list of ShareFolder and ShareFile objects matching your search from sharefile.


## License
* Copyright 2012 Anton Avguchenko,MIT License