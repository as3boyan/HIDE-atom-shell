package about;
import watchers.LocaleWatcher;
import watchers.SettingsWatcher;
import haxe.Timer;
import js.Browser;
import js.html.DivElement;
import js.html.Element;
import js.html.KeyboardEvent;
import js.html.ParagraphElement;
import js.html.AnchorElement;
import js.Lib;
import nodejs.webkit.BrowserWindow;

/**
 * ...
 * @author AS3Boyan
 */
class Presentation
{
	static var impressDiv:DivElement;
	static var slidesCount:Int;
	static var autoplay:Bool = true;
	static private var timer:Timer;

	public static function main()
	{		
		Browser.window.onload = function (e):Void
		{
			SettingsWatcher.load();
			
			impressDiv = Browser.document.createDivElement();
			impressDiv.id = "impress";
		
			var start:DivElement = Browser.document.createDivElement();
			start.id = "start";
			start.className = "step";
			start.setAttribute('data-transition-duration', "1000");
			impressDiv.appendChild(start);
			
			var p:ParagraphElement = Browser.document.createParagraphElement();
			p.style.width = "1000px";
			p.style.fontSize = "80px";
			p.style.textAlign = "center";
			p.setAttribute("localeString", "HIDE - cross platform extensible IDE for Haxe");
			p.textContent = LocaleWatcher.getStringSync("HIDE - cross platform extensible IDE for Haxe");
			start.appendChild(p);
						
			slidesCount = 1;

			var slide:DivElement;

			slide = createSlide(LocaleWatcher.getStringSync("'Feature request' perk backer and project sponsor"));
			slide = createSlide("Haxe Foundation ", "http://haxe-foundation.org/", "haxe-foundation.org", "120px");
			slide = createSlide(LocaleWatcher.getStringSync("'Link to your website' perk backers"));
			slide = createSlide("FlashDevelop", "http://www.flashdevelop.org/", "www.flashdevelop.org", "100px");
			slide = createSlide("OpenFL", "http://www.openfl.org/", "www.openfl.org", "100px");
			slide = createSlide("Hypersurge", "http://hypersurge.com/", "hypersurge.com", "100px");
			slide = createSlide("Adrian Cowan", "http://blog.othrayte.net/", "blog.othrayte.net", "100px");
			slide = createSlide("Justin Donaldson", "http://scwn.net/", "scwn.net", "100px");
			slide = createSlide("Jonas Malaco Filho", null, null, "100px");
			slide = createSlide("tommy62", null, null, "100px");
			slide = createSlide(LocaleWatcher.getStringSync("'Contributor' perk backers"));
			
			var contributors:Array<String> = [
			"Allan Dowdeswell",
			"Samuel Batista",
			"JongChan Choi",
			"Patric Vormstein",
			"Harry.french",
			"Vincent Blanchet",
			"zaynyatyi",
			"qzix13",
			"free24speed",
			"franco.ponticelli",
			"william.shakour",
			"frabbit",
			"Nick Holder",
			"fintanboyle",
			"Katsuomi Kobayashi",
			"grigoruk",
			"jessetalavera",
			"bradparks",
			"pchertok",
			"Masahiro Wakame",
			"Stojan Ilic",
			"Renaud Bardet",
			"Filip Loster",
			"MatejTyc",
			"Tiago Ling Alexandre",
			"Skial Bainn",
			"lars.doucet",
			"Ido Yehieli",
			"Ronan Sandford",
			"brutfood",
			"Matan Uberstein",
			"rcarcasses",
			"vic.cvc",
			"Richard Lovejoy",
			"Tarwin Stroh-Spijer",
			"obutovich",
			"erik.escoffier",
			"Robert Wahler",
			"Louis Tovar",
			"L Pope",
			"Florian Landerl",
			"shohei 909",
			"Andy Li",
			"dionjw",
			"Aaron Spjut",
			"sebpatu",
			"brycedneal",
			"Sam Twidale",
			"Phillip Louderback",
			"Mario Vormstein",
			"deepnight",
			"Daniel Freeman",
			];
			
			while (contributors.length > 0)
			{
				slide = createSlide(contributors.splice(Std.random(contributors.length), 1)[0]);
			}
			
			slide = createSlide(LocaleWatcher.getStringSync("Also there is anonymous contributors, people who helped us to spread the word and people who helped us through pull requests, bug reports and feature requests and by giving feedbacks"));
			slide = createSlide(LocaleWatcher.getStringSync("Without your help, this would not have been possible to make it"));			
			slide = createSlide(LocaleWatcher.getStringSync("Thanks for your support!"));
			slide = createSlide(LocaleWatcher.getStringSync("(in case if you want to change website or name, just let me know - AS3Boyan)"));

			Browser.document.body.appendChild(impressDiv);
			
			runImpressJS();
			
			var window = BrowserWindow.getAllWindows()[0];;
			window.on("close", function (e)
			{
				window.close(true);
			}
			);
		};
	}
	
	private static function createSlide(text:String, ?url:String, ?linkText:String, ?_fontSize:String = "80px"):DivElement
	{
		slidesCount++;

		var slide:DivElement = Browser.document.createDivElement();
		slide.id = "slide" + Std.string(slidesCount);
		slide.className = "step";
		
		slide.setAttribute("data-rotate", Std.string(Std.random(360)));
		slide.setAttribute("data-scale", Std.string(Math.random() * 25 + 1));
		slide.setAttribute("data-x", Std.string( Math.random() * 100000));
		slide.setAttribute("data-y", Std.string( Math.random() * 100000));
		slide.setAttribute("data-z", Std.string( -Math.random() * 3000));
		slide.setAttribute("data-rotate-x", Std.string(Std.random(360)));
		slide.setAttribute("data-rotate-y", Std.string(Std.random(360)));
		
		var p:ParagraphElement = Browser.document.createParagraphElement();
		p.style.width = "1000px";
		p.style.fontSize = _fontSize;
		p.innerText = text;
		slide.appendChild(p);

		if (url != null)
		{
			p = Browser.document.createParagraphElement();
			p.className = "footnote";
			p.innerText = LocaleWatcher.getStringSync("Website: ");
			p.setAttribute("localeString", "Website: ");
			p.style.fontSize = "24px";
			slide.appendChild(p);

			var a:AnchorElement = Browser.document.createAnchorElement();
			a.href = url;
			a.innerText = linkText;
			a.target = "_blank";
			p.appendChild(a);
		}

		impressDiv.appendChild(slide);
		return slide;
	}

	private static function runImpressJS():Void
	{		
		var impressInstance:Dynamic = untyped impress();
		impressInstance.init();
		
		//Impress.js autoplay
		//ported to Haxe from
		//http://stackoverflow.com/questions/11694069/how-to-make-impress-js-slideshow-auto-play-and-loop
		Browser.document.addEventListener('impress:stepenter', function (e):Void
		{			
			if (autoplay)
			{
				var duration:Int = (e.target.getAttribute('data-transition-duration') != null ? e.target.getAttribute('data-transition-duration') : 2500 + Std.random(1500)); // use the set duration or fallback to 2000ms
			
				Timer.delay(function () 
				{
					if (autoplay)
					{
						untyped impressInstance.next(); 
					}
				}
				, duration);
			}
		});
		
		Browser.document.addEventListener("keyup", function (e:KeyboardEvent)
		{
			autoplay = false;
			
			if (timer != null)
			{
				timer.stop();
				timer = null;
			}
			
			timer = new Timer(15000);
			
			timer.run = function ()
			{
				autoplay = true;
				untyped impressInstance.next(); 
				timer.stop();
				timer = null;
			};
		}
		);
	}
}