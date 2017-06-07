# Stinky in here
Don't Starve mod which turns your garbage into valuable shitloads of ... yeah ... shit!

    Warning: This mod is not yet completely tested; please keep in mind, that it might crash on use. Im looking forward to change to a release stable version.

    Please test this mod and send messages, if you find any bug!

Have you ever had an ice box full of nearly spoiled food and didnt know, what to do?

Just throw it on ur new fancy compost pile and get extra poop!

This new compost pile (requested here: http://forums.kleientertainment.com/topic/30589-mod-request-compost-piles/) can turn veggies, meals, twigs, grass, seeds and lot more into poop. You dont have to run to your beefalo-plains to find poop, you can generate it by yourself!

### Features

* Rotting veggies, fruits, eggs, meals, grass, twigs, cones, flowers, mushrooms and seeds (mandrakes, too :-))
* Dropping 1-4 Poop after a few days (~1.5-10 days) with given criterias (amount of stuff, spoilage ..)
* Burnable with 0-3 ash (amount ~poopamount)
* Probability of fireflies (usual: 2%, 90% in a specific case)
* Design: ~Farm + fancy poop-flies, New UI(5 Slots)
* Tech-Category: Food (Science Machine needed)
* 6xRocks 3xPoop 4xLogs

### Future changes

* Custom minimap icon (possible?)

Special thanks to Malacath for the great support!

### Balance and Variables

#### Allowed Ingredients (Value, Shiny=0.0)

* Pome Granade, Dragon Fruit, Cave Banana, Watermelon (1)
* Berries (.5)
* Durian (1)
* Carrot, Corn, Pumpkin, Eggplant, Cut Lichen, Cactus Flesh (1)
* Red, Green, Blue Cap (.5)
* Mandrake (1, 4)
* Tallbird Egg (2)
* Egg, Bird Egg (1)
* Butterfly Wings (.5, 1) SHINY
* Twigs, Pinecone, Seeds (.25)
* Cut Grass, Rot, Evil Petals (.5)
* Petals (.5, .5) SHINY
* Butterflymuffin, Dragon Pie, Fist of Jam, Fruit Medley, Mandrake Soup, Powder Cake, Pumpkin Cookie, Ratatouille, Taffy, Unagi, Waffles, Wet Goop (1.5)
* Bacon & Eggs, Fish Tacos, Fish Sticks, Froggle Bunwich, Honey Ham, Honey Nuggets, Kabobs, Meatballs, Bone Stew, Monster Lasagna, Perogies, Turkey Dinner (1.75)

#### Recipes

* If you reach a shiny value of at least 3.0 you get 2 poop and 95% prob of fireflies spawning after harvesting. (4 days)
* If you reach a value of more than 5.0 (5.0 is not enough), you receive 3 poop and 5% probability of fireflies spawning (2.2 days).
* If you reach a value of more than 3.0 (3.0 is not enough), you receive 2 poop and 5% probability of fireflies spawning (2 days).
* Else: you receive 1 poop and 5% probability of fireflies spawning after harvesting. (3 days)

#### Bonuses

* If you compost some food which let you gain at least 4 poop (recipe+rottyness bonus (4.)), the compost pile develops fertile soil. (This is a durable status (until the pile gets burnt))
* If you have spoilable food, you receive a bonus on the composting time. Factor = 0.5 + (totalSpoilage / (2*spoiledFoodCount)). Example: 5 berries are half spoiled (50%=0.5). totalSpoilage = 5 * 0.5 = 2.5. spoiledFoodCount = 5 --> Factor = 0.5 + (2.5 / 10) = 0.75. Therefore the composttime is reduced by 25%
* If you have fertile soil (see 1.), the composttime is reduced by 10% (If your reduced composttime (2.) is 20%, the complete reduction will be 28% (0.8*0.9))
* If you compost some food which has an average spoilage of lower than 33% (this is nearly red), you receive one extra poop on harvesting. (rottyness bonus)

* The composting time bonuses can summarize to an - asymptotic - maximum of 0.5*0.9 = 0.45

#### Burnable

* If you burn the pile when it was done, you will receive the amount of poop you'd received by harvesting plus 1. (Large recipe with 3xpoop will drop 4xash)
* Piles that are empty or are rotting at the moment will not drop ash.
