# GuildHello

GuildHello is a World of Warcraft: Forever addon that says `Hi, Name!` in guild chat ten seconds after it detects a guildmate coming online. If the roster shows them going offline during that window, it cancels the greeting. A reconnect starts a new ten-second wait. The first roster snapshot after login or `/reload` establishes who is already online.

## Install

Download the repository ZIP from **Code → Download ZIP**. Extract it into your WoW Forever client's `Interface/AddOns` directory and rename the extracted `GuildHello-main` folder to `GuildHello`. Check that `GuildHello.toc` and `GuildHello.lua` are directly inside that folder. Enable GuildHello in the character selection AddOns menu.
