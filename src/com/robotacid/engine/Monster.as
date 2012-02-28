﻿package com.robotacid.engine {
	import com.robotacid.ai.Brain;
	import com.robotacid.phys.Collider;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	/**
	 * This is the basic template for all monsters in the game.
	 *
	 * Differences between them are determined by the reaction of code in the
	 * Brain and Character classes to the monster's "name" variable
	 *
	 * @author Aaron Steed, robotacid.com
	 */
	public class Monster extends Character{
		
		public var mapInitialised:Boolean;
		
		// Heart items are this game's equivalent of health potions
		// they are harvested randomly during a kill
		// more likely is it that a bare handed player will pluck a heart
		public static const BUTCHER_CHANCE:Number = 0.1;
		public static const BARE_HANDED_BUTCHER_BONUS:Number = 0.15;
		
		public function Monster(gfx:DisplayObject, x:Number, y:Number, name:int, level:int, items:Vector.<Item>){
			super(gfx, x, y, name, MONSTER, level, false);
			
			// we do want monsters on the Entities list, but not just yet
			addToEntities = true;
			
			missileIgnore |= Collider.MONSTER | Collider.MONSTER_MISSILE;
			
			brain = new Brain(this, Brain.MONSTER);
			
			// monsters carrying loot should equip themselves, however
			// we reach this code before the map has finished initialising
			// which crashes effects like "light", so we wait until the MapTileManager
			// activates the monster for the first time
			mapInitialised = false;
			
			if(items) loot = items;
		}
		
		/* Called when the MapTileManager activates this monster for the first time */
		public function mapInit():void{
			if(loot){
				var item:Item;
				for(var i:int = 0; i < loot.length; i++){
					item = loot[i];
					if((!weapon && item.type == Item.WEAPON) || (!armour && item.type == Item.ARMOUR)){
						equip(item);
					} else if(!throwable && item.type == Item.WEAPON && (item.range & Item.THROWN)){
						equip(item, true);
					}
					if(weapon && armour && throwable) break;
				}
			}
		}
		
		override public function createCollider(x:Number, y:Number, properties:int, ignoreProperties:int, state:int = 0, positionByBase:Boolean = true):void {
			super.createCollider(x, y, properties, ignoreProperties, state, positionByBase);
			collider.properties |= Collider.MONSTER;
			collider.ignoreProperties |= Collider.MONSTER_MISSILE;
			collider.stompProperties = Collider.PLAYER | Collider.MINION;
		}
		
		override public function main():void {
			// offscreen check
			if(!game.mapTileManager.intersects(collider, SCALE * 2)){
				remove();
				return;
			}
			tileCenter = (mapX + 0.5) * SCALE;
			if(state == WALKING) brain.main();
			super.main();
		}
		
		override public function applyDamage(n:Number, source:String, knockback:Number = 0, critical:Boolean = false, aggressor:Character = null, defaultSound:Boolean = true):void {
			super.applyDamage(n, source, knockback, critical, aggressor, defaultSound);
			// poison effects on multiple characters could cause the bar to flicker between victims,
			// so we focus on the last person who was attacked physically
			if(active && this == game.player.victim){
				game.enemyHealthBar.setValue(health, totalHealth);
				game.enemyHealthBar.activate();
			}
		}
		
		override public function death(cause:String = "crushing", decapitation:Boolean = false, aggressor:Character = null):void {
			if(!active) return;
			for(var i:int = 0; i < loot.length; i++){
				if(loot[i].location == Item.EQUIPPED){
					unequip(loot[i]);
				}
				loot[i].dropToMap(mapX, mapY);
			}
			loot = new Vector.<Item>();
			super.death(cause, decapitation);
			game.enemyHealthBar.deactivate();
			
			// determine if the player manages to pluck out the monster's heart
			if(aggressor == game.player){
				var surgeryChance:Number = BUTCHER_CHANCE + (aggressor.weapon == null ? BARE_HANDED_BUTCHER_BONUS : aggressor.weapon.butcher);
				if(game.random.value() < surgeryChance){
					var heartMc:Sprite = new HeartMC();
					var heart:Item = new Item(heartMc, name, Item.HEART, 0);
					heart.collect(game.player, false);
					var victimName:String = Character.stats["names"][name];
					game.console.print("rogue tore out a" + ((victimName.charAt(0).search(/[aeiou]/i) == 0) ? "n " : " ") + heart.nameToString());
				}
			}
			
			Brain.monsterCharacters.splice(Brain.monsterCharacters.indexOf(this), 1);
			if(--game.map.completionCount == 0) game.levelCompleteMsg();
		}
		
		override public function remove():void {
			Brain.monsterCharacters.splice(Brain.monsterCharacters.indexOf(this), 1);
			super.remove();
		}
		
		override public function toXML():XML {
			var xml:XML = super.toXML();
			if(loot.length){
				for(var i:int = 0; i < loot.length; i++){
					xml.appendChild(loot[i].toXML());
				}
			}
			return xml;
		}
		
	}
	
}