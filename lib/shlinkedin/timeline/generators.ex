defmodule Shlinkedin.Timeline.Generators do
  def adversity() do
    """
    Storytime... When I was #{young_identifier()}, I lived #{poor_condition()}. We had to fight to survive — I once #{
      weird_brutal_action()
    }. #{question_quote()}

    Well, something even worse happened to me. One day, when I was #{
      blatantly_self_aggrandizing_charitable_action()
    }, a #{surprising_aggressor()} managed to #{crime()}. I was left extremely #{adjective()}.

    But I didn’t whine, or complain. I didn’t even #{reasonable_response()}.

    Instead, I asked the #{surprising_aggressor()} #{business_question()}, and offered my help in solving his business challenge. That’s when I learned to #{
      modern_business_practice()
    }. When you are faced with #adversity, you need to #{stupid_response()}. It’s the only way to learn. Thanks to my challenges, and my willingness to power through them, I am now #{
      present_title()
    }. You can do the same, too. You just have to believe. Thank you.

    #{hashtags()}.

    """
  end

  def job() do
    """
    Hi everyone,

    I'm thrilled to announce I am now #{present_title()}.

    I could never imagine going from #{adjective()} when I was #{young_identifier()} to where I am now.
    I know you're probably looking for advice, but I don't have much to offer, except for my one guiding principle: #{
      modern_business_practice()
    }.

    #{hashtags()}
    """
  end

  def young_identifier() do
    [
      "but a wee lad",
      "a little baby",
      "84",
      "5",
      "12",
      "2",
      "a spritely young lad",
      "a playful, innocent little shoe shine",
      "pretty young thing",
      "Pretty kitty",
      "CEO of being a baby",
      "a young man",
      "blossoming youth",
      "a young woman",
      "an itty bitty lil kid",
      "a boy two weeks ago",
      "a wee lass",
      "so so small",
      "tiny",
      "5 and three quarters",
      "so small that my legs didn’t touch the ground when I sat on a chair",
      "so young that I didn’t even know what business meant",
      "young and reckless",
      "young and beautiful"
    ]
    |> Enum.random()
  end

  @doc """
  Returns a random poor condition for template generator
  """
  def poor_condition() do
    [
      "in a shoe",
      "under a bridge",
      "in your basement",
      "in Northern Yorkshire, where the beer is warm and nights are cold",
      "in a dirt pit on the side of the road",
      "in an abandoned nuclear waste factory",
      "on the side of the road",
      "in a haunted house",
      "in a decrepit neo-modernist mansion barely worth $3.2 million",
      "by a Dairy Queen in Secaucus, NJ",
      "under a giant turtle",
      "in a pineapple under the sea",
      "in a dumpster by Dave & Busters",
      "next to a tire fire",
      "to dream",
      "in Transylvania",
      "in New York City, but the seedy part from crime movies",
      "Underwater",
      "in a swamp",
      "in a really small yacht. ",
      "at a prep school, where I was all-state in lacrosse",
      "under a staircase at my aunt and uncle’s place",
      "in a garbage can",
      "in the back of a moving van, just jetting from place to place",
      "right behind you",
      "in a Planet Fitness",
      "in Italy, but not the Italy you know with spaghetti and pesto as far as the eye can see. This was the mean Italy, with rigatoni and puttanesca everywhere",
      "in a beat-up tin shack",
      "in an alleyway",
      "in a blanket fort on the beach"
    ]
    |> Enum.random()
  end

  def weird_brutal_action() do
    [
      "saw two pigeons fighting over a human finger",
      "saw three pigeons fighting over a human finger",
      "saw seven salesman eat a briefcase for fun",
      "saw a megalodon shark",
      "saw a man transform into a bird and peck someone’s head really hard",
      "saw Two women braiding hair for money in a van",
      "saw Seven prep school students descend on a referee after a poor call in their lacrosse game and eat him",
      "saw two Nicolas Cage movies in one night",
      "saw an ad for ‘plastic’ and I’m still not sure what that meant",
      "saw three goblin tribes warring over an Orichalcum mine",
      "saw a CEO’s tie get stolen while he was wearing it",
      "saw a former pro-wrestler fight a parked car and win",
      "saw a grizzly bear selling salacious acts for salmon",
      "saw a salmon selling salacious acts for protection from bears",
      "saw an old man claiming to be a wizard rob a convenience store with his wand",
      "saw an old man claiming to be a wizard rob a convenience store with his “wand.”",
      "had to make my spreadsheets on a greasy old Arby’s bag",
      "had to file my taxes with my accountant (my accountant was a rabid possum)",
      "Trained a lizard to teach me algebra because my school was overrun with moths",
      "had to chug ten soylents just to get into ZBT",
      "had to tickle my way through an EDM festival just to get to the grocery store",
      "robbed a freight train like a cowboy just to get some socks",
      "captured two rabbits and wore them like ear muffs just to survive the winter",
      "saw a ghost begging for spare ectoplasm by the subway",
      "brokered a trade between two salamanders and only got a 2% cut",
      "shaved a man’s back for some bread",
      "had to take a town car to the airport because there were no ubers available",
      "had to take the subway",
      "had to eat one of those cinnamon buns that come pre-wrapped at the store",
      "had to eat “Canned Soup.”",
      "wrestled an octopus because the warlord said to",
      "smashed a jack-o-lantern just to get to that sweet, sweet orange goop",
      "fought to survive",
      "entered data for 3 hours straight just so we could get that slide deck out",
      "got a mere 5 hours of sleep because I had an espresso after dinner",
      "had to pickup my seamless order in person because of an issue with their app",
      "ate fast food",
      "had to get vaccinated for something called ‘possum madness’",
      "perform a private musical number for a sheik just for some food"
    ]
    |> Enum.random()
  end

  def question_quote() do
    [
      "“How do you manage to be so handsome with such an intense past,” you mumble?",
      "“Wow wow wow! But why tell me?”",
      "“Uhm… okay?” you wonder.",
      "“Oh my goodness! How do you know so much wisdom?” You may cry!",
      "“I don’t possibly see how this is relevant to anything!” You exclaim!",
      "So, you think I’m crazy…",
      "Ah, you must think I’m a jester, having a great big lark in the courtyard of the king.",
      "I’m sure you’re a bit confused. Anyway..",
      "Hah—I must sound like a rambler for the ages. So..",
      "“There’s no way this can have a business-related takeaway,” you say?",
      "Hah! Crazy times…. Anyhoo! ",
      "Ah, memories… So",
      "Look at me! Rambling like an old drunk! So…"
    ]
    |> Enum.random()
  end

  def blatantly_self_aggrandizing_charitable_action() do
    [
      "preparing soup for the homeless after my shift at the neurosurgery factory as a doctor",
      "massaging our brave veterans",
      "teaching orphans how to create a pivot table in Excel",
      "teaching amputee puppies how to sing",
      "carrying old people across the street",
      "dancing with the stars",
      "teaching a young Elon Musk about science",
      "sharing my cool idea for a personal computation device with my friend young Bill Gates",
      "when I was showing Jimi Hendrix some cool guitar licks he could use (one became “Purple Haze”)",
      "building fresh water wells for underserved villages in southern New Jersey",
      "planting trees in the Sahara",
      "prepared morning coffee for my sickly interns",
      "donating a million dollars (that I could barely afford) to hospitals",
      "repainting hospitals for charity",
      "donating my organs to charity",
      "inventing the internet",
      "tutoring veterans",
      "alphabetizing our brave veterans",
      "revitalizing my local infrastructure through the power of marketing",
      "doing “private” stuff",
      "teaching Jeff Bezos how to read",
      "helping small business learn how to better use Salesforce",
      "inventing penicillin ",
      "teaching entrepreneurs how to network",
      "teaching entrepreneurship to networkers",
      "juggling to entertain orphan veterans",
      "wearing a sailor’s outfit and dancing for Navymen",
      "teaching amputees about diversity",
      "repainting my local church",
      "supporting my local business",
      "eating at a local hot spot",
      "getting my 4th vaccine",
      "pondering my philosophy books",
      "admiring my library of classic literature",
      "telling everyone that they are beautiful no matter what shape their head is"
    ]
    |> Enum.random()
  end

  def surprising_aggressor() do
    [
      "a nun",
      "a raccoon ",
      "a middle schooler",
      "a girl scout",
      "a boy scout",
      "a rabid bird of some kind",
      "a snotty little fellow by the name of ‘Davey’",
      "a stinky rat",
      "a WeWork development intern",
      "a youth pastor",
      "a very small boy",
      "a mysterious nomad",
      "a wandering minstrel ",
      "a savvy IT guy",
      "a wise old dancer",
      "a streetsmart pickpocket",
      "a prostitute with a heart of gold",
      "a tiny dancer",
      "a very large dancer",
      "a Navyman",
      "a reputable local jacuzzi salesman",
      "an impish bridge troll",
      "a horde of small mangrove crabs",
      "an oilman ",
      "three small children in a trenchcoat",
      "two tricky garbage foxes ",
      "a man with teeny tiny hands",
      "a dental hygienist ",
      "a dentist",
      "a doctor",
      "my friend, Zander",
      "my friend, Grolf",
      "my friend, Marcus",
      "Billie Eilish’s manager",
      "Mr. Potatohead from the beloved Toy Story franchise",
      "a CEO",
      "a CFO",
      "a CMO",
      "a horde of ravenous digital marketers",
      "two recently engaged lovebirds",
      "a kind old man",
      "two old drunkards",
      "a 35 year old suburban mom consumed by a white wine rage",
      "ny state representative",
      "ny local congressperson",
      "a struggling actor",
      "a pack of wild interns",
      "HR",
      "a toaster that was made conscious by a kind wizard’s spell",
      "a hard-boiled private detective"
    ]
    |> Enum.random()
  end

  def crime() do
    [
      "Jack my shit",
      "Shank me good",
      "Creep up on me and slapped the back of my head",
      "Copy my social media post and posted it without crediting me",
      "Invite me to 10 meetings in a single week",
      "Seize my arm and verbally berated me for hours",
      "Steal all of my fresh produce and grain",
      "Drop kick me into a wall",
      "Tickle me senseless",
      "Unqualify all my leads",
      "Drop all my tables",
      "Deoptimize every single funnel I had",
      "Completely hack me",
      "Steal my new billfold",
      "Demolish me in every imaginable way",
      "Commit a string of arsons across the country",
      "Challenge all my beliefs",
      "Evade all my taxes for me",
      "Smother me in my sleep",
      "Lock me up",
      "Register me as an accredited 501(c)3",
      "Convert me to the episcopalian church",
      "Shanghai me on his ship",
      "Sacrificed me so that they may enjoy a bountiful harvest come spring",
      "Reported me",
      "Undermine my leadership",
      "Managed to successfully vote me of the board of directors",
      "Managed to defeat me in a proxy battle",
      "Fill my pockets with coleslaw",
      "Debrief me by removing my briefs",
      "Karate chop my solar plexus",
      "Steal my teeth",
      "Bungle all my job interviews for the last 6 years",
      "Floss my teeth but in a really poor fashion",
      "Drop a piano on my head",
      "Attack me with a piece of rusty old rebar",
      "Chop off my head",
      "Chop off my whole body",
      "Set me on fire—metaphorically and literally",
      "Crunch all my fingers in their mouth",
      "Pierce me with their pointy teeth",
      "Give me rabies with a single bite",
      "Douse me in toxic mystery liquids"
    ]
    |> Enum.random()
    |> String.downcase()
  end

  def adjective() do
    [
      "Thirsty",
      "Confused",
      "goopy",
      "Sweaty",
      "Upset",
      "Unhappy",
      "Out of sorts",
      "Demoralized",
      "Ashamed",
      "Troubled",
      "Impoverished",
      "Tired",
      "Sleepy",
      "Disquieted",
      "Disturbed",
      "Distressed",
      "Stressed",
      "Exhausted",
      "Covered in metaphorical spikes",
      "Lumpy and aggressive",
      "Angry",
      "Bewildered",
      "Unoptimized",
      "Mismanaged",
      "Corpulent",
      "Boring",
      "vapid ",
      "Clingy",
      "Covered in a metaphorical soup of my own design",
      "Frustrated with the tangled webs that we weave",
      "Greasy",
      "Damp",
      "Ticklish "
    ]
    |> Enum.random()
    |> String.downcase()
  end

  def reasonable_response() do
    [
      "go to the hospital",
      "ask anyone for help",
      "clean myself off",
      "bandage up my wounds",
      "cry except a little",
      "shriek with terror",
      "call the authorities for assistance",
      "try to stop the whole ordeal",
      "clean up afterwards",
      "stop working",
      "cry",
      "post about it on social media as a desperate bid for attention, and with the hopes that some turbulent experience will grant me clout as a “thought leader.” Not even once",
      "eat my vegetables",
      "retaliate",
      "kick ‘em in the face for revenge",
      "stop spreadsheeting while it happened",
      "pause checking my email while it happened",
      "ask my pediatrician for help",
      "keel over in agony like a lesser human would",
      "look up at the cloudy skies and cry out, “Why, God? Why hast thou forsaken me?”",
      "fight back. Though I could have—you see, I’m a black belt in Krav Maga and in my spare time I teach it to children who don’t have teeth for free. Krav Maga isn’t about attacking, it’s about self-defense. But sometimes, self-defense is about attacking, so naturally, I didn’t fight back like I said earlier. I definitely know Krav Maga please stop asking for demonstrations I can’t right now because I'm BUSY"
    ]
    |> Enum.random()
  end

  def business_question() do
    [
      "“How do you reach new prospects?”",
      "“What is your product’s main value prop?”",
      "“How do you engage your employees?”",
      "“What are your core brand values?”",
      "“How do have you maintained a healthy funnel?”",
      "“Do you have well-managed revenue streams?”",
      "“Your Workforce—are they optimized?”",
      "“Have you employed any digital solutions to improve your labor allocation? I’d love to chat for ten minutes.”",
      "“Do you ever have trouble with your subordinates talking out of turn during meetings?”",
      "“Will you let me tickle your revenue streams? I can promise major growth.”",
      "“When was the last time you were hugged?”",
      "“How tall are you?”",
      "“How blue is the sky? It is as blue as your business is filled with potential, but serious flaws in brand identity.”",
      "“Sure, you may be able to defeat me—but can you defeat your own business challenges?”",
      "“Who is your Chief Revenue Officer? Has your C-Suite been fully integrated with the cloud?”",
      "“Where is the cloud?”",
      "“Do you have actionable insights to make data-driven decisions?”",
      "“Are you tired of manual processes slowing down your sales process?”"
    ]
    |> Enum.random()
  end

  def modern_business_practice() do
    [
      "Update my compliance documents",
      "File with the SEC",
      "Optimize workflows",
      "Build a small business",
      "Increase inbound leads by 10x",
      "Decrease revenue leakage by 50%",
      "Intimidate pigeons so that they will be my interns",
      "Network. ",
      "Intimidate my peers",
      "Make interns cry",
      "Go to the bathroom all by myself",
      "Be a big business boss",
      "Swim",
      "Collate my rolodex",
      "Take a business spanking and turn it into revenue",
      "Marketing",
      "Be a thought leader",
      "Make my dreams into realities by dreaming of very, very small and attainable goals—like working at a certain company that makes software",
      "Clip not just my nails, but the nails of every client and prospect nearby",
      "Sleep upside down like a bat",
      "Tie my shoes (metaphorically)",
      "Challenge my peers to become better workers. To dare them into greatness. To show them that marketing isn’t just about selling a product—it’s also about upselling additional features to existing clients",
      "Make a go-to market plan",
      "Standardize internal messaging practices so everyone talks good at eachother for the company make good work ok",
      "Be a lawyer",
      "Braid hair",
      "Make pickles at home really easily",
      "Cook",
      "Sing",
      "Dance",
      "Dance the dance of business",
      "Scale a business internationally",
      "Motivate my engineering team with branded webcam covers. ",
      "Offset the mental effects of frequent 60 hour work weeks by offering employees free access to an app where a white guy talks to you about meditation for 30 minutes"
    ]
    |> Enum.random()
    |> String.downcase()
  end

  def stupid_response() do
    [
      "Look inward, and outward, simultaneously",
      "To spit in the eyes of god",
      "Melt",
      "Milk your business hows until you have enough business calcium",
      "Tie up your boots and get to work",
      "Be strong",
      "Be courageous and bold and brave",
      "Slap that adversity in the face and say “not today, scum. I’m a businessperson and I’m tough.”",
      "Diversity",
      "Make that adversity into strength",
      "Use your cunning to outsmart it",
      "Redirect its negative energies using your extensive Krav Maga training",
      "Curl up into a ball and play dead",
      "Immediately defecate in your own pants and make yourself appear as tall as possible by holding your hands up straight. That ought to scare it off",
      "Clap loudly and yell “AHHHHHH” for as long as possible",
      "Stay positive. We’ve all been there, and you will get through this adversity. It’s as simple as staying positive. We’ve all been there, and you will get through this adversity as long as you stay positive and remember, we’ve all been there",
      "Clench your jaw and really just push it out",
      "Shave your chest and wrestle",
      "Oil up and slide around in the grand halls of business. That’ll make it tougher for the adversity to actually catch you and hold on",
      "Smile more",
      "Think happy thoughts",
      "Overcome it",
      "Lasso it and hogtie it",
      "Throw a saddle on that bad boy and BAM—giddy up adversity! All aboard the adversity express!",
      "Move to Brooklyn probably. And talk about how nice it is having trees on your street. And say “it’s so peaceful” a lot"
    ]
    |> Enum.random()
  end

  def present_title() do
    [
      "Assistant Manager at the Arby’s off I-95",
      "a juice artist at a Jamba Juice",
      "CEO of Apple",
      "one of Forbes’ 10,000 under 10,000",
      "a brand invigorator. A storyteller. A single mother. A veteran. And above all else, a marketer",
      "an Entrepreneur with over 7 business ideas to my name",
      "some sort of demi-god",
      "severely in debt",
      "paying off student loans for the foreseeable future",
      "in debt",
      "suffering from minor tinnitus",
      "thrilled to announce that I’ll be joining Doyle, Fulham, and Westerberg LLC as a junior associate",
      "tired all the time",
      "a junior copywriter and i get to write for brands that I know! That’s fun and makes it cool! You know Charmin toilet paper? I’ve written two of their Tweets. ",
      "lost in the Google basement, please send help. It’s very dark and people keep offering me two massages per quarter",
      "living under a bridge in San Francisco",
      "the proud owner of two separate Instagram accounts",
      "helping business owners achieve their goals",
      "Head Coder at codetech.io",
      "a train engineer",
      "a DJ",
      "a podcaster.",
      "CEO of my own company that I invented",
      "Jamba Juice. Forever. Jamba Juice is eternal. It will witness the death of the wind, the mountains as they retreat into the seas",
      "a member of the AMA Marketing Hall of Fame",
      "a proud viewer of every Super Bowl ad",
      "a vegan",
      "a vegetarian",
      "a pescetarian",
      "exclusively carnivorous—like Joe Rogan, my hero",
      "on an exclusive deal with Clubhouse where I go on there and talk for awhile",
      "a doctor",
      "an oil baron",
      "a rollercoaster tycoon",
      "Warren Buffet",
      "Richard Branson’s right-hand man",
      "Elon Musk and Grimes’ baby",
      "named Kevin",
      "significantly taller than I was as a child"
    ]
    |> Enum.random()
  end

  def hashtags() do
    [
      "#Adversity #Diversity #University",
      "#Blessed ",
      "#AccentureGlobal",
      "#NASDAQ",
      "#OracleTop100",
      "#MarketingHacks #MarketingWizard #WhizzingOnMarketers",
      "#GrundlePlay",
      "#Bonds #Debt #SalesManagement #BDSM",
      "#ThoughtLeadership #BusinessHacks #ConsensualChoking",
      "#KPI #WAP",
      "#TeachYourChildren #LessonsForLife #JamOutWithJamba",
      "#JambaForever",
      "#Business #DairyFree",
      "#LikeForLike",
      "#LickForLick",
      "#VenmoMe",
      "#Hashtag",
      "#AgeismInTheWorkplace",
      "#MillenialTrends #GenZ #Lit ",
      "#VeganRecipes #ChickpeaFlour",
      "#StopTheCount",
      "#ConstitutionalRights #RightToBareArms",
      "#BigStrongFiremen",
      "#GreasedUpAndReadyToGo",
      "#NoMorePediatricians",
      "#5G #Unsafe #KillsBirds",
      "#Vaccines #DontTrustThem",
      "#DoYourResearch",
      "#Patriot #RedWhiteBlue",
      "#PleaseHelpMe",
      "#Grinding #HaveNotSeenKidsInThreeMonths",
      "#Grinding #TwoBusinesspeopleGrinding",
      "#FreeMoney #MLM #Ponzi",
      "#GreedIsGood",
      "#NFT #Crypto #Blockchain",
      "#Sustainability #GoGreen #Reduce #Reuse #Recycle #ReststopBathroom #5Minutes #MeetMeThere",
      "#Brave #IAmBrave #Bravery #Courage",
      "#SpicyTakes #Memes",
      "#TacoBell"
    ]
    |> Enum.random()
  end
end
