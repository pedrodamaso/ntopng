--
-- (C) 2013-20 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path
require "lua_utils"
local plugins_utils = require("plugins_utils")
local user_scripts = require("user_scripts")
local page_utils = require("page_utils")

sendHTTPContentTypeHeader('text/html')
page_utils.set_active_menu_entry(page_utils.menu_entries.plugins)

dofile(dirs.installdir .. "/scripts/lua/inc/menu.lua")

-- print[[<hr>]]

local ifid = interface.getId()
local edition = _GET["edition"] or ""

-- #######################################################

if(isAdministrator() and (_POST["action"] == "reload")) then
  local plugins_utils = require("plugins_utils")

  plugins_utils.loadPlugins()
  user_scripts.loadDefaultConfig()
end

-- #######################################################

local function printPlugins()
  local plugins = plugins_utils.getLoadedPlugins()

  print[[<h3>]] print(i18n("plugins_overview.loaded_plugins")) print[[</h3><br>
  <table class="table table-bordered table-sm table-striped">
    <tr><th width="20%">]] print(i18n("plugins_overview.plugin")) print[[</th><th>]] print(i18n("show_alerts.alert_description")) print[[</th><th>]] print(i18n("plugins_overview.source_location")) print[[</th><th width="10%">]] print(i18n("plugins_overview.availability")) print[[</th></tr>]]

  for _, plugin in pairsByField(plugins, "title", asc) do
    local available = ""

    -- Availability
    if(plugin.edition == "enterprise") then
      available = "Enterprise"
      if((edition ~= "") and (edition ~= "enterprise")) then goto skip end
    elseif(plugin.edition == "pro") then
      available = "Pro"
      if((edition ~= "") and (edition ~= "pro")) then goto skip end
    else
      available = "Community"
      if((edition ~= "") and (edition ~= "community")) then goto skip end
    end

    print(string.format([[<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>]], plugin.title, plugin.description, plugin.path, available))
    ::skip::
  end

  print[[</table>]]
end

-- #######################################################

print[[<div class="row">
<div class="col col-md-1">
  <form class="form-inline" style="width:12em">
    <select id="filter_select" name="edition" class="form-control">
    <option value="" ]] print(ternary(isEmptyString(edition, "selected", ""))) print[[>]] print(i18n("all")) print[[</option>
    <option value="community" ]] print(ternary(edition == "community", "selected", "")) print[[>]] print(i18n("plugins_overview.edition_only", {edition="Community"})) print[[</option>
    <option value="pro" ]] print(ternary(edition == "pro", "selected", "")) print[[>]] print(i18n("plugins_overview.edition_only", {edition="Pro"})) print[[</option>
    <option value="enterprise" ]] print(ternary(edition == "enterprise", "selected", "")) print[[>]] print(i18n("plugins_overview.edition_only", {edition="Enterprise"})) print[[</option>
    </select>
  </form>
</div>]]

if isAdministrator() then
  print[[<div class="col col-md-2 offset-9">
  <form class="form-inline" method="POST">
    <input name="csrf" type="hidden" value="]] print(ntop.getRandomCSRFValue()) print[[">
    <input name="action" type="hidden" value="reload" />
    <button class="btn btn-primary" style="margin-left:auto" type="submit">]] print(i18n("plugins_overview.reload_plugins")) print[[</button>
  </form>
</div>
]]
end

print[[
</div>
<script>
  $("#filter_select").on("change", function() {
    $("#filter_select").closest("form").submit();
  });
</script><br>]]

printPlugins()

dofile(dirs.installdir .. "/scripts/lua/inc/footer.lua")

