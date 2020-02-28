local require = require
local tools = require("wtf.core.tools")
local Plugin = require("wtf.core.classes.plugin")
local route = require "resty.route".new()

local _M = Plugin:extend()
_M.name = "honeybot.fake.owa"
config = {}

function set_headers(hdrs)
  local ngx = ngx
  local pairs = pairs
  ngx.header["Server"] = nil
  
  if hdrs then
    for key,val in pairs(hdrs) do
      ngx.header[key] = val
    end
  end
end

function send_response(state, content)
  ngx.ctx.response_from_lua = 1
  ngx.status = state
  ngx.print(content)
  ngx.exit(state)
end
function get_file_extension(url)
  return url:match("^.+%.(.+)$")
end

function get_ct()
  local ext = get_file_extension(ngx.var.uri)
  local ct = ""
  if ext == "txt" then
    ct = "text/plain"
  elseif ext == "html" then
    ct = "text/html; charset=UTF-8"
  elseif ext == "css" then
    ct = "text/css; charset=utf-8"
  elseif ext == "js" then
    ct = "application/javascript"
  elseif ext == "gif" then
    ct = "image/gif"
  elseif ext == "jpg" or ext == "jpeg" then
    ct = "image/jpg"
  else
    ct = "text/html; charset=UTF-8"
  end
  return ct
end

function http404()
  ngx.header["Cache-Control"] = "private"
  ngx.header["Content-Type"] = "text/html; charset=utf-8"
  ngx.header["Date"] = ngx.http_time(ngx.time())
  ngx.header["request-id"] = "5bb7ce62-600b-4e6f-a000-a5dd7c50c5f6"
  ngx.header["Server"] = "Microsoft-IIS/8.5"
  ngx.header["X-AspNet-Version"] = "4.0.30319"
  ngx.header["X-CalculatedBETarget"] = ngx.var.host
  ngx.header["X-FEServer"] = "MAIL"
  ngx.header["X-Powered-By"] = "ASP.NET"
  ngx.header["X-UA-Compatible"] = "IE=10"
  
  local filename = config["datapath"] .. config["version"] .. "/__404.html"
  local template = io.open(filename, "rb")
  if template ~= nil then
    local page = template:read "*a"
    send_response(404, page)
  else
    send_response(404, "Not found")
  end
end

function set_static_headers()
  local headers = {}
  headers["Accept-Ranges"] = "bytes"
  headers["Access-Control-Allow-Origin"] = "*"
  headers["Cache-Control"] = "public, max-age=2592000"
  headers["Content-Type"] = get_ct()
  headers["Date"] = ngx.http_time(ngx.time())
  headers["ETag"] = "05d3bc5f7fcd31:0"
  headers["Last-Modified"] = "Tue, 05 Jun 2018 18:05:22 GMT"
  headers["request-id"] = "e6a8290a-3ce5-4718-934d-89de27f4869d"
  headers["Server"] = "Microsoft-IIS/8.5"
  headers["Set-Cookie"] = "X-BackEndCookie=S-1-5-21-2842635114-1562026284-3637546774-20330=u56Lnp2ejJqByMzKx5manMbSmsnMyNLLx5qZ0p3IxsnSypzGzMzNmZzKmp7NgYHNz83P0s/M0s3Gq8/JxcrHxc3M; expires=" .. ngx.cookie_time(ngx.time() + 60*60*24*30) .."; path=/owa; secure; HttpOnly; SameSite=None"
  headers["X-AspNet-Version"] = "4.0.30319"
  headers["X-BackEnd-Begin"] = os.date("%Y-%m-%dT%H:%M:%s.244")
  headers["X-BackEnd-End"] = os.date("%Y-%m-%dT%H:%M:%s.232")
  headers["X-CalculatedBETarget"] = ngx.var.host
  headers["X-Content-Type-Options"] = "nosniff"
  headers["X-FEServer"] = "MAIL"
  headers["X-Powered-By"] = "ASP.NET"
  
  set_headers(headers)
end
function static(self, path)
  local filename = config["datapath"] .. config["version"] .."/".. path
  local template = io.open(filename, "rb")
  if template ~= nil then
    local page = template:read "*a"
    set_static_headers()
    send_response(200, page)
  else
    http404()
  end
end


