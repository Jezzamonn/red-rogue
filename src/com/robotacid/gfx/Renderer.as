﻿package com.robotacid.gfx {	import com.robotacid.dungeon.Content;	import com.robotacid.dungeon.Map;	import com.robotacid.engine.Effect;	import com.robotacid.engine.Entity;	import com.robotacid.engine.Item;	import com.robotacid.engine.MapTileConverter;	import com.robotacid.ui.MinimapFeature;	import flash.display.Bitmap;	import flash.display.BitmapData;	import flash.display.BlendMode;	import flash.display.Graphics;	import flash.display.MovieClip;	import flash.display.Shape;	import flash.display.Sprite;	import flash.display.Stage;	import flash.events.Event;	import flash.filters.ColorMatrixFilter;	import flash.geom.Matrix;	import flash.geom.Point;	import flash.geom.Rectangle;	import flash.utils.getDefinitionByName;		/**	 * Manages all graphics rendering	 *	 * @author Aaron Steed, robotacid.com	 */	public class Renderer{				public var g:Game;		public var camera:CanvasCamera;		public var sceneManager:SceneManager;				// gfx holders		public var canvas:Sprite;		public var lightningShape:Shape		public var bitmapData:BitmapData;		public var bitmap:Bitmap;		public var lightBitmap:Bitmap;		public var backgroundShape:Shape;		public var backgroundBitmapData:BitmapData;		public var blockBitmapData:BitmapData;		public var blockRect:Rectangle;				// blits		public var sparkBlit:BlitRect;		public var twinkleBlit:BlitClip;		public var teleportSparkBigFadeBlit:FadingBlitRect;		public var teleportSparkSmallFadeBlit:FadingBlitRect;		public var stunBlit:BlitClip;		public var novaBlit:BlitClip;				public var smallDebrisBlits:Vector.<BlitRect>;		public var bigDebrisBlits:Vector.<BlitRect>;		public var smallFadeBlits:Vector.<FadingBlitRect>;		public var bigFadeBlits:Vector.<FadingBlitRect>;		public var stairsUpFeatureBlit:BlitClip;		public var stairsDownFeatureBlit:BlitClip;		public var portalFeatureBlit:BlitClip;		public var searchFeatureBlit:BlitClip;		public var featureRevealedBlit:BlitClip;		public var minionFeatureBlit:BlitClip;				public var backgroundBitmaps:Vector.<Bitmap>;				// self maintaining animations		public var fx:Vector.<FX>;		public var fxSpawn:Vector.<FX>; // fx generated during the filter callback must be added to a waiting list		public var fxFilterCallBack:Function;				// states		public var shakeOffset:Point;		public var shakeDirX:int;		public var shakeDirY:int;		public var fireBallAngle:int;		public var lockFrame:int;				// temp variables		private var i:int;				public static var point:Point = new Point();		public static var matrix:Matrix = new Matrix();				// measurements from Game.as		public static const SCALE:Number = Game.SCALE;		public static const INV_SCALE:Number = Game.INV_SCALE;		public static const WIDTH:Number = Game.WIDTH;		public static const HEIGHT:Number = Game.HEIGHT;				// debris types		public static const BLOOD:int = 0;		public static const BONE:int = 1;		public static const STONE:int = 2;				public function Renderer(g:Game){			this.g = g;		}				/* Initialisation is separated from the constructor to allow reference paths to be complete before all		 * of the graphics are generated - an object is null until its constructor has been exited */		public function init():void{						Entity.renderer = this;			LightMap.renderer = this;			Effect.renderer = this;			FX.renderer = this;			Map.renderer = this;			Content.renderer = this;			ItemMovieClip.renderer = this;			SceneManager.renderer = this;						ItemMovieClip.init();						// init debris particles			smallDebrisBlits = Vector.<BlitRect>([				new BlitRect(0, 0, 1, 1, 0xffAA0000),				new BlitRect(0, 0, 1, 1, 0xffffffff),				new BlitRect(0, 0, 1, 1, 0xff000000)			]);			bigDebrisBlits = Vector.<BlitRect>([				new BlitRect(-1, -1, 2, 2, 0xffAA0000),				new BlitRect(-1, -1, 2, 2, 0xFFFFFFFF),				new BlitRect( -1, -1, 2, 2, 0xff000000)			]);			smallFadeBlits = Vector.<FadingBlitRect>([				new FadingBlitRect(0, 0, 1, 1, 30, 0xffAA0000),				new FadingBlitRect(0, 0, 1, 1, 30, 0xffffffff),				new FadingBlitRect(0, 0, 1, 1, 30, 0xff000000)			]);			bigFadeBlits = Vector.<FadingBlitRect>([				new FadingBlitRect( -1, -1, 2, 2, 30, 0xffAA0000),				new FadingBlitRect( -1, -1, 2, 2, 30, 0xffffffff),				new FadingBlitRect( -1, -1, 2, 2, 30, 0xff000000)			]);			stairsUpFeatureBlit = new BlitClip(new StairsUpFeatureMC);			stairsDownFeatureBlit = new BlitClip(new StairsDownFeatureMC);			portalFeatureBlit = new BlitClip(new PortalFeatureMC);			searchFeatureBlit = new BlitClip(new SearchFeatureMC);			featureRevealedBlit = new BlitClip(new FeatureRevealedMC);			MinimapFeature.revealBlit = featureRevealedBlit;			minionFeatureBlit = new BlitClip();			minionFeatureBlit.totalFrames = 1;			minionFeatureBlit.data = new BitmapData(3, 3, true, 0x00000000);			minionFeatureBlit.frames = Vector.<BitmapData>([minionFeatureBlit.data]);			minionFeatureBlit.rect = minionFeatureBlit.data.rect;			minionFeatureBlit.dx = minionFeatureBlit.dy = -1;			minionFeatureBlit.width = minionFeatureBlit.height = 3;			minionFeatureBlit.data.setPixel32(1, 0, 0xCCFFFFFF);			minionFeatureBlit.data.setPixel32(0, 1, 0xCCFFFFFF);			minionFeatureBlit.data.setPixel32(2, 1, 0xCCFFFFFF);			minionFeatureBlit.data.setPixel32(1, 2, 0xCCFFFFFF);									backgroundBitmaps = Vector.<Bitmap>([				new g.library.BackB1,				new g.library.BackB2,				new g.library.BackB3,				new g.library.BackB4			]);						sparkBlit = smallDebrisBlits[BONE];			teleportSparkSmallFadeBlit = smallFadeBlits[BONE];			teleportSparkBigFadeBlit = bigFadeBlits[BONE];						twinkleBlit = new BlitClip(new TwinkleMC);			stunBlit = new BlitClip(new StunMC);			novaBlit = new BlitClip(new NovaMC);						blockRect = new Rectangle(0, 0, Game.WIDTH, Game.HEIGHT - Game.CONSOLE_HEIGHT);						fxFilterCallBack = function(item:FX, index:int, list:Vector.<FX>):Boolean{				item.main();				return item.active;			};		}				/* Prepares sprites and bitmaps for a game session */		public function createRenderLayers(holder:Sprite = null):void{						if(!holder) holder = g;						canvas = new Sprite();			holder.addChild(canvas);						backgroundShape = new Shape();			backgroundBitmapData = new BitmapData(1, 1, true, 0x00000000);						bitmapData = new BitmapData(WIDTH, HEIGHT, true, 0x00000000);			bitmap = new Bitmap(bitmapData);						var debugShape:Shape = new Shape();			Game.debug = debugShape.graphics;			var debugStayShape:Shape = new Shape();			Game.debugStay = debugStayShape.graphics;			Game.debugStay.lineStyle(2, 0xFF0000);						lightningShape = new Shape();			lightBitmap = new Bitmap(new BitmapData(1, 1, true, 0x00000000));			lightBitmap.scaleX = lightBitmap.scaleY = Game.SCALE;						//lightBitmap.visible = false;						canvas.addChild(backgroundShape);			canvas.addChild(bitmap);			canvas.addChild(lightningShape);			canvas.addChild(lightBitmap);			canvas.addChild(debugShape);			canvas.addChild(debugStayShape);						fx = new Vector.<FX>();			fxSpawn = new Vector.<FX>();						camera = new CanvasCamera(canvas, this);						shakeOffset = new Point();			shakeDirX = 0;			shakeDirY = 0;			fireBallAngle = 0;			lockFrame = 0;		}				/* Tries to free memory by orphaning the graphics layers - this in theory should give the		 * garbage collector a kick up the bum - I gather this seems overkill, but Flash's garbage		 * collector is actually notoriously ropey, and this is a static object which I don't want		 * to reinitialise because of all the blitting objects. So ner. */		public function clearAll():void{			while(canvas.numChildren > 0){				canvas.removeChildAt(0);			}			bitmap = null;			bitmapData.dispose();			bitmapData = null;			fx = null;			g = null;		}				/* Updates all of the rendering */		public function main():void {						updateShaker();						if(g.player.collider){				camera.setTarget(					g.player.collider.x + g.player.collider.width * 0.5 + g.player.cameraDisplacement.x,					g.player.collider.y + g.player.collider.height * 0.5 + g.player.cameraDisplacement.y				);			}						camera.main();						// clear bitmapDatas			bitmapData.fillRect(bitmapData.rect, 0x00000000);			bitmap.x = -canvas.x;			bitmap.y = -canvas.y;						// black border around small levels			if(canvas.x > camera.mapRect.x){				bitmapData.fillRect(new Rectangle(0, 0, canvas.x, Game.HEIGHT - Game.CONSOLE_HEIGHT), 0xFF000000);			}			if(canvas.x + camera.mapRect.x + camera.mapRect.width < Game.WIDTH){				bitmapData.fillRect(new Rectangle(canvas.x + camera.mapRect.x + camera.mapRect.width, 0, Game.WIDTH - (canvas.x + camera.mapRect.x + camera.mapRect.width), Game.HEIGHT - Game.CONSOLE_HEIGHT), 0xFF000000);			}			if(canvas.y > 0){				bitmapData.fillRect(new Rectangle(0, 0, Game.WIDTH, canvas.y), 0xFF000000);			}			if(canvas.y + camera.mapRect.height < Game.HEIGHT - Game.CONSOLE_HEIGHT){				bitmapData.fillRect(new Rectangle(0, canvas.y + camera.mapRect.height, Game.WIDTH, (Game.HEIGHT - Game.CONSOLE_HEIGHT) - (canvas.y + camera.mapRect.height)), 0xFF000000);			}						// render parallax layer			backgroundShape.x = -canvas.x;			backgroundShape.y = -canvas.y;			backgroundShape.graphics.clear();			matrix.identity();			matrix.tx = canvas.x;			matrix.ty = canvas.y;			backgroundShape.graphics.beginBitmapFill(backgroundBitmapData, matrix);			backgroundShape.graphics.drawRect(0, 0, Game.WIDTH, Game.HEIGHT - Game.CONSOLE_HEIGHT);						var entity:Entity;						for(i = 0; i < g.portals.length; i++){				entity = g.portals[i];				if(entity.gfx.visible) entity.render();			}						for(i = 0; i < g.chaosWalls.length; i++){				entity = g.chaosWalls[i];				if(entity.gfx.visible) entity.render();			}						blockRect.x = bitmap.x;			blockRect.y = bitmap.y;			point.x = point.y = 0;			bitmapData.copyPixels(blockBitmapData, blockRect, point, null, null, true);						g.mapTileManager.main();						if(g.dungeon.type != Map.OUTSIDE_AREA) g.lightMap.main();						for(i = 0; i < g.items.length; i++){				entity = g.items[i];				if(entity.gfx.visible) entity.render();			}						for(i = 0; i < g.entities.length; i++){				entity = g.entities[i];				if(entity.gfx.visible) entity.render();			}						g.player.render();						if(sceneManager) sceneManager.render();						if(fxSpawn.length){				fx = fx.concat(fxSpawn);				fxSpawn.length = 0;			}			if(fx.length) fx = fx.filter(fxFilterCallBack);					}				/* Shake the screen in any direction */		public function shake(x:int, y:int):void {			// ignore lesser shakes			if(Math.abs(x) < Math.abs(shakeOffset.x)) return;			if(Math.abs(y) < Math.abs(shakeOffset.y)) return;			shakeOffset.x = x;			shakeOffset.y = y;			shakeDirX = x > 0 ? 1 : -1;			shakeDirY = y > 0 ? 1 : -1;		}				/* resolve the shake */		private function updateShaker():void {			// shake first			if(shakeOffset.y != 0){				shakeOffset.y = -shakeOffset.y;				if(shakeDirY == 1 && shakeOffset.y > 0) shakeOffset.y--;				if(shakeDirY == -1 && shakeOffset.y < 0) shakeOffset.y++;			}			if(shakeOffset.x != 0){				shakeOffset.x = -shakeOffset.x;				if(shakeDirX == 1 && shakeOffset.x > 0) shakeOffset.x--;				if(shakeDirX == -1 && shakeOffset.x < 0) shakeOffset.x++;			}		}				/* Add to list */		public function addFX(x:Number, y:Number, blit:BlitRect, dir:Point = null, delay:int = 0, spawn:Boolean = false):FX{			var item:FX = new FX(x, y, blit, bitmapData, bitmap, dir, delay);			if(spawn) fxSpawn.push(item);			else fx.push(item);			return item;		}		/* Add to list */		public function addDebris(x:Number, y:Number, blit:BlitRect, vx:Number = 0, vy:Number = 0, print:BlitRect = null, smear:Boolean = false, spawn:Boolean = false):DebrisFX{			var item:DebrisFX;			item = new DebrisFX(x, y, blit, bitmapData, bitmap, print, smear);			item.addVelocity(vx, vy);			if(spawn) fx.push(item);			else fxSpawn.push(item);			return item;		}				/* Fill a rect with fading teleport sparks that drift upwards */		public function createTeleportSparkRect(rect:Rectangle, quantity:int):void{			var x:Number, y:Number, spark:FadingBlitRect, item:FX;			for(var i:int = 0; i < quantity; i++){				x = rect.x + g.random.range(rect.width);				y = rect.y + g.random.range(rect.height);				spark = g.random.value() < 0.5 ? teleportSparkSmallFadeBlit : teleportSparkBigFadeBlit;				item = addFX(x, y, spark, new Point(0, -g.random.value()));				item.frame = g.random.range(spark.totalFrames);			}		}		/* Fill a rect with particles and let them fly */		public function createDebrisRect(rect:Rectangle, vx:Number, quantity:int, type:int):void{			var x:Number, y:Number, blit:BlitRect, print:BlitRect;			for(var i:int = 0; i < quantity; i++){				x = rect.x + g.random.range(rect.width);				y = rect.y + g.random.range(rect.height);				if(g.random.value() < 0.5){					blit = smallDebrisBlits[type];					print = smallFadeBlits[type];				} else {					blit = bigDebrisBlits[type];					print = bigFadeBlits[type];				}				addDebris(x, y, blit, vx + g.random.range(vx) , -g.random.range(5.5), print, true);			}		}		/* Throw some debris particles out */		public function createDebrisSpurt(x:Number, y:Number, vx:Number, quantity:int, type:int):void{			var blit:BlitRect, print:BlitRect;			for(var i:int = 0; i < quantity; i++){				if(g.random.value() < 0.5){					blit = smallDebrisBlits[type];					print = smallFadeBlits[type];				} else {					blit = bigDebrisBlits[type];					print = bigFadeBlits[type];				}				addDebris(x, y, blit, vx + g.random.range(vx) , -g.random.range(4.5), print, true);			}		}		/* Throw some sparks out */		public function createSparks(x:Number, y:Number, dx:Number, dy:Number, quantity:int):void{			for(var i:int = 0; i < quantity; i++){				addDebris(x, y, sparkBlit,					dx + (-dy + g.random.range(dy * 2) * g.random.range(5)),					dy + ( -dx + g.random.range(dx * 2) * g.random.range(5))				);			}		}		/* Throw some fireballs out		public function createFireBalls(x:Number, y:Number, quantity:int):void{			var step:int = 360 / quantity;			while(quantity--){				fireBallAngle += step + Math.random() * step;				if(fireBallAngle >= 360) fireBallAngle -= 360;				addDebris(x, y, fireBallBlit, Trig.cos[fireBallAngle] * 5, -5 + Trig.sin[fireBallAngle] * 5, true, false, true);			}		}*/			}}