Inventory Templates
===================


About
-----

*Inventory Templates* allows players to quickly and easily import and export inventory slot filters as blueprints. Such blueprints can be easily shared, stored, and managed using the blueprint library. It is particularly useful for quickly setting-up filters on entities that do not support native blueprinting - such as cars and spidertrons.


Features
--------


### Create templates

Hold an empty blueprint while any inventory with filtering support is opened, and an export button will be shown at bottom-left of the window. Clicking on the button while holding an empty blueprint will read information about currently configured inventory filters, and export them to blueprint in the form of constant combinators (see below section on format). The export button is visible _only_ when an empty, non-library blueprint is held.


### Template format

Valid inventory blueprints contain only constant combinators, with signals specifying what item filter is applied to a slot, and eventually where the chest limits have been set (red bar).

Each constant combinator represents a single slot in the inventory filter configuration. Constant combinators are read from top to bottom and from left to right. Normally they will be laid-out in aligned rows, with each row consisting out of 10 combinators (mapping directly to the layout in inventory window).

First filter slot of a combinator is used to specify the inventory slot filter. Second filter slot of a combinator can optionally be set to red signal, indicating that the inventory slot belongs to chest limits area. Chest limits are applied only on inventories that support them.


Known issues
------------

There are no known issues at this time.


Contributions
-------------

Bugs and feature requests can be reported through discussion threads or through project's issue tracker. For general questions, please use discussion threads.

Pull requests for implementing new features and fixing encountered issues are always welcome.


Credits
-------

Creation of this mod has been inspired by [Quickbar Templates](https://mods.factorio.com/mod/QuickbarTemplates), mod which implements import and export of quickbar filters as blueprint templates.


License
-------

All code, documentation, and assets implemented as part of this mod are released under the terms of MIT license (see the accompanying `LICENSE` file), with the following exceptions:

-   [assets/backpack.svg](https://game-icons.net/1x1/delapouite/delivery-drone.html), by Delapouite, under [CC BY 3.0](http://creativecommons.org/licenses/by/3.0/), used in creation of modpack thumbnail.
-   [build.sh (factorio_development.sh)](https://code.majic.rs/majic-scripts/), by Branko Majic, under [GPLv3](https://www.gnu.org/licenses/gpl-3.0.html).
-   `graphics/icons/export-template-button.png`, which is a derivative based on Factorio game assets as provided by *Wube Software Ltd*. For details, see [Factorio Terms of Service](https://www.factorio.com/terms-of-service).
