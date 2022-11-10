# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1] - 11/5/2022
- Initial launch of Forever Engine Feather.

--------------------------
11/05/22
- Added Script Support;
- Softcoded Characters with HScript;
- Psych Character Support;
- Autoplay can no longer Miss Notes;
- Receptors can now be regenerated;
- Pausing should not lag anymore;
- Icons are now stored inside the Character's *Folder*;
- Characters now have fake miss animations (if real ones couldn't be found on offsets);

--------------------------
11/05/22

- Receptors can now be manipulated (position, size, etc);
- started working on notetypes (wip);
- enabled hscriptPos for error handling on scripts;
- ghost tapping is now enabled by default;
- splashes are now recycled sprites;
- moved score related stuffs to Timings;
- added Character-specific Health Bar Colors;
- added Character-specific Noteskins and Note Splashes;
- simplified countdown code;
- UI Class is now a sprite group, meaning it can be manipulated (as in alpha, position, etc) similar to receptors;

--------------------------
11/06/22

- updated default health bar for it to match Forever 1.0's;
- Custom Game Over Variables for characters;
- Softcoded Event Notes (with hardcoding still being possible);
- Psych Engine Chart Support (for newer versions);
- Chart Editor Shortcut on Freeplay;
- Stages per Chart, rather than Hardcoded;
- on-screen error log (by superpowers04);
- Week 6 fixes;

--------------------------
11/07/22

- Fixed "Hey!" and "Play Animation" events crashing the game;
- Unhardcoded "Change Character" event;
- Added Personalization Options for Strumline and Hold Note Opacity;
- Improved Selector Options Code;
- Added "Exit to options" to the Pause Menu;
- Slightly Improved Options Menu;
- Weeks are now managed by JSONs on the assets folder (notice that weeks can still be hardcoded);
- Week Characters are now separated on their own individual images, along with having a JSON file attached for customiization;
- Difficulty Images are now separated in individual files;
- added an option to disable flashing lights;
- Title Text is now hardcoded;
- Game Logo on Titlescreen is now hardcoded;

--------------------------
11/08/22

- Scripted Stages;
- Change Stage Event;
- You can now regenerate characters by calling "regenerateCharacters()" on PlayState;
- Reorganized Source Filesystem;
- Removed a few unused imports within the Source Classes;
- Changed Default Script Extension to "hx" so haxe formatter actually works with them;

- Center Mark now shows the accurate difficulty name regardless that song has that difficulty or not;
- You won't get misses from pressing keys while the song is ending if Ghost Tapping is not enabled;
- Accuracy shouldn't go over 100%, now, additionally, there shouldn't be a percentage symbol while accuracy is at "N/A";
- Icons have infinite frames (to avoid a wall of icons blocking your vision on freeplay in case you got a third one);
- It's no longer christmas in Fresh :(

--------------------------
11/09/22

- [WORK IN PROGRESS]; Error Handling for scripts;
- [SOURCE]; a new sprite class which can be used to attach sprites to other sprites;
- Minor UI Adjustments;

--------------------------
10/11/22

- Judgement and Combo Fade Animations are now bound to time;
* additionally, they can (optionally) be recycled sprites rather than being added every note hit;
- [DOCUMENTATION]: began working on small bits of documentation which will be expanded and updated with time;
- [WORK IN PROGRESS]: Mod Managment with **Polymod!**;