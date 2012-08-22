# Auth: https://subdomain.sharefile.com/rest/getAuthID.aspx?username=email@address&password=password
 
require 'open-uri'
require 'net/https'
require 'json'
require 'yaml'

# using local certs to make SSL work
module Net 
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=
   
    def use_ssl=(flag)
      open('ca-bundle.crt', 'w') do |file|
        file << open("http://certifie.com/ca-bundle/ca-bundle.crt.txt").read
      end
      self.ca_file = 'ca-bundle.crt'
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end
 
class ShareFolder
 
  attr_accessor :id, :authid, :subdomain,
                :children,
                :parentid,
                :parentname,
                :grandparentid,
                :type,
                :displayname,
                :size,
                :creatorname,
                :zoneid,
                :canupload,
                :candownload,
                :candelete,
                :creationdate,
                :filename,
                :details,
                :creatorid,
                :creatorfname,
                :creatorlname,
                :description,
                :expirationdate,
                :filecount,
                :progenyeditdate,
                :streamid,
                :commentcount,
                :isfavorite,
                :ispinned,
                :ispersonal

 
  def initialize(id, authid, subdomain, item=nil, include_children=false)
    @id = id
    @authid = authid
    @subdomain = subdomain
    @children = []

    if item #get attributes from item to avoid an extra API call
      @parentid        = item["parentid"]
      @parentname      = item["parentname"]
      @grandparentid   = item["grandparentid"]
      @type            = item["type"]
      @displayname     = item["displayname"]
      @size            = item["size"]
      @creatorname     = item["creatorname"]
      @zoneid          = item["zoneid"]
      @canupload       = item["canupload"]
      @candownload     = item["candownload"]
      @candelete       = item["candelete"]
      @creationdate    = item["creationdate"]
      @filename        = item["filename"]
      @details         = item["details"]
      @creatorid       = item["creatorid"]
      @creatorfname    = item["creatorfname"]
      @creatorlname    = item["creatorlname"]
      @description     = item["description"]
      @expirationdate  = item["expirationdate"]
      @filecount       = item["filecount"]
      @progenyeditdate = item["progenyeditdate"]
      @streamid        = item["streamid"]
      @commentcount    = item["commentcount"]
      @isfavorite      = item["isfavorite"]
      @ispinned        = item["ispinned"]
      @ispersonal      = item["ispersonal"]
    else #get attributes from getex
      info = self.getex
      @parentid        = info["parentid"]
      @parentname      = info["parentname"]
      @grandparentid   = info["grandparentid"]
      @type            = info["type"]
      @displayname     = info["displayname"]
      @size            = info["size"]
      @creatorname     = info["creatorname"]
      @zoneid          = info["zoneid"]
      @canupload       = info["canupload"]
      @candownload     = info["candownload"]
      @candelete       = info["candelete"]
      @creationdate    = info["creationdate"]
      @filename        = info["filename"]
      @details         = info["details"]
      @creatorid       = info["creatorid"]
      @creatorfname    = info["creatorfname"]
      @creatorlname    = info["creatorlname"]
      @description     = info["description"]
      @expirationdate  = info["expirationdate"]
      @filecount       = info["filecount"]
      @progenyeditdate = info["progenyeditdate"]
      @streamid        = info["streamid"]
      @commentcount    = info["commentcount"]
      @isfavorite      = info["isfavorite"]
      @ispinned        = info["ispinned"]
      @ispersonal      = info["ispersonal"]
    end
    
    fetch_children if include_children
  end

  # Returns id of the current folder verifying it exists
  def get
    url = prefix + "get"
    return response(url)
  end       

  # Returns all metadata of the requested folder id
  def getex
    url = prefix + "getex"
    return response(url)
  end

  # Passing the required "name" parameter creates a folder with this name. Optionally, passing an "overwrite" parameter as true/false, will overwrite an existing folder if true.
  def create(name)
    url = prefix + "create" + "&name=#{name}"
    return response(url)
  end

  # Returns a list of all sub-folders and files in the current folder
  def list
    url = prefix + "list"
    return response(url)
  end

  # Deletes a folder given the passed in "id" parameter and all children of this folder.
  def delete
    url = prefix + "delete"
    return response(url)
  end

  # Passing the required "name" parameter will change a folders name to what is passed.
  def rename(name)
    url = prefix + "rename&name=#{name}" 
    return response(url)
  end

  # (not implemented) Calling this function will return a link directly to a specified folder given the "id" parameter of a folder.
  def request_url(requirelogin=false, requireuserinfo=false, expirationdays=30, notifyonupload=false)
  end

  # (not implemented) Grants folder privileges to the given user.
  def grant(userid=nil, email=nil, download=true, upload=false, view=true, admin=false, delete=false, notifyupload=false, notifydownload=false) #(userid OR email) required
  end
  
  # (not implemented) Revokes folder privileges from the given user
  def revoke(userid=nil, email=nil) #(userid OR email) required
  end

  # Returns a list of all sub-folders and files in the current folder with additional information.
  def listex
    url = prefix + "listex"
    return response(url)
  end

  # Returns a permission list for the given folder.
  def getacl
    url = prefix + "getacl"
    return response(url)
  end

  # populates ShareFolder.children list. Can be done at initialize using include_children=true
  def fetch_children
    @children = []
    for item in self.listex
      if item["type"] == "folder" and item["id"]!=@id #sharefile API includes self in list
        @children << ShareFolder.new(item["id"], @authid, item)
      elsif item["type"] == "file"
        @children << ShareFile.new(item["id"], @authid, item)
      end
    end
  end

  # Returns a ShareFolder object that is the parent of self
  def parent
    return ShareFolder.new(@parentid, @authid, @subdomain)
  end

  # Returns a ShareFolder object that is the grandparent of self
  def grandparent
    return ShareFolder.new(@grandparentid, @authid, @subdomain)
  end

