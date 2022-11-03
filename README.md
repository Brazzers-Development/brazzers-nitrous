![Brazzers Development Discord](https://i.imgur.com/nXhPxIO.png)

<details>
    <summary><b>Important Links</b></summary>
        <p>
            <a href="https://discord.gg/J7EH9f9Bp3">
                <img alt="GitHub" src="https://logos-download.com/wp-content/uploads/2021/01/Discord_Logo_full.png"
                width="150" height="55">
            </a>
        </p>
        <p>
            <a href="https://ko-fi.com/mannyonbrazzers">
                <img alt="GitHub" src="https://uploads-ssl.webflow.com/5c14e387dab576fe667689cf/61e11149b3af2ee970bb8ead_Ko-fi_logo.png"
                width="150" height="55">
            </a>
        </p>
</details>

# Installation steps

## General Setup
Advanced and unique nitrous system featuring flowrate, purge mode, and more all working on the synced version of qb-tunerchip's nitrous system. This script only includes the nitrous portion of the tunerchip script and not the tunerchip itself. The list of full features are down below

Preview: https://youtu.be/-cWlexmU0x8

## Installation Default QBCore Garages
If you're to lazy to do this, I included the drag and drop of qb-inventory server.lua in the files lazy fuck

Locate your QBCore.Commands.Add("giveitem" command in your qb-inventory > main.lua and add the itemData snippet to it: 
```lua
	elseif itemData["name"] == "nitrous" then
		info.status = "Filled"
```
Locate FormatItemInfo function in your qb-inventory > html > js > app.js file and add the itemData snippet below:
```js
    else if (itemData.name == "nitrous") {
        $(".item-info-title").html("<p>" + itemData.label + "</p>");
        $(".item-info-description").html(
            "<p>" + itemData.info.status + " nitrous bottle</p>"
        );
    }
```

## Credits
QBCore - Original maker of the nitrous system. I just cleaned it up and added a ton of features (https://github.com/qbcore-framework/qb-tunerchip)
13Stewartc - Blue/ Purple Backfire (https://www.gta5-mods.com/misc/purple-blue-flames-replace-sp-fivem)

## Features
1. Flowrate System - Allowing players to cycle nitrous/ purge flow rate effecting consumption, boost, and more!
2. Ability To Increase & Decrease Flowrate On the Spot With A Keybind
3. Ability To Refill Nitrous Bottles When Empty
4. Fully Synced Nitrous & Purge System ( Syncing The Flow Rate Too )
5. Fully Open Sourced ( No Encryption )
6. Multi-Language Support using QBCore Locales
7. 24/7 Support in discord

## Dependencies
1. qb-target
2. qb-inventory