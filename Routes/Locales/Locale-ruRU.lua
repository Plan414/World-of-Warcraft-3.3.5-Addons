﻿-- THIS CONTENTS OF THIS FILE IS AUTO-GENERATED BY THE WOWACE PACKAGER
-- Please use the Localization App on WoWAce to update this
-- at http://www.wowace.com/projects/routes/localization/

local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale("Routes", "ruRU")
if not L then return end

-- L["Add"] = "Add"
-- L["Add node after (green)"] = "Add node after (green)"
-- L["Add node before (red)"] = "Add node before (red)"
-- L["Always show"] = "Always show"
-- L["An updated copy of TomTom is required for TomTom integration to work"] = "An updated copy of TomTom is required for TomTom integration to work"
-- L["Are you sure you want to delete this route?"] = "Are you sure you want to delete this route?"
-- L["Are you sure you want to delete this taboo? This action will also remove the taboo from all routes that use it."] = "Are you sure you want to delete this taboo? This action will also remove the taboo from all routes that use it."
-- L["A route with that name already exists. Overwrite?"] = "A route with that name already exists. Overwrite?"
-- L["A taboo with that name already exists. Overwrite?"] = "A taboo with that name already exists. Overwrite?"
-- L["Automatic route updating"] = "Automatic route updating"
--[==[ L["AUTOMATIC_UPDATE_TEXT"] = [=[
Routes will automatically update your routes and insert/remove nodes as required when you use |cffffff78GatherMate|r or |cffffff78Cartographer_<Profs>|r as your data sources. |cffffff78Gatherer/HandyNotes|r is not supported as it currently does not support callbacks.

When you find a new node in either of these addons, Routes will search the zone for existing routes with that node type and insert it in the best location in the route. SImilarly, when you delete a node in those addons, Routes will also remove the node from the relevant routes.

Moving an existing node's location by a few yards is handled by a node deletion followed by an node insertion. In fact, this is exactly how GatherMate and Cartographer_<Profs> handles it internally.

To stop this automatic updating behavior, you can turn off the option by following these steps:

|cffffff781.|r Navigate to the |cffffff78Routes|r root tree on the left side of the configuration screen.

|cffffff782.|r Uncheck the boxes for each data source.
]=] ]==]
-- L["Auto show and hide routes based on your professions"] = "Auto show and hide routes based on your professions"
-- L["Auto show/hide"] = "Auto show/hide"
-- L["Auto Show/Hide per route type"] = "Auto Show/Hide per route type"
-- L["Auto Show/Hide settings"] = "Auto Show/Hide settings"
-- L["Background"] = "Background"
-- L["Background Disclaimer"] = "This will perform the TSP route generation in the background much more slowly without locking up WoW. Please note that your WoW will still take a noticable performance hit."
-- L["Cancel route edit"] = "Cancel route edit"
-- L["Cancel taboo edit"] = "Cancel taboo edit"
-- L["CartographerExtractGas"] = "Extract Gas"
-- L["CartographerFishing"] = "Fishing"
-- L["CartographerHerbalism"] = "Herbalism"
-- L["CartographerMining"] = "Mining"
-- L["CartographerTreasure"] = "Treasure"
-- L["Cartographer_Waypoints module is missing or disabled"] = "Cartographer_Waypoints module is missing or disabled"
L["|cffffd200     %d|r node(s) are at |cffffd2000|r yards of a cluster point"] = "|cffffd200     %d|r точек сбора находятся в |cffffd2000|r метрах от указанного места"
L["|cffffd200     %d|r node(s) are between |cffffd200%d|r-|cffffd200%d|r yards of a cluster point"] = "|cffffd200     %d|r точек находятся между |cffffd200%d|r и |cffffd200%d|r метрами от указанного места"
-- L["Change default hidden route color"] = "Change default hidden route color"
-- L["Change default route color"] = "Change default route color"
-- L["Change direction"] = "Change direction"
-- L["Change direction (Carto)"] = "Change direction (Carto)"
-- L["Change direction (TomTom)"] = "Change direction (TomTom)"
-- L["Change the direction of the nodes in the route being added as the next waypoint"] = "Change the direction of the nodes in the route being added as the next waypoint"
-- L["Change the line color"] = "Change the line color"
-- L["Cluster"] = "Cluster"
-- L["CLUSTER_DESC"] = "Clustering a route makes Routes take all the nodes that are near each other and combine then into a single node as a travel point. This process takes a while, but is reasonably fast."
-- L["Cluster Radius"] = "Cluster Radius"
-- L["CLUSTER_RADIUS_DESC"] = "The maximum distance a node will be away from its cluster node point. The default is 60 yards because the detection radius of tracking skills is 80 yards."
-- L["Cluster this route"] = "Cluster this route"
-- L["Color of lines"] = "Color of lines"
-- L["Create Bare Route"] = "Create Bare Route"
-- L["CREATE_BARE_ROUTE_DESC"] = "This will create a route with just 3 initial points in it, and does not use any data from any source. You may then manually edit this route to insert and move nodes."
-- L["Create Route"] = "Create Route"
-- L["Create Route from Data Sources"] = "Create Route from Data Sources"
--[==[ L["CREATE_ROUTE_TEXT"] = [=[
Creating a route has 4 simple steps. First, navigate to the |cffffff78Add|r section on the left side.

|cffffff781.|r Type in a name for the route and press |cffffff78ENTER|r or click the |cffffff78OK|r button.

|cffffff782.|r Select a zone to create the route in.

|cffffff783.|r Select the sources of data.

|cffffff784.|r Select the type of data you wish to use in your route.


|cffffd200Notes:|r

* It is important to press the |cffffff78ENTER|r or click the |cffffff78OK|r button when entering the route name, otherwise the name will not be saved.

* If the route creation is successful, you will see pink lines running all over your world map in the selected zone. A route entry will be created on the left side under Routes for each route. This initial route is unoptimized and will need optimization.
]=] ]==]
-- L["Create Taboo"] = "Create Taboo"
--[==[ L["CREATE_TABOOS_TEXT"] = [=[
|cffffff78Taboo regions|r are areas (2D polygons) on the World Map that you can define easily to tell Routes to ignore. When such areas are defined, Routes will actively ignore any nodes that lie in these areas, and take extra effort such that the generated route does not cross these areas. This is very useful for marking places that are out of the way such as floating islands, caves, tall mountains, enemy towns and so on.

Taboo regions are created using the following steps:

|cffffff781.|r Navigate to the |cffffff78Taboos|r root tree on the left of the configuration screen.

|cffffff782.|r Type in a name for the taboo region and press |cffffff78ENTER|r or click the |cffffff78OK|r button.

|cffffff783.|r Select a zone in the dropdown to create the taboo region in.

|cffffff784.|r Click |cffffff78Create Taboo|r.

|cffffff785.|r Navigate to the newly created taboo on the left of the configuration tree in the |cffffff78Taboos|r tree.

|cffffff786.|r Click the |cffffff78Edit taboo region|r button.

|cffffff787.|r Open the World Map and navigate to the correct map where the taboo region is if necessary.

|cffffff788.|r You should see a triangular shaded region on the world map. Edit the taboo region by
a) |cffffff78Dragging|r the nodes of the polygon;
b) Inserting a node into the polygon by |cffffff78left-clicking|r an in-between node;
c) Deleting a node from the polygon by |cffffff78right-clicking|r an existing node.

|cffffff789.|r Click |cffffff78Save taboo edit|r to save your changes, or |cffffff78Cancel taboo edit|r to abandon your changes.

Taboo regions may cross over itself and overlap and contain as many nodes as you want. This means you can create very complicated and detailed taboo regions should you so desire to do so.


|cffffd200Notes:|r

* Once a taboo region is created, you may attach the taboo region to an existing route inside the individual route's configuration. You will need to reoptimize the route after attaching or removing taboo regions from a route.

* Editing a taboo region will affect all routes that use it, likewise deleting a taboo region will remove it from all routes that use it.
]=] ]==]
-- L["Creating a route"] = "Creating a route"
-- L["Creating a taboo region"] = "Creating a taboo region"
-- L["Customizing route display"] = "Customizing route display"
--[==[ L["CUSTOMIZING_ROUTE_TEXT"] = [=[
You can customize the display of your routes on the maps easily. The options comes in two parts. The |cffffff78Options|r section on the left contains global settings that apply to everything, the |cffffff78Line Settings|r options in each individual route is used to change settings to be different from the global settings.

For map drawing, you may alter which maps Routes will draw your routes on as well as the default color and width of the lines. Additionally, you may change whether the lines on the minimap should have line gaps drawn so that they do not cover the minimap yellow tracking blips and icons placed there by |cffffff78GatherMate|r/|cffffff78Cartographer|r/|cffffff78Gatherer|r/|cffffff78HandyNotes|r.

Each route can be changed to have a specific color and width in the route settings, as well as whether to hide a route from showing completely. This allows you to mark routes that you no longer wish to use, but neither wish to delete, from showing up on the maps. The |cffffff78Show hidden routes|r option in the general options can be used to override this individual route setting.

You may also opt to |cffffff78Auto show/hide|r routes based on the types of nodes that they contain, such as ore nodes or herbalism nodes, and whether such routes should show up on the maps only when you have the profession, only while you have the tracking ability active, always show, or never show. If a route contains multiple node types, the route will be shown as long as at least one of the node types satisfy the conditions to be shown.
]=] ]==]
-- L[" Data"] = " Data"
-- L["Default route"] = "Default route"
-- L["Delete"] = "Delete"
-- L["Delete node"] = "Delete node"
L["Delete Taboo"] = "Удалить запрет"
-- L["Delete this taboo region permanently. This will also remove it from all routes that use it."] = "Delete this taboo region permanently. This will also remove it from all routes that use it."
-- L["Direction changed"] = "Direction changed"
-- L["Do not draw gaps for clustered node points in routes."] = "Do not draw gaps for clustered node points in routes."
-- L["Draw line gaps"] = "Draw line gaps"
-- L["Draw on minimap when indoors"] = "Draw on minimap when indoors"
-- L["Edit route"] = "Edit route"
-- L["Edit Route Manually"] = "Edit Route Manually"
-- L["Edit taboo region"] = "Edit taboo region"
-- L["Edit this route on the world map"] = "Edit this route on the world map"
-- L["Edit this taboo region on the world map"] = "Edit this taboo region on the world map"
-- L["ExtractGas"] = "Gas"
-- L["ExtraOptDesc"] = "Turning on this option will make optimizing the route take approximately 40% longer, but will generate -slightly- better routes. Recommended setting is OFF."
-- L["Extra optimization"] = "Extra optimization"
-- L["FAQ"] = "FAQ"
--[==[ L["FAQ_TEXT"] = [=[
|cffffd200
When I try to create a route, it says no data is found. What am I doing wrong?
|r
It means exactly that: No data is found, mostly because the addon is not loaded or in standby mode. If you are using any of the |cffffff78Cartographer_<Profession>|r modules, then these modules must be loaded and active for data to be available.

Note that |cffffff78Cartographer_<Profession>|r modules are all Load on Demand addons and require |cffffff78Cartographer_Professions|r to be enabled as it is the loading stub.

|cffffd200
I made a route with Rich Adamantite Ore in it. When I find normal Adamantite Ore in the same place, GatherMate/Cartographer deletes the rich node and replaces it with a normal node. This removes the node from my route since it is contructed out of only rich nodes. What can I do?
|r
1. You can make a route with both rich and normal Adamantite Ore in it.

2. You can tell Routes not to automatically insert/delete nodes. This option is found in the root options of the Routes tree in the config screen.

|cffffd200
Can you make a progress indicator on how long a background route optimization would take?
|r
A progress bar is not possible for the optimization process as it is a non-linear algorithm. It works on a "multiple pass" basis, each pass improving on the previous pass until it reaches a point where the improvement made is too minimal and then it will stop.

This is somewhat like the |cffffff78Windows XP Disk Defragmentation|r utility, and its progress bar is worthless because its only showing you the % of each pass, but it doesn't know how many passes it will take, it could be 3 passes, it could be 10 passes, it stops only when it thinks it has done enough. This is why in the |cffffff78Vista|r version, it no longer shows you a progress bar at all.

|cffffd200
How does Routes perform its route optimization?
|r
Routes uses an algorithm called |cffffff78Ant Colony Optimization|r (ACO) which is a heuristic/probabilistic method of calculating optimal graphs based on observed real life ant behavior.

ACO algorithms have been used to produce near-optimal solutions to the |cffffff78Traveling Salesman Problem|r (TSP). For more information, consult Google or Wikipedia.

|cffffd200
What does the "Extra Optimization" option do?
|r
By default, we only used ACO along with the standard |cffffff782-opt algorithm|r to optimize routes. Turning on "extra optimization" tells Routes to also use 2.5-opt, which is a specific subset of 3-opt. 2-opt is the process where pairs of edges are exchanged (A-B and C-D becomes A-C and B-D) in order to produce shorter routes.

|cffffd200
What algorithm does node clustering use?
|r
We employ a Hierarchical Agglomerative Clustering algorithm using a greedy approach, so the output is deterministic.

|cffffd200
I created a taboo region, attached it to a route, and optimized it. My route still flies through the taboo region. Why?
|r
It is not possible to always find a route that does not fly through a taboo region or sometimes highly unfeasible to do so.

The user could potentially create taboo regions that split the map into impassable sections and regions, so the algorithm is simply biased not to pass through them if it is possible.

|cffffd200
I've found a bug! Where do I report it?
|r
You can report bugs or give suggestions at |cffffff78http://forums.wowace.com/showthread.php?t=10369|r

Alternatively, you can also find us on |cffffff78irc://irc.freenode.org/wowace|r

When reporting a bug, make sure you include the |cffffff78steps on how to reproduce the bug|r, supply any |cffffff78error messages|r with stack traces if possible, give the |cffffff78revision number|r of Routes the problem occured in and state whether you are using an |cffffff78English client or otherwise|r.

|cffffd200
Who wrote this cool addon?
|r
|cffffff78Xaros|r on EU Doomhammer Alliance & |cffffff78Xinhuan|r on US Blackrock Alliance did.
]=] ]==]
-- L["Fishing"] = "Fishing"
-- L["Foreground"] = "Foreground"
-- L["Foreground Disclaimer"] = "Generate close to optimal path for the set of nodes in this route. Please keep in mind that doing this will 'hang' your client for some time. Depending on the amount of nodes (more cause near exponential increase in time) and CPU speed you might even get a disconnect if it takes too long."
-- L["Frequently Asked Questions"] = "Frequently Asked Questions"
-- L[" Gatherer/HandyNotes currently does not support callbacks, so this is impossible for Gatherer/HandyNotes."] = " Gatherer/HandyNotes currently does not support callbacks, so this is impossible for Gatherer/HandyNotes."
-- L["GathererHERB"] = "Herbalism"
-- L["GathererMINE"] = "Mining"
-- L["GathererOPEN"] = "Treasure"
-- L["GatherMateExtract Gas"] = "Extract Gas"
-- L["GatherMateFishing"] = "Fishing"
-- L["GatherMateHerb Gathering"] = "Herbalism"
-- L["GatherMateMining"] = "Mining"
-- L["GatherMateTreasure"] = "Treasure"
-- L["Help File"] = "Help File"
-- L["Herbalism"] = "Herbalism"
-- L["Hidden route"] = "Hidden route"
-- L["Hide Route"] = "Hide Route"
-- L["Hide the route from being shown on the maps"] = "Hide the route from being shown on the maps"
-- L["Information"] = "Information"
-- L["Integrated support options for Cartographer_Waypoints"] = "Integrated support options for Cartographer_Waypoints"
-- L["Integrated support options for TomTom"] = "Integrated support options for TomTom"
-- L["Line Color"] = "Line Color"
-- L["Line gaps"] = "Line gaps"
-- L["Line Settings"] = "Line Settings"
-- L["Map Drawing"] = "Map Drawing"
-- L["Minimap"] = "Minimap"
-- L["Minimap drawing"] = "Minimap drawing"
-- L["Minimap when indoors"] = "Minimap when indoors"
-- L["Mining"] = "Mining"
-- L["Name of Route"] = "Name of Route"
-- L["Name of Taboo"] = "Name of Taboo"
-- L["Name of taboo region to add"] = "Name of taboo region to add"
-- L["Name of the route to add"] = "Name of the route to add"
-- L["Never show"] = "Never show"
-- L["No data found"] = "No data found"
-- L["No data selected for new route"] = "No data selected for new route"
-- L["No name given for new route"] = "No name given for new route"
-- L["No name given for new taboo region"] = "No name given for new taboo region"
-- L["Normal lines"] = "Normal lines"
-- L["Note"] = "Note"
-- L["Now running TSP in the background..."] = "Now running TSP in the background..."
-- L["Only while tracking"] = "Only while tracking"
-- L["Only with profession"] = "Only with profession"
-- L["Optimize Route"] = "Optimize Route"
-- L["Optimizing a route"] = "Optimizing a route"
--[==[ L["OPTIMIZING_ROUTE_TEXT"] = [=[
New routes that are created start off unoptimized and just look like a haphazard mess of lines on the map. To optimize a route, navigate to your route on the left side. On the right side, there are 4 tabs, click on |cffffff78Optimize Route|r.

Route optimization has 2 parts. The first is Route Clustering, the second is Route Optimizing.

|cffffff781.|r Click the |cffffff78Cluster|r button to cluster the route.

|cffffff782.|r Click the |cffffff78Foreground|r OR |cffffff78Background|r button and wait.


|cffffd200Notes:|r

* Route clustering is optional. What it does is it takes nodes that are near each other within a specified distance and combines them into a single travel point. Clustering a route is a reversible process, no node data is lost.

* Route optimization can be done either using foreground or the background options. Both methods are identical. The foreground method will use up all your available CPU time "hanging WoW" until it completes, while the background method does it much more slowly in the background without locking WoW.

* Generally speaking, use foreground if the number of nodes is small (less than 100), background if the number of nodes is big, otherwise you risk disconnecting from the WoW servers if optimization takes too long.

* Route generation uses an algorithm known as |cffffff78Ant Colony Optimization|r. This algorithm is based on observed real life ant behavior, and uses thousands of random numbers to simulate the ants and generate the routes.

* This means that route generation is random and optimizing the same initial route will give different results each time. You may repeatedly optimize a route in an attempt to find a better solution, Routes will not discard a shorter known solution.

* The other reason why we want the generated route to be random is because you don't want 1000 other people to have the exact same route as you right? Standard WowHead node data is downloadable fairly easily for the 3 gathering addons.

* In its current implementation in Routes, the ACO algorithm is pruned fairly heavily in order to reduce execution time. Trying to solve an NP-Complete problem in a WoW sandbox using the Lua scripting language isn't the most ideal of things to do.

* We make efforts to prevent the route from criss-crossing itself, but sometimes it happens and the algorithm doesn't catch it. If this happens, just optimize the route again.
]=] ]==]
-- L["Options"] = "Options"
-- L["Overview"] = "Overview"
--[==[ L["OVERVIEW_TEXT"] = [=[
|cffffff78Routes|r is an addon designed to make gathering things more efficient. It does this by generating efficient farming routes based on what you want to farm, and using existing data from your |cffffff78GatherMate|r, |cffffff78Cartographer_<Profs>|r or |cffffff78Gatherer|r addons. These routes are then drawn on your maps and you follow them easily and quickly.

The |cffffff78Travelling Salesman Problem|r (TSP) is a traditional problem where given N cities and the distances between any pair of cities, find the shortest tour that visits all of the cities exactly once and return to the starting city. The same problem is applied to the gathering nodes in World of Warcraft to find the shortest possible route to visit every known spawn point in a circuit.
]=] ]==]
-- L["Path with %d nodes found with length %.2f yards after %d iterations in %.2f seconds."] = "Path with %d nodes found with length %.2f yards after %d iterations in %.2f seconds."
-- L["Permanently delete a route"] = "Permanently delete a route"
-- L["Reset"] = "Reset"
-- L["Reset the line settings to defaults"] = "Reset the line settings to defaults"
-- L["Route Clustering"] = "Route Clustering"
--[==[ L["ROUTE_EDIT_DESC"] = [=[
To edit a route, click on the |cffffd200Edit|r button. The route will be drawn on the World Map. Drag the nodes to position them, left click on an in-between vertex to add nodes, right click on them to delete. After editing, you may click the |cffffd200Save|r button to save your changes, or the |cffffd200Cancel|r button to discard your changes.

Please note that you cannot edit a route when it is being optimized in the background or if the route is a clustered route.
]=] ]==]
-- L["Route Optimizing"] = "Route Optimizing"
L["routes"] = "маршруты"
-- L["Routes"] = "Routes"
-- L["Routes in %s"] = "Routes in %s"
-- L["Routes Node Menu"] = "Routes Node Menu"
-- L["Routes with Fish"] = "Routes with Fish"
-- L["Routes with Gas"] = "Routes with Gas"
-- L["Routes with Herbs"] = "Routes with Herbs"
-- L["Routes with Notes"] = "Routes with Notes"
L["Routes with Ore"] = "Маршруты сбора руды"
L["Routes with Treasure"] = "Маршруты сбора сокровищ"
L["Save route edit"] = "Сохранить изменения маршрута"
L["Save taboo edit"] = "Сохранить изменения запрета"
L["Select data to use"] = "Выберите, какие данные использовать"
L["Select data to use in the route creation"] = "Выберите, какие данные использовать для создания маршрута"
L["Select sources of data"] = "Выберите источники данных"
L["Select taboo regions to apply:"] = "Выберите области запрета для:"
L["Select Zone"] = "Выбрать зону"
L["Set the width of lines on each of the maps."] = "Установите толщину линий для всех типов карт."
L["Shorten the lines drawn on the minimap slightly so that they do not overlap the icons and minimap tracking blips."] = "Укоротите линии на миникарте так, чтобы они не перекрывали значки и точки слежения."
L["Show hidden routes"] = "Отображать скрытые маршруты"
L["Show hidden routes?"] = "Отобразить скрытые маршруты?"
L["Skill-Engineering"] = "Навык-Инженерия"
L["Skill-Fishing"] = "Навык-Рыбная ловля"
L["Skill-Herbalism"] = "Навык-Травничество"
L["Skill-Mining"] = "Навык-Горное дело"
-- L["Skip clustered node points"] = "Skip clustered node points"
-- L["%s - Node %d"] = "%s - Node %d"
-- L["Start using Cartographer_Waypoints by finding the closest visible route/node in the current zone and using that as the waypoint"] = "Start using Cartographer_Waypoints by finding the closest visible route/node in the current zone and using that as the waypoint"
-- L["Start using TomTom"] = "Start using TomTom"
-- L["Start using TomTom by finding the closest visible route/node in the current zone and using that as the waypoint"] = "Start using TomTom by finding the closest visible route/node in the current zone and using that as the waypoint"
-- L["Start using Waypoints"] = "Start using Waypoints"
-- L["Start using Waypoints (Carto)"] = "Start using Waypoints (Carto)"
-- L["Start using Waypoints (TomTom)"] = "Start using Waypoints (TomTom)"
-- L["Stop editing this route on the world map and abandon changes made"] = "Stop editing this route on the world map and abandon changes made"
-- L["Stop editing this route on the world map and save the edits"] = "Stop editing this route on the world map and save the edits"
-- L["Stop editing this taboo region on the world map and abandon changes made"] = "Stop editing this taboo region on the world map and abandon changes made"
-- L["Stop editing this taboo region on the world map and save the edits"] = "Stop editing this taboo region on the world map and save the edits"
-- L["Stop using Cartographer_Waypoints by clearing the last queued node"] = "Stop using Cartographer_Waypoints by clearing the last queued node"
-- L["Stop using TomTom"] = "Stop using TomTom"
-- L["Stop using TomTom by clearing the last queued node"] = "Stop using TomTom by clearing the last queued node"
-- L["Stop using Waypoints"] = "Stop using Waypoints"
-- L["Stop using Waypoints (Carto)"] = "Stop using Waypoints (Carto)"
-- L["Stop using Waypoints (TomTom)"] = "Stop using Waypoints (TomTom)"
-- L["TABOO_DESC"] = "Taboo regions are areas which you can define to exclude nodes. Once you have created a taboo region, you can attach the taboo region to an existing route, and all nodes inside this region will be removed and no new ones will be added to it."
-- L["TABOO_DESC2"] = "Taboo regions are areas you specify for a route to ignore. Nodes in these taboo regions are ignored and not included in a route. Additionally when optimizing a route, the generated route will attempt to avoid crossing any taboo regions if possible."
-- L["TABOO_EDIT_DESC"] = "To edit a taboo region, click on the |cffffd200Edit|r button. The taboo region will be drawn on the World Map. Drag the vertexes to position them. Right click on the vertexes to add or delete vertexes. After editing, you may click the |cffffd200Save|r button to save your changes, or the |cffffd200Cancel|r button to discard your changes."
-- L["Taboos"] = "Taboos"
-- L["Taboos in %s"] = "Taboos in %s"
-- L["The cluster radius of this route is |cffffd200%d|r yards."] = "The cluster radius of this route is |cffffd200%d|r yards."
-- L["The following error occured in the background path generation coroutine, please report to Grum or Xinhuan:"] = "The following error occured in the background path generation coroutine, please report to Grum or Xinhuan:"
-- L["There is already a TSP running in background. Wait for it to complete first."] = "There is already a TSP running in background. Wait for it to complete first."
-- L["These settings control the visibility and look of the drawn route."] = "These settings control the visibility and look of the drawn route."
-- L["This is the distance in yards away from a waypoint to consider as having reached it so that the next node in the route can be added as the waypoint"] = "This is the distance in yards away from a waypoint to consider as having reached it so that the next node in the route can be added as the waypoint"
-- L["This route contains |cffffd200%d|r nodes that have been tabooed."] = "This route contains |cffffd200%d|r nodes that have been tabooed."
-- L["This route contains the following nodes:"] = "This route contains the following nodes:"
-- L["This route has |cffffd200%d|r nodes and is |cffffd200%d|r yards long."] = "This route has |cffffd200%d|r nodes and is |cffffd200%d|r yards long."
-- L["This route has nodes that belong to the following categories:"] = "This route has nodes that belong to the following categories:"
-- L["This route has no taboo regions."] = "This route has no taboo regions."
-- L["This route has the following taboo regions:"] = "This route has the following taboo regions:"
-- L["This route is a clustered route, down from the original |cffffd200%d|r nodes."] = "This route is a clustered route, down from the original |cffffd200%d|r nodes."
-- L["This route is not a clustered route."] = "This route is not a clustered route."
--[==[ L[ [=[This section implements Cartographer_Waypoints support for Routes. Click Start to find the nearest node in a visible route in the current zone.
]=] ] = [=[This section implements Cartographer_Waypoints support for Routes. Click Start to find the nearest node in a visible route in the current zone.
]=] ]==]
--[==[ L[ [=[This section implements TomTom support for Routes. Click Start to find the nearest node in a visible route in the current zone.
]=] ] = [=[This section implements TomTom support for Routes. Click Start to find the nearest node in a visible route in the current zone.
]=] ]==]
-- L["Toggle drawing on each of the maps."] = "Toggle drawing on each of the maps."
-- L["TomTom is missing or disabled"] = "TomTom is missing or disabled"
-- L["TOO_MANY_NODES_ERROR"] = "This route has more than 724 nodes. Please reduce it by removing some nodes or by clustering otherwise memory allocation errors will occur."
-- L["Treasure"] = "Treasure"
-- L["Uncluster"] = "Uncluster"
-- L["Uncluster this route"] = "Uncluster this route"
-- L["Update distance"] = "Update distance"
-- L["Use Auto Show/Hide"] = "Use Auto Show/Hide"
-- L["Waypoint hit distance"] = "Waypoint hit distance"
-- L["Waypoints (Carto)"] = "Waypoints (Carto)"
-- L["Waypoints Integration"] = "Waypoints Integration"
--[==[ L["WAYPOINTS_INTEGRATION_TEXT"] = [=[
Routes comes with direct support for |cffffff78Cartographer_Waypoints|r or |cffffff78TomTom|r, using the waypoints system so that you can quickly travel along your routes without getting lost amidst the lines.

Using waypoints is easy. Simply go to a zone with a visible route, and click the |cffffff78Start using waypoints|r button. This tells Routes to find the closest node in the closest visible route and queues this node in |cffffff78Cartographer_Waypoints|r or |cffffff78TomTom|r. A graphical arrow then appears in the middle of the screen indicating the direction and distance to reach the waypoint.

When you reach the node, Routes will automatically queue the next node in the route and so on. Click |cffffff78Stop using waypoints|r to remove the currently queued node and |cffffff78Change directions|r to change the direction of nodes that are being queued.

To help with using waypoints, you can easily setup keybinds to start/stop and change directions in the Routes configuration screen itself or in ESC -> Key Bindings. Additionally, |cffffff78FuBar_RoutesFu|r has quick access menus for this as well.


|cffffd200Notes:|r

* The waypoint integration modules are disabled if the support addons are not found.
]=] ]==]
-- L["Waypoints (TomTom)"] = "Waypoints (TomTom)"
-- L["When the following data sources add or delete node data, update my routes automatically by inserting or removing the same node in the relevant routes."] = "When the following data sources add or delete node data, update my routes automatically by inserting or removing the same node in the relevant routes."
-- L["Width (Map)"] = "Width (Map)"
L["Width (Minimap)"] = "Ширина (мини-карта)"
L["Width of the line in the map"] = "Ширина линии на карте"
L["Width of the line in the Minimap"] = "Ширина линии на мини-карте"
L["Width of the line in the Worldmap"] = "Ширина линии на карте мира"
L["Width of the line in the Zone Map"] = "Ширина линии на карте зоны"
L["Width (Zone Map)"] = "Ширина (карта зоны)"
L["Worldmap"] = "Карта мира"
L["Worldmap drawing"] = "Отрисовка карты мира"
L["Yards to move before triggering a minimap update"] = "Метров в пути до обновления мини-карты"
L["You have |cffffd200%d|r route(s) in |cffffd200%s|r."] = "У вас |cffffd200%d|r маршрут(ов) в |cffffd200%s|r."
L["You have |cffffd200%d|r taboo region(s) in |cffffd200%s|r."] = "У вас |cffffd200%d|r запретных областей в |cffffd200%s|r."
L["You may not delete a route that is being optimized in the background."] = "Вы не можете удалить оптимизирующийся маршрут."
L["You may not delete a taboo that is being edited."] = "Вы не можете удалить редактируемый запрет."
L["Zone Map"] = "Карта зоны"
L["Zone Map drawing"] = "Отрисовка карты зоны"
L["Zone to create route in"] = "Зона для создания маршрута"
L["Zone to create taboo in"] = "Зона для создания запрета"

