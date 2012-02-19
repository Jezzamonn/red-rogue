﻿package com.robotacid.ui.menu {
	import com.robotacid.engine.Character;
	import flash.utils.Dictionary;
	import com.robotacid.engine.Item;
	
	/**
	 * A special MenuList just for the inventory, because managing the items is quite complicated
	 * and makes quite mess on its own without having all the other game options farting around it
	 *
	 * @author Aaron Steed, robotacid.com
	 */
	public class InventoryMenuList extends MenuList{
		
		public var game:Game;
		public var menu:Menu;
		
		public var weaponsList:MenuList;
		public var armourList:MenuList;
		public var runesList:MenuList;
		public var heartsList:MenuList;
		public var equipmentList:MenuList;
		
		public var weaponActionList:MenuList;
		public var armourActionList:MenuList;
		public var runeActionList:MenuList;
		public var heartActionList:MenuList;
		public var enchantmentList:EnchantmentList;
		
		public var weaponsOption:MenuOption;
		public var armourOption:MenuOption;
		public var runesOption:MenuOption;
		public var heartsOption:MenuOption;
		public var sortOption:MenuOption;
		
		public var equipOption:ToggleMenuOption;
		public var equipMinionOption:ToggleMenuOption;
		public var equipMainOption:ToggleMenuOption;
		public var equipMinionMainOption:ToggleMenuOption;
		public var equipThrowOption:ToggleMenuOption;
		public var equipMinionThrowOption:ToggleMenuOption;
		public var dropOption:MenuOption;
		public var eatOption:MenuOption;
		public var feedMinionOption:MenuOption;
		public var enchantOption:MenuOption
		public var throwRuneOption:MenuOption;
		public var enchantmentsOption:MenuOption;
		
		public var itemToOption:Dictionary;
		public var equipmentToOption:Dictionary;
		
		public static const EQUIP:int = 0;
		public static const UNEQUIP:int = 1;
		
		public function InventoryMenuList(menu:Menu, game:Game) {
			super();
			this.menu = menu;
			this.game = game;
			
			// MENU LISTS
			
			weaponsList = new MenuList();
			armourList = new MenuList();
			runesList = new MenuList();
			heartsList = new MenuList();
			
			equipmentList = new MenuList();
			
			weaponActionList = new MenuList();
			armourActionList = new MenuList();
			runeActionList = new MenuList();
			heartActionList = new MenuList();
			enchantmentList = new EnchantmentList();
			
			// MENU OPTIONS
			
			weaponsOption = new MenuOption("weapons", weaponsList, false);
			weaponsOption.help = "The list of weapons you and your minion can equip.";
			armourOption = new MenuOption("armour", armourList, false);
			armourOption.help = "The list of armour you and your minion can equip.";
			runesOption = new MenuOption("runes", runesList, false);
			runesOption.help = "The list of runes that can be used on yourself, your minion, monsters and your equipment.";
			heartsOption = new MenuOption("hearts", heartsList, false);
			heartsOption.help = "The list of hearts you can eat to regain health.";
			sortOption = new MenuOption("sort equipment");
			sortOption.selectionStep = 1;
			sortOption.help = "sorts weapons and armour according to the highest stats. does not consider special abilities or enchantments.";
			
			enchantOption = new MenuOption("enchant", equipmentList, false);
			
			equipMainOption = new ToggleMenuOption(["equip main", "unequip main"]);
			equipMainOption.selectionStep = 2;
			equipThrowOption = new ToggleMenuOption(["equip throw", "unequip throw"]);
			equipThrowOption.selectionStep = 2;
			equipMinionMainOption = new ToggleMenuOption(["equip minion main", "unequip minion main"]);
			equipMinionMainOption.selectionStep = 2;
			equipMinionThrowOption = new ToggleMenuOption(["equip minion throw", "unequip minion throw"]);
			equipMinionThrowOption.selectionStep = 2;
			equipOption = new ToggleMenuOption(["equip", "unequip"]);
			equipOption.selectionStep = 2;
			equipMinionOption = new ToggleMenuOption(["equip minion", "unequip minion"]);
			equipMinionOption.selectionStep = 2;
			dropOption = new MenuOption("drop");
			eatOption = new MenuOption("eat");
			feedMinionOption = new MenuOption("feed minion");
			throwRuneOption = new MenuOption("throw");
			enchantmentsOption = new MenuOption("enchantments", enchantmentList);
			
			enchantmentList.pointers = new Vector.<MenuOption>();
			enchantmentList.pointers.push(enchantmentsOption);
			
			// OPTION ARRAYS
			
			options.push(weaponsOption);
			options.push(armourOption);
			options.push(runesOption);
			options.push(heartsOption);
			options.push(sortOption);
			
			weaponActionList.options.push(equipMainOption);
			weaponActionList.options.push(equipThrowOption);
			weaponActionList.options.push(equipMinionMainOption);
			weaponActionList.options.push(equipMinionThrowOption);
			weaponActionList.options.push(dropOption);
			weaponActionList.options.push(enchantmentsOption);
			
			armourActionList.options.push(equipOption);
			armourActionList.options.push(equipMinionOption);
			armourActionList.options.push(dropOption);
			armourActionList.options.push(enchantmentsOption);
			
			runeActionList.options.push(enchantOption);
			runeActionList.options.push(eatOption);
			runeActionList.options.push(throwRuneOption);
			runeActionList.options.push(feedMinionOption);
			runeActionList.options.push(dropOption);
			
			heartActionList.options.push(eatOption);
			heartActionList.options.push(feedMinionOption);
			heartActionList.options.push(dropOption);
			
			itemToOption = new Dictionary(true);
			equipmentToOption = new Dictionary(true);
		}
		
		/* Called when a new game starts */
		public function reset():void{
			weaponsList.options.length = 0;
			weaponsList.selection = 0;
			weaponsOption.active = false;
			weaponsOption.visited = true;
			armourList.options.length = 0;
			armourList.selection = 0;
			armourOption.active = false;
			armourOption.visited = true;
			runesList.options.length = 0;
			runesList.selection = 0;
			runesOption.active = false;
			runesOption.visited = true;
			heartsList.options.length = 0;
			heartsList.selection = 0;
			heartsOption.active = false;
			heartsOption.visited = true;
			equipmentList.options.length = 0;
			equipmentList.selection = 0;
			itemToOption = new Dictionary(true);
			equipmentToOption = new Dictionary(true);
			enchantOption.active = false;
		}
		
		/* Adds a new menu item and selects that item on the MenuList */
		public function addItem(item:Item, visited:Boolean = false):Item{
			var equipmentOption:MenuOptionStack, itemOption:MenuOptionStack, usageOptions:MenuList, i:int, context:String;
			
			var targetList:MenuList;
			var targetOption:MenuOption;
			if(item.type == Item.WEAPON){
				targetList = weaponsList;
				targetOption = weaponsOption;
			} else if(item.type == Item.ARMOUR){
				targetList = armourList;
				targetOption = armourOption;
			} else if(item.type == Item.RUNE){
				targetList = runesList;
				targetOption = runesOption;
			} else if(item.type == Item.HEART){
				targetList = heartsList;
				targetOption = heartsOption;
			}
			if(!visited) targetOption.visited = false;
			
			if(item.type == Item.RUNE || item.type == Item.HEART){
				// first see if this item can go into an existing stack
				var itemStack:Item;
				var optionStack:MenuOptionStack;
				for(i = 0; i < targetList.options.length; i++){
					optionStack = targetList.options[i] as MenuOptionStack;
					itemStack = optionStack.userData as Item;
					if(item.stackable(itemStack)){
						itemStack.stacked = true;
						optionStack.total++;
						
						// since the new item was copyable - it now goes into the garbage
						// collector, preserving memory
						
						menu.update();
						return itemStack;
					}
				}
			}
			
			// set up what can be done with this item
			if(item.type == Item.WEAPON){
				usageOptions = weaponActionList;
				
			} else if(item.type == Item.ARMOUR){
				usageOptions = armourActionList;
				
			} else if(item.type == Item.HEART){
				// health items should be targetable under the same context
				context = "heart";
				usageOptions = heartActionList;
				
			} else if(item.type == Item.RUNE){
				usageOptions = runeActionList;
			}
			
			itemOption = new MenuOptionStack(item.toString(), usageOptions);
			itemOption.context = context;
			itemOption.userData = item;
			itemOption.help = item.getHelpText();
			itemToOption[item] = itemOption
			
			targetList.options.push(itemOption);
			targetList.selection = targetList.options.length - 1;
			if(targetList.options.length == 1){
				targetOption.active = true;
			}
			
			// equipment needs to be targetable by runes and so gets added to the equipment list
			if(item.type == Item.ARMOUR || item.type == Item.WEAPON){
				equipmentOption = new MenuOptionStack(item.toString());
				equipmentOption.userData = item;
				equipmentOption.help = item.getHelpText() + "\npress right to enchant this item";
				equipmentList.options.push(equipmentOption);
				equipmentList.selection = equipmentList.options.length - 1;
				equipmentToOption[item] = equipmentOption;
				// make sure the enchant option is active
				enchantOption.active = true;
			}
			
			menu.update();
			return item;
		}
		
		/* Removes an item from the menu tree. Used for dropping */
		public function removeItem(item:Item):Item{
			var option:MenuOptionStack = itemToOption[item];
			
			// first see if this item is in a stack
			if(option.total > 1){
				option.total--;
				if(option.total == 1) item.stacked = false;
				return item.copy();
			}
			
			var targetList:MenuList;
			var targetOption:MenuOption;
			if(item.type == Item.WEAPON){
				targetList = weaponsList;
				targetOption = weaponsOption;
			} else if(item.type == Item.ARMOUR){
				targetList = armourList;
				targetOption = armourOption;
			} else if(item.type == Item.RUNE){
				targetList = runesList;
				targetOption = runesOption;
			} else if(item.type == Item.HEART){
				targetList = heartsList;
				targetOption = heartsOption;
			}
			
			targetList.options.splice(targetList.options.indexOf(option), 1);
			
			// a reference to this item may still exist in a hot key map - we need to neutralise it
			option.active = false;
			itemToOption[item] = null;
			
			if(item.type == Item.ARMOUR || item.type == Item.WEAPON){
				var equipmentIndex:int = equipmentList.options.indexOf(equipmentToOption[item]);
				if(equipmentIndex == equipmentList.options.length - 1) equipmentList.selection = 0;
				equipmentList.options.splice(equipmentIndex, 1);
				// a reference to this item may still exist in a hot key map - we need to neutralise it
				equipmentToOption[item].active = false;
				equipmentToOption[item] = null;
				// if there is no equipment, there is nothing to enchant
				if(equipmentList.options.length == 0){
					enchantOption.active = false;
				// don't let the equipment option point to a blank space
				} else if(equipmentList.selection >= equipmentList.options.length){
					equipmentList.selection = equipmentList.options.length - 1;
				}
			}
			// block empty lists
			if(targetList.options.length == 0){
				targetOption.active = false;
				
			// don't let the target option point to a blank space
			} else if(targetList.selection >= targetList.options.length){
				targetList.selection = targetList.options.length - 1;
			}
			
			// if this is being called from Effect.enchant and there is only one item in the enchantables list
			// menu.update() will crash the game - walking back to the trunk is necessary
			if(menu.currentMenuList == equipmentList) while(menu.previousMenuList) menu.stepLeft();
			
			menu.update();
			
			return item;
		}
		
		/* Resets the name of an option linked to this item - called when equipping items */
		public function updateItem(item:Item):void{
			itemToOption[item].name = item.toString();
			itemToOption[item].help = item.getHelpText();
			if(item.type == Item.ARMOUR || item.type == Item.WEAPON){
				equipmentToOption[item].name = item.nameToString();
				equipmentToOption[item].help = item.getHelpText() + "\nstep right to enchant this item";
			}
			menu.update();
		}
		
		/* Iterates through the runes in the inventory and identifies them */
		public function identifyRunes():void{
			var i:int, rune:Item;
			for(i = 0; i < runesList.options.length; i++){
				rune = runesList.options[i].userData as Item;
				Item.revealName(rune.name, runesList);
			}
		}
		
		/* Does a basic ordering of items based on stats */
		public function sortEquipment():void{
			weaponsList.selection = 0;
			armourList.selection = 0;
			weaponsList.options.sort(weaponSortCallback);
			armourList.options.sort(armourSortCallback);
			//var i:int;
			//trace("");
			//for(i = 0; i < weaponsList.options.length; i++){
				//trace(weaponsList.options[i].name, getWeaponValue(weaponsList.options[i].userData as Item));
			//}
			menu.update();
			game.console.print("equipment is now in order of purpose");
		}
		
		private function weaponSortCallback(a:MenuOption, b:MenuOption):Number{
			var aValue:Number = getWeaponValue(a.userData as Item);
			var bValue:Number = getWeaponValue(b.userData as Item);
			if(aValue > bValue) return -1;
			else if(aValue < bValue) return 1;
			return 0;
		}
		
		private function getWeaponValue(item:Item):Number{
			return item.damage + item.attack * 10 + item.knockback / Character.KNOCKBACK_DIST + item.stun + item.butcher + item.leech;
		}
		
		private function armourSortCallback(a:MenuOption, b:MenuOption):Number{
			var aValue:Number = getArmourValue(a.userData as Item);
			var bValue:Number = getArmourValue(b.userData as Item);
			if(aValue > bValue) return -1;
			else if(aValue < bValue) return 1;
			return 0;
		}
		
		private function getArmourValue(item:Item):Number{
			return item.defence * 10 + item.endurance + item.thorns + item.leech;
		}
	}

}