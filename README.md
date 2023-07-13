# Lation's 24/7 Robbery
A fun & unique 24/7 robbery script for ESX & QBCore. Rob the registers, hack the computer for a security code & use that code to get access to the safe for even more money. There is global cooldowns that restrict players from chain-robbing. If you fail hacking the computer too many times (configurable) you will fail the robbery and have to start over. If you try unlocking the safe unsuccessfully too many times (configurable) you will fail the robbery and have to start over. Every robbery will generate a new & unique "PIN" to unlock the safe. Furthermore, there is a small chance you can get lucky & find a note under the register that gives you the safe's PIN and allows you to skip hacking the computer at all! This chance is configurable. 

## Support & More
[Click here to join our Discord](https://discord.gg/9EbY4nM5uu)

## Features
- Supports ESX & QBCore
- Highly detailed config file
- Preconfigured for default 24/7 (if you use Gabz, the coords are in the gabz247coords.lua file)
- Customize payouts to player
- Enable/disable requiring a police presence in the city
- Configurable individual cooldowns for registers & safes
- Configurable max attempts at hacking and/or unlocking the safe
- Customizable computer hack minigame (skillcheck or questionnaire)
- If using questionnaire hack, ability to fully customize each question & answer

## Dependencies
- [ox_lib](https://github.com/overextended/ox_lib/releases)
- [ox_target](https://github.com/overextended/ox_target/releases), [qb-target](https://github.com/qbcore-framework/qb-target) or [qtarget](https://github.com/overextended/ox_target/releases)

## Installation
- Ensure you have all dependencies installed
- Add lation_247robbery to your 'resources' directory
- Add 'ensure lation_247robbery' in your 'server.cgf'

## Preview
[Streamable - Lation's 24/7 Robbery](https://streamable.com/xaaave)