function root_redirect()
  local headers = {}
  headers["Date"] = ngx.http_time(ngx.time())
  headers["Content-Length"] = "0"
  headers["Cache-Control"] = "no-cache"
  headers["Pragma"] = "no-cache"
  headers["Server"] = "Microsoft-IIS/8.5"
  headers["X-Powered-By"] = "ASP.NET"
  local port = ngx.var.server_port
  if ngx.var.scheme == "https" and port == "443" then port = "" end
  if ngx.var.scheme == "http" and port == "80" then port = "" end
  local new_uri = ngx.var.scheme .."://"..ngx.var.host
  if port ~= "" then new_uri = new_uri .. ":"..port end
  new_uri = new_uri .."/owa/"
  headers["Location"] = new_uri
  set_headers(headers)
  send_response(301, "")
end

function owa_redirect()
  local headers = {}
  headers["Date"] = ngx.http_time(ngx.time())
  headers["Content-Type"] = "text/html; charset=utf-8"
  headers["request-id"] = "3aa5e8d2-d894-41f9-bca2-4e6e5dff5112"
  headers["Server"] = "Microsoft-IIS/8.5"
  local expires = 60*60*24*365 -- 1 year
  headers["Set-Cookie"] = "ClientId=SBFGNSOKEUQVRKZLDWLA; expires=" .. ngx.cookie_time(ngx.time() + expires) .."; path=/; HttpOnly"
  headers["X-FEServer"] = "MAIL"
  headers["X-Powered-By"] = "ASP.NET"
  local port = ngx.var.server_port
  if ngx.var.scheme == "https" and port == "443" then port = "" end
  if ngx.var.scheme == "http" and port == "80" then port = "" end
  local new_uri = ngx.var.scheme .."://"..ngx.var.host
  if port ~= "" then new_uri = new_uri .. ":"..port end
  
  local referer =  ngx.var.http_referer
  if referer == "" or referer == nil then referer = new_uri .. "/owa/" end
  referer = ngx.escape_uri(referer)
  new_uri = new_uri .."/owa/auth/logon.aspx?url=" .. referer .. "&reason=0"
  headers["Location"] = new_uri
  set_headers(headers)
  send_response(302, "")
end

function ecp_redirect()
  local headers = {}
  headers["Date"] = ngx.http_time(ngx.time())
  headers["Content-Type"] = "text/html; charset=utf-8"
  headers["request-id"] = "0a31b617-ddb9-40da-a196-b7ff805803b9"
  headers["Server"] = "Microsoft-IIS/8.5"
  local expires = 60*60*24*365 -- 1 year
  headers["Set-Cookie"] = "ClientId=SBFGNSOKEUQVRKZLDWLA; expires=" .. ngx.cookie_time(ngx.time() + expires) .."; path=/; HttpOnly"
  headers["X-FEServer"] = "MAIL"
  headers["X-Powered-By"] = "ASP.NET"
  local port = ngx.var.server_port
  if ngx.var.scheme == "https" and port == "443" then port = "" end
  if ngx.var.scheme == "http" and port == "80" then port = "" end
  local new_uri = ngx.var.scheme .."://"..ngx.var.host
  if port ~= "" then new_uri = new_uri .. ":"..port end
  
  local referer =  ngx.var.http_referer
  if referer == "" or referer == nil then referer = new_uri .. "/ecp/default.aspx" end
  referer = ngx.escape_uri(referer)
  new_uri = new_uri .."/owa/auth/logon.aspx?replaceCurrent=1&url=" .. referer
  headers["Location"] = new_uri
  set_headers(headers)
  send_response(302, "")
end

function ecp_default()
  local args, err = ngx.req.get_uri_args()
  local headers = {}
  if args["__VIEWSTATE"] ~= nil then
    headers["Cache-Control"] = "private"
    headers["Date"] = ngx.http_time(ngx.time())
    headers["Content-Type"] = "text/html; charset=utf-8"
    headers["request-id"] = "fdd4acfa-70e3-42a6-ba7c-0d0d46c5a807"
    headers["Server"] = "Microsoft-IIS/8.5"
    headers["X-AspNet-Version"] = "4.0.30319"
    headers["X-CalculatedBETarget"] = ngx.var.host
    headers["X-Content-Type-Options"] = "nosniff"
    headers["X-ECP-ERROR"] = "System.Web.UI.ViewStateException"
    headers["X-Frame-Options"] = "SameOrigin"
    headers["X-UA-Compatible"] = "IE=10"
    headers["X-FEServer"] = "MAIL"
    headers["X-Powered-By"] = "ASP.NET"
    
    local filename = config["datapath"] .. config["version"] .."/".. "__500.html"
    local template = io.open(filename, "rb")
    if template ~= nil then
      local page = template:read "*a"
      set_headers(headers)
      send_response(500, page)
    else
      http404()
    end
  else
    static(nil, "ecp/default.aspx")
  end
