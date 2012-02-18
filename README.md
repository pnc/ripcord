Never wonder what's running on your servers again.

# Ripcord

After you (or a colleague) has deployed to Heroku, it can be tricky to tell what version (branch, commit, or what-have-you) of your app is running. Ripcord tells you, so you'll never have to ask again.

![Ripcord running in the wild](ripcord/raw/master/web/banner.png)

## Setup

Setup is easy. You can run your own Ripcord on Heroku for free.

Clone it.

    git clone git://github.com/pnc/ripcord.git
    cd ripcord
    
Create a Heroku app. Call it whatever you want. Replace `i-love-carrots` in all of the following instructions with whatever you decide to name it.

    heroku apps:create --stack cedar i-love-carrots

Add MongoHQ's free version. (You'll need a verified Heroku account.)

    heroku addons:add mongohq:free --app i-love-carrots

Deploy this bad boy.

    git push heroku master

Tell all your other apps to phone home.

    cd ../your-production-app
    heroku addons:add deployhooks:http \
      url=http://i-love-carrots.herokuapp.com --app your-production-app

Then head over to `i-love-carrots.herokuapp.com`. After the first time you redeploy your production app, you'll have the option of associating a GitHub repository with the Heroku application. Click __add username/repository__ below your app name and fill it in with something like `pnc/ripcord`. Doing so will give you links to the commit diffs on GitHub and, when it can be determined, the remote branch that owns the commit.

## Private Repositories

If your GitHub repository is private, you'll need to do two more things.

First, [create an OAuth application on Git](https://github.com/account/applications/new).

Replace `i-love-carrots` below with the name of your Heroku app.

  - Application Name: Whatever you want
  - Main URL: `http://i-love-carrots.herokuapp.com`
  - Callback URL: `http://i-love-carrots.herokuapp.com/oauth`

Tell your Ripcord app about the Client ID and Client Secret you'll see displayed after you hit "Create Application":

    heroku config:add OAUTH_CLIENT_ID=id_from_github --app i-love-carrots
    heroku config:add OAUTH_CLIENT_SECRET=secret_from_github --app i-love-carrots

Then, go to your Ripcord app and use the Authorize GitHub Account button to give Ripcord access your private repo.