private

  def prefix
    "https://#{@subdomain}.sharefile.com/rest/folder.aspx?fmt=json&authid=#{@authid}&id=#{@id}&op="
  end

  def response(url)
    r = JSON.parse(open(url).read)
    if r["error"] == false
      return r["value"]
    else
      return r
    end
  end
end #ShareFolder
 
class ShareFile
 
  attr_accessor :id, :authid, :subdomain,
                :type,
                :filename,
                :displayname,
                :size,
                :creationdate,
                :creatorfname,
                :creatorlname,
                :description,
                :descriptionhtml,
                :expirationdate,
                :parentid,
                :parentname,
                :url,
                :previewstatus,
                :virusstatus,
                :md5,
                :thumb75,
                :thumb600,
                :creatorid,
                :streamid,
                :zoneid

  def initialize(id, authid, subdomain, item=nil)
    @id = id
    @authid = authid
    @subdomain = subdomain

    if item #get attributes from item to avoid an extra API call
      @type             = item["type"]
      @filename         = item["filename"]
      @displayname      = item["displayname"]
      @size             = item["size"]
      @creationdate     = item["creationdate"]
      @creatorfname     = item["creatorfname"]
      @creatorlname     = item["creatorlname"]
      @description      = item["description"]
      @descriptionhtml  = item["descriptionhtml"]
      @expirationdate   = item["expirationdate"]
      @parentid         = item["parentid"]
      @parentname       = item["parentname"]
      @url              = item["url"]
      @previewstatus    = item["previewstatus"]
      @virusstatus      = item["virusstatus"]
      @md5              = item["md5"]
      @thumb75          = item["thumb75"]
      @thumb600         = item["thumb600"]
      @creatorid        = item["creatorid"]
      @streamid         = item["streamid"]
      @zoneid           = item["zoneid"]
    else #get attributes from getex
      info = self.getex
      @type             = info["type"]
      @filename         = info["filename"]
      @displayname      = info["displayname"]
      @size             = info["size"]
      @creationdate     = info["creationdate"]
      @creatorfname     = info["creatorfname"]
      @creatorlname     = info["creatorlname"]
      @description      = info["description"]
      @descriptionhtml  = info["descriptionhtml"]
      @expirationdate   = info["expirationdate"]
      @parentid         = info["parentid"]
      @parentname       = info["parentname"]
      @url              = info["url"]
      @previewstatus    = info["previewstatus"]
      @virusstatus      = info["virusstatus"]
      @md5              = info["md5"]
      @thumb75          = info["thumb75"]
      @thumb600         = info["thumb600"]
      @creatorid        = info["creatorid"]
      @streamid         = info["streamid"]
      @zoneid           = info["zoneid"]
    end
  end

  # Returns all metadata of the requested file id.
  def get
    url = prefix + "get"
    return response(url)
  end

  # (not implemented) Generates a public link for download.
  def getlink(requireuserinfo=false,expirationdays=30,notifyondownload=false, maxdownloads=-1)
  end

  # Removes a file from the system. Files can be recovered within 7 days, but not currently through the API.
  def delete
    url = prefix + "delete"
    return response(url)
  end

  # Passing the required "name" parameter will change a files name to what is passed.
  def rename(name)
    url = prefix + "rename&name=#{name}"
    return response(url)
  end

  # (not implemented) Passing the required parameters will create the file in the specified folder AFTER the upload has completed. Since a file cannot exist without a physical file uploaded, if the upload fails or is cancelled before all data has been transferred to ShareFile, this file will not exist. "filename" must include the extension.
  def upload(filename, folderid=nil, unzip=true, overwrite=false, details=nil) #filename must include the extension
  end

  # Returns a direct link to download the file.
  def download
    url = prefix + "download"
    return response(url)
  end

  # Returns additional data for the requested file.
  def getex
    url = prefix + "getex"
    return response(url)
  end

  # Returns a ShareFolder object that is the parent of self
  def parent
    return ShareFolder.new(@parentid, @authid, @subdomain)
  end

  # Returns a ShareFolder object that is the grandparent of self
  def grandparent
    return ShareFolder.new(@grandparentid, @authid, @subdomain)
  end