end

function failed_auth_redirect()
  local headers = {}
  headers["Date"] = ngx.http_time(ngx.time())
  headers["Content-Type"] = "text/html; charset=utf-8"
  headers["request-id"] = "b0394c0e-23d1-4b09-b129-46e560ca5d14"
  headers["Server"] = "Microsoft-IIS/8.5"
  headers["X-FEServer"] = "MAIL"
  headers["X-Powered-By"] = "ASP.NET"
  
  ngx.req.read_body()
  local args, err = ngx.req.get_post_args()
  local url = ngx.escape_uri("/")
  
  if args["destination"] ~= nil then
    url = ngx.escape_uri(args["destination"])
  end
  
  local port = ngx.var.server_port
  if ngx.var.scheme == "https" and port == "443" then port = "" end
  if ngx.var.scheme == "http" and port == "80" then port = "" end
  local new_uri = ngx.var.scheme .."://"..ngx.var.host
  if port ~= "" then new_uri = new_uri .. ":"..port end
  new_uri = new_uri .."/owa/auth/logon.aspx?url=" .. url .. "&reason=2" 
  
  headers["Location"] = new_uri
  set_headers(headers)
  send_response(302, "")
end

function successful_auth_redirect()
  local headers = {}
  headers["Cache-Control"] = "private"
  headers["Date"] = ngx.http_time(ngx.time())
  headers["Content-Type"] = "text/html; charset=utf-8"
  headers["request-id"] = "063992aa-c8b9-4c00-91d8-74a55e9b0290"
  headers["Server"] = "Microsoft-IIS/8.5"
  headers["X-AspNet-Version"] = "4.0.30319"
  headers["X-FEServer"] = "MAIL"
  headers["X-Powered-By"] = "ASP.NET"
  --[[
  ngx.req.read_body()
  local args, err = ngx.req.get_post_args()
  local url = "/owa/")
  
  if args["destination"] ~= nil then
    url = args["destination"]
  else
    local port = ngx.var.server_port
    if ngx.var.scheme == "https" and port == "443" then port = "" end
    if ngx.var.scheme == "http" and port == "80" then port = "" end
    url = ngx.var.scheme .."://"..ngx.var.host
    if port ~= "" then url = url .. ":"..port end
    url = url .."/owa/" 
  end
  
  headers["Location"] = new_uri
  ]]--
  set_headers(headers)
  send_response(200, "")
end

function logon_get()
  local headers = {}
  headers["Cache-Control"] = "no-cache, no-store"
  headers["Content-Type"] = "text/html; charset=utf-8"
  headers["Date"] = ngx.http_time(ngx.time())
  headers["Expires"] = "-1"
  headers["request-id"] = "9907f8c9-1e91-4fe4-8627-50fcfcab1884"
  headers["Pragma"] = "no-cache"
  headers["Server"] = "Microsoft-IIS/8.5"
  headers["X-AspNet-Version"] = "4.0.30319"
  headers["X-Frame-Options"] = "SAMEORIGIN"
  headers["X-Powered-By"] = "ASP.NET"
  set_headers(headers)
  
  local filename = config["datapath"] .. config["version"] .. "/owa/auth/"
  local option = "logon.aspx"
  
  local args, err = ngx.req.get_uri_args()
  
  if args["url"] ~= nil then
    local args_url = args["url"]
    if args_url:match(".*/ecp.*") then
      option = "logon.aspx.admin"
    end
  end
  if args["reason"] == "2" then
    option = "logon.aspx.fail"
  end
  
  filename = filename .. option
  
  local template = io.open(filename, "rb")
  if template ~= nil then
    local page = template:read "*a"
    send_response(200, page)
  else
    send_response(404, "Not found")
  end
end



function _M:init(...)
  local select = select
  local instance = select(1, ...)
  config["version"] = self:get_optional_parameter('version')
  config["datapath"] = self:get_optional_parameter('path')

  route "=/" (root_redirect)
  route "=/owa" (owa_redirect)
  route "=/owa/" (owa_redirect)
  route "=/owa/auth/logon.aspx" (logon_get)
  route "=/ecp" (ecp_redirect)
  route "=/ecp/" (ecp_redirect)
  route "=/ecp/default.aspx" (ecp_default)
  route "=/owa/auth.owa" {
    get  = (owa_redirect),
    post = (successful_auth_redirect)
  }
  route "#/(.+)" (static)
  -- route:on(404, not_found)
  
	return self
end

function _M:content(...)
  route:dispatch(ngx.var.uri, ngx.var.request_method)
end

return _M
