Never wonder what's running on your servers again.

# Ripcord

After you (or a colleague) has deployed to Heroku, it can be tricky to tell what version (branch, commit, or what-have-you) of your app is running. Ripcord tells you, so you'll never have to ask again.

![Ripcord running in the wild](ripcord/raw/master/web/banner.png)

## Setup

Setup is easy. You can run your own Ripcord on Heroku for free.

Clone it.

    git clone git://github.com/pnc/ripcord.git
    cd ripcord
    
Create a Heroku app.

    heroku apps:create --stack cedar i-love-carrots

Add MongoHQ's free version. (You'll need a verified Heroku account.)

    heroku addons:add mongohq:free --app i-love-carrots

Deploy this bad boy.

    git push heroku master

Tell all your other apps to phone home.

    heroku addons:add deployhooks:http \
      url=http://i-love-carrots.herokuapp.com --app your-production-app

Then head over to `i-love-carrots.herokuapp.com`. After the first time you redeploy your production app, you'll have the option of associating a GitHub repository with the Heroku application. Doing this will give you links to the commit diffs and, when it can be determined, the remote branch that owns the commit.

If your GitHub repository is private, use the Authorize GitHub Account button to allow Ripcord to access your private repo.