# Auth: https://subdomain.sharefile.com/rest/getAuthID.aspx?username=email@address&password=password
 
require 'open-uri'
require 'net/https'
require 'json'
require 'yaml'
 
module Net #use local certs to make SSL work
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

  def get
    url = prefix + "get"
    return response(url)
  end       

  def getex
    url = prefix + "getex"
    return response(url)
  end

  def create(name)
    url = prefix + "create" + "&name=#{name}"
    return response(url)
  end

  def list
    url = prefix + "list"
    return response(url)
  end

  def delete
    url = prefix + "delete"
    return response(url)
  end

  def rename(name)
    url = prefix + "rename&name=#{name}" 
    return response(url)
  end

  def request_url(requirelogin=false, requireuserinfo=false, expirationdays=30, notifyonupload=false)
  end

  def grant(userid=nil, email=nil, download=true, upload=false, view=true, admin=false, delete=false, notifyupload=false, notifydownload=false) #(userid OR email) required
  end
  
  def revoke(userid=nil, email=nil) #(userid OR email) required
  end

  def listex
    url = prefix + "listex"
    return response(url)
  end

  def getacl
    url = prefix + "getacl"
    return response(url)
  end

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

  def get
    url = prefix + "get"
    return response(url)
  end

  def getlink(requireuserinfo=false,expirationdays=30,notifyondownload=false, maxdownloads=-1)
  end

  def delete
    url = prefix + "delete"
    return response(url)
  end

  def rename(name)
    url = prefix + "rename&name=#{name}"
    return response(url)
  end

  def upload(filename, folderid=nil, unzip=true, overwrite=false, details=nil) #filename must include the extension
  end

  def download
    url = prefix + "download"
    return response(url)
  end

  def getex
    url = prefix + "getex"
    return response(url)
  end

  def parent
    return ShareFolder.new(@parentid, @authid, @subdomain)
  end

  def grandparent
    return ShareFolder.new(@grandparentid, @authid, @subdomain)
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


  end

  def prefix
    "https://#{@subdomain}.sharefile.com/rest/users.aspx?fmt=json&authid=#{@authid}&op="
  end

  def id_param
    "&id=#{@id}"
  end

  def response(url)
    r = JSON.parse(open(url).read)
    if r["error"] == false
      return r["value"]
    else
      return r
    end
  end

  def get
    url = prefix + "get" + id_param
    return response(url)
  end

  def liste
    url = prefix + "liste"
    return response(url)
  end

  def listc
    url = prefix + "listc"
    return response(url)
  end

  def delete
    url = prefix + "delete" + id_param
    return response(url)
  end

  def deletef
    url = prefix + "deletef" + id_param
    return response(url)
  end

  def create(firstname, lastname, email, isemployee=false, company=nil, createfolders=false, usefilebox=false, manageusers=false, isadmin=false, password=nil)
    
  end

  def update(firstname, lastname, email=nil)
  end

  def resetp(oldp,newp,notify=false)
  end

  def getex
    url = prefix + "getex" + id_param
    return response(url)
  end
end #ShareUser



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

  def search(q) #returns a list of ShareFolder and ShareFile objects
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
 
