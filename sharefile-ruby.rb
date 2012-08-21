# Auth: https://subdomain.sharefile.com/rest/getAuthID.aspx?username=email@address&password=password
 
require 'open-uri'
require 'net/https'
require 'json'
require 'yaml'
 
module Net #use local certs to make SSL work
  class HTTP
    alias_method :original_use_ssl=, :use_ssl=
   
    def use_ssl=(flag)
      self.ca_file = 'ca-bundle.crt' 
      self.verify_mode = OpenSSL::SSL::VERIFY_PEER
      self.original_use_ssl = flag
    end
  end
end
 
class ShareFolder
 
  attr_accessor :id,
                :authid,
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

 
  REQUEST_PREFIX = "https://subdomain.sharefile.com/rest/folder.aspx?op="

  def initialize(id, authid, item=nil)
    @id = id
    @authid = authid
    @children = []

    if item
      #create from item
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
    else #create from getex
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
  end

  def get
    url = REQUEST_PREFIX+"get&authid=#{@authid}&id=#{@id}&fmt=json"
    return JSON.parse(open(url).read)["value"]
  end       

  def getex
    url = REQUEST_PREFIX+"getex&authid=#{@authid}&id=#{@id}&fmt=json"
    return JSON.parse(open(url).read)["value"]
  end

  def create(name)
    url = REQUEST_PREFIX+"create&authid=#{@authid}&id=#{@id}&name=#{name}&fmt=json"
    return JSON.parse(open(url).read)["value"]
  end

  def list
    url = REQUEST_PREFIX+"list&authid=#{@authid}&id=#{@id}&fmt=json"
    return JSON.parse(open(url).read)["value"]
  end

  def listex
    url = REQUEST_PREFIX+"listex&authid=#{@authid}&id=#{@id}&fmt=json"
    return JSON.parse(open(url).read)["value"]
  end

  def populate_children
    @children = []
    for item in self.listex
      if item["type"] == "folder" and item["id"]!=@id
        @children << ShareFolder.new(item["id"], @authid)
      elsif item["type"] == "file"
        @children << ShareFile.new(item["id"], @authid)
      end
    end
  end
end #ShareFolder
 
class ShareFile
 
  attr_accessor :id

  def initialize(id, authid)
    @id = id

  end
end #ShareFile
 
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
    @root_folder = ShareFolder.new(@root_id, @authid)
  end

  #https://subdomain.sharefile.com/rest/method.aspx?[parameter collection]

  def search(q)
    url = "https://#{subdomain}.sharefile.com/rest/search.aspx?op=search&query=#{q}&authid=#{@authid}&fmt=json"
    result = JSON.parse(open(url).read)
    if result["value"] #success
      return result["value"]
    else #error
      return result
    end
  end
 
end #ShareFileService
 