private

  def prefix
    "https://#{@subdomain}.sharefile.com/rest/file.aspx?fmt=json&authid=#{@authid}&id=#{@id}&op="
  end

  def response(url)
    r = JSON.parse(open(url).read)
    if r["error"] == false
      return r["value"]
    else
      return r
    end
  end

end #ShareFile
 

class ShareUser
  attr_accessor :authid, :subdomain, :id, 
                :firstname, 
                :lastname, 
                :email, 
                :isemployee,
                :company,
                :createfolders,
                :usefilebox,
                :manageusers,
                :isadmin,
                :password

  def initialize(id, authid, subdomain)
    @id = id
    @authid = authid
    @subdomain = subdomain

    #TODO full init
  end

  # Returns the user metadata.
  def get
    url = prefix + "get" + id_param
    return response(url)
  end

  # Returns a list of all the account employees.
  def liste
    url = prefix + "liste"
    return response(url)
  end

  # Returns a list of all the account clients.
  def listc
    url = prefix + "listc"
    return response(url)
  end

  # Calling this will delete the user completely from the system. Note: This operation may take several minutes depending on the number of associated folders the user is assigned to.
  def delete
    url = prefix + "delete" + id_param
    return response(url)
  end

  # Calling this will delete the user from all folders ONLY but not the system. Note: This operation may take several minutes depending on the number of associated folders the user is assigned to.
  def deletef
    url = prefix + "deletef" + id_param
    return response(url)
  end

  # (not implemented) Passing in the required parameters, a user is created in the system as either a client or an employee of the account.
  def create(firstname, lastname, email, isemployee=false, company=nil, createfolders=false, usefilebox=false, manageusers=false, isadmin=false, password=nil)    
  end

  # (not implemented) Passing in the required parameters, a user is updated in the system. Other specific updates must be made to separate operators.
  def update(firstname, lastname, email=nil)
  end

  # (not implemented) Calling this will reset the specified users password.
  def resetp(oldp,newp,notify=false)
  end

  # Returns additional information about the user.
  def getex
    url = prefix + "getex" + id_param
    return response(url)
  end

private

  def response(url)
    r = JSON.parse(open(url).read)
    if r["error"] == false
      return r["value"]
    else
      return r
    end
  end

  def prefix
    "https://#{@subdomain}.sharefile.com/rest/users.aspx?fmt=json&authid=#{@authid}&op="
  end

  def id_param
    "&id=#{@id}"
  end

end #ShareUser


=begin rdoc
 This is how you make the initial connection to sharefile API.

 +connection+ = +ShareFileService+.+new+("_yoursubdomain_", "_youremail_", "_yourpassword_")
 
 +root+ = +connection+.+root_folder+ => ShareFolder object that is the root of your sharefile account
 
 +root+.+fetch_children+ -- call explicitly to avoid unneeded API calls
 
 +root+.+children+ => list of ShareFolder and ShareFile objects in the root. Populated by +fetch_children+, otherwise empty list.
 
 +connection+.+search+("_superimportantfile.txt_") => list of ShareFolder and ShareFile objects matching your search from sharefile.
=end
class ShareFileService
 
  attr_accessor :root_folder, :subdomain, :email, :password, :authid, :current_folder_id, :root_id

  def initialize(subdomain,email,password)
    @subdomain = subdomain
    @email = email
    @password = password
    auth_url = "https://#{@subdomain}.sharefile.com/rest/getAuthID.aspx?username=#{@email}&password=#{@password}&fmt=json"
    @authid = JSON.parse(open(auth_url).read)["value"]
    root_id_url = "https://#{@subdomain}.sharefile.com/rest/folder.aspx?op=get&authid=#{@authid}&path=/&fmt=json"
    @root_id = JSON.parse(open(root_id_url).read)["value"]
    @root_folder = ShareFolder.new(@root_id, @authid, @subdomain)
  end

  # Returns a list of ShareFolder and ShareFile objects.
  def search(q)
    results = []
    url = "https://#{@subdomain}.sharefile.com/rest/search.aspx?op=search&query=#{q}&authid=#{@authid}&fmt=json"
    response = JSON.parse(open(url).read)
    if response["error"] == false #success
      response["value"].each do |item|
        if item["type"] == "folder"
          results << ShareFolder.new(item["id"], @authid, @subdomain, item)
        elsif item["type"] == "file"
          results << ShareFile.new(item["id"], @authid, @subdomain, item)
        end
      end
      return results
    else #error
      return response
    end
  end
 
end #ShareFileService
 
