# Camptownladies

_A singing twitter bot._

Camptownladies does linguistic analysis in order to identify tweets matching the metrical rhythm of the first line of the traditional American minstrel song "[Camptown Races](http://en.wikipedia.org/wiki/Camptown_Races)", and respond appropriately: "doo-dah, doo-dah".

In its original install, camptownladies ran for over 2 years using the Twitter account [@camptownladies](http://twitter.com/camptownladies), evoking amusement, confusion, and sometimes inexplicable rage. Recently the account was flagged as spam and threatened with a ban, so I've taken it out of service.

## Configuration

1. Install prerequisites:

        perl -MCPAN -e 'install qw(Encode Net::Twitter Lingua::EN::Syllable Lingua::EN::Phoneme Text::Language::Guess);'

2. Create a Twitter account for your bot and sign in.

3. Register a new Twitter app at https://dev.twitter.com/apps/new.

4. Copy the consumer key and consumer secret into the appropriate variables in `bot.pl`, then create an OAuth access token and copy it and the access token secret in as well. 

## Execution

Each time camptownladies runs, it will pull in the latest 20 tweets from the public timeline via Twitter's API and analyze them. If any of them match the desired pattern, it will reply to that tweet. Since none of them are guaranteed to match, it may require a few runs before it replies.

You can add a cron task to periodically run `bot.pl`, e.g.

    # m h dom mon dow    command
      * * *   *   *      /home/username/camptownladies/bot.pl >>/tmp/camptownladies.log

## License

This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
