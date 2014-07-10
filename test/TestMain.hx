package ;
import js.node.Fs;

import buddy.*;
using buddy.Should;

/**
 * @author AS3Boyan
 * null
 * null
 */

@:build(buddy.GenerateMain.build(["test"]))
class TestMain extends BuddySuite
{
	public function new() 
	{
		// A test suite:
        describe("Using Buddy", {
            var experience = "?";
            var mood = "?";

            // Executed before each "it":
            before({
                experience = "great";
            });

            it("should be a great testing experience", {
                experience.should.be("great");
            });

            it("should really make the tester happy", {
                mood.should.be("happy");
            });

            // Executed after each "it":
            after({
                mood = "happy";
            });
        });
	}
}