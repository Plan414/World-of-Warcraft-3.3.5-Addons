# A fork of the abandoned Best In Slot AddOn.

***

## FAQ
### Q: Can I disable the window resizing/make it instant?
#### A: Go to **Options** -&gt; Animation. Check the boxes to disable or make the animations instant.

### Q: I can't find [Aman'Thul's Vision](http://www.wowhead.com/item=154172/amanthuls-vision) under trinkets!
#### A: It's not tied to any specc so you need to click "Show all items" to see it in the list.

### Q: I've encountered a bug! How can I report it?
#### A: Capture the bug with an AddOn like Swatter or BugSack and report the output to the [BestInSlotRedux GitHub](https://github.com/anhility/BestInSlotRedux/issues).

### Q: These localization's are really weird, wrong or missing.
#### A: When I took over the project so were the original translation files unfortunately lost. Please help at the project's [localization page](https://wow.curseforge.com/projects/bestinslotredux/localization).

***

# Best In Slot Redux Quick Start Guide

The intention of this page is to quickly get you started with Best In Slot Redux and its features.

## Accessing the AddOn

By default there's a mini-map button which looks like this: ![](https://i.imgur.com/UHOQkJ6.png)  
You can also access the AddOn by using the chat commands: **/bis** or **/bestinslot**. Try **/bis help** for additional commands.  
There's also support for data broker AddOns like Titan Panel or similar.

## The Manager

The **BiS Manager** is where all the magic happens. This is the place where you can set your BestInSlot lists. On startup the AddOn automatically selects the highest available raid tier and difficulty. You can make a BestInSlot list for every raid tier, for every difficulty, for every specialization.  
For instance, a hunter can have 3 specializations for Mythic Antorus, the Burning Throne: one for Beast Mastery, Marksmanship and Survival.  

The manager will show you a copy of your inventory screen and for each slot you can set a BestInSlot item. The AddOn uses the loot list of that list and checks if you're eligible for that loot in that slot. You'll get a list with items that you're eligible to roll for the selected raid tier, difficulty and specialization.    
![](https://i.imgur.com/MPMzxYN.png)

## I've setup my BiS list, what is the advantage of using this Add On?
 
First off, you can easily check what you need from an instance on a per boss basis.  
![](https://i.imgur.com/1qUe6pj.png)  
  
You can make custom BiS lists if you need more than the standard one for each specc.  
![](https://i.imgur.com/fEnm04n.png)  
  
You can export your BiS lists to WoWhead or SimCraft.  
![](https://i.imgur.com/h4DJc4M.png)

## Cool. Can this somehow help seeing who needs which item too?

Yes it can! With the **Request BiS** panel can you automatically fetch your raids, guild members or a whisper target's BiS lists and see how many people that need an item from each boss.  
![](https://i.imgur.com/ejqJPT0.png)  
  
Under **Guild BiS lists** can can see all your guild members BiS lists that you have requested.  
![](https://i.imgur.com/jdVmXbF.png)  
  
And if you have a persons BiS list so can you see that they need that item with the ingame tooltip.  
![](https://i.imgur.com/nRcNXE1.png)