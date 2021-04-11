(import
  random
  discord
  [discord.ext [commands]]
  [bot.utils [create-embed get-guild-prefix]]
  [bot.database.models [Raid]]
  [bot.utils.helpers [chunk get-create-user update-xp]]
  [disputils [BotEmbedPaginator]])


(defclass Raids [commands.Cog]
  #[[:video_game:]]
  (defn __init__ [self bot]
    (setv self.bot bot))
  #@((.command commands)
      (defn/a raids [self ctx]
        #[[*Look at available raids.*

        **Usage**: `{prefix}raids`
        **Example**: `{prefix}raids`]]
        (setv raids (lfor raid (.values self.bot.raid-data) (if (= raid.guild-id ctx.guild.id) raid)))
        (if (= (len raids) 0)
          (do
            (await (.send ctx "There are currently no raids running. You should start one!"))
            (return)))
        (setv raid-list [])
        (try
          (for [chunked (chunk raids 5)]
            (.append raid-list
              (lfor raid chunked f"\n\n**-** {(if raid.gmax ('Gmax') (''))} {(if raid.shiny ('Shiny') (''))} {(.capitalize raid.pokemon)}")))
          (except [e [Exception]]
            (print e)
            (await (.send ctx "An error has occurred."))
            (return)))
        (if (> (len raids) 0)
          (do
            (setv description [])
            (for [page raid-list]
              (setv de-string "")
              (for [item page]
                (setv de-string (+ de-string item)))
              (.append description de-string))
            (setv embed (lfor page description (.Embed discord :description (+ "**Current Raids:**" page) :color (.purple discord.Colour))))
            (setv paginator (BotEmbedPaginator ctx embeds))
            (await (.run paginator)))
          (await (.send ctx "No raids are running.")))))
  #@((.command commands)
      (defn/a queue [self ctx &rest ^str pokemon]
        #[[*Look up a raid's queue*

        `pokemon` is the name of the Pokemon raid you want to view.
        **Usage**: `{prefix}queue pokemon`
        **Example**: `{prefix}queue Pikachu`]]
        (await (.wait-until-ready self.bot))
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower pokemon)) (= raid.guild-id ctx.guild.id))
            (do
              (setv raid raid)
              (break))
            (setv raid None)))
        (if-not raid
          (do
            (await (.send ctx "There is no raid running with that Pokemon, or you did not specify a Pokemon, try using this command again."))
            (return)))
        (setv users (lfor user (.values self.bot.queue-data) (if (and (= (get user "guild-id") ctx.guild.id) (= (get user "raid-id") raid.id)) user)))
        (if (> (len users) 0)
          (do
            (setv description [])
            (setv raid-pokemon "")
            (if raid.gmax
              (setv raid-pokemon (+ raid-pokemon "Gmax ")))
            (if raid.shiny
              (setv raid-pokemon (+ raid-pokemon "Shiny ")))
<<<<<<< HEAD
            (setv raid-pokemon (+ raid-pokemon (.capitalize raid.pokemon))))
          (await (.send ctx "There is no raid running with that Pokemon, or you did not specify a Pokemon, try using this command again."))
          (try
            (setv user-list (lfor chunked (chunk users 5) (lfor user chunked f"**-** <@{(get user 'user_id')}>\n")))
            (except [e [Exception]]
              (print e)
              (await (.send ctx "An error has occurred."))
              (return)))
          (for [page user-list]
            (setv de-string "")
            (for [item page]
              (setv de-string (+ de-string item)))
            (.append description de-string))
          (setv embeds
                (lfor page description (.Embed discord
                                               :title "Raid Queue"
                                               :description (+ f"**Current Pokemon:** {raid-pokemon}\n\nCurrent Queue:\n" page)
                                               :color (.purple discord.Colour))))
          (try
            (for [embed embeds]
              (.set-thumbnail embed :url (get self.bot.pokemon-images (.lower pokemon))))
            (except [e [Exception]]
              (print e)
              (await (.send ctx "An image for this pokemon cannot be found... contact the dev regarding this issue."))
              (return)))
          (setv paginator (BotEmbedPaginator ctx embeds))
          (await (.run paginator)))
        ))
  #@((.command commands)
      (defn/a join [self ctx &rest ^str raid-pokemon]
        #[[*Join an existing Pokemon raid.*
=======
            (setv raid-pokemon (+ raid-pokemon (.capitalize raid.pokemon)))
            (await (.send ctx "There is no raid running with that Pokemon, or you did not specify a Pokemon, try using this command again."))
            (try
              (setv user-list (lfor chunked (chunk users 5) (lfor user chunked f"**-** <@{get user 'user_id'}>\n")))
              (except [e [Exception]]
                (print e)
                (await (.send ctx "An error has occurred."))
                (return)))
            (for [page user-list]
              (setv de-string "")
              (for [item page]
                (setv de-string (+ de-string item)))
              (.append description de-string))
            (setv embeds (lfor page description (.Embed discord
              :title "Raid Queue"
              :description (+ "**Current Pokemon:** {raid-pokemon}\n\nCurrent Queue:\n" page
              :color (.purple discord.Colour)))))
            (try
              (for [embed embeds]
                (.set-thumbnail embed :url (get self.bot.pokemon_images (.lower pokemon))))
              (except [e [Exception]]
                (print e)
                (await (.send ctx "An image for this pokemon cannot be found... contact the dev regarding this issue."))
                (return)))
            (setv paginator (BotEmbedPaginator ctx embeds))
            (await (.run paginator)))
          (await (.send ctx "There is no raid running with that Pokemon, or you did not specify a Pokemon, try using this command again.")))))
  #@((.command commands)
      (defn/a join [self ctx &rest ^str raid-pokemon]
        #[[*Join an existing Pokemon raid.*

        `[pokemon]` is the Pokemon raid you want to join
        **Usage**: `{prefix}join [pokemon]`
        **Example**: `{prefix}join Pikachu`]]
        (setv raid-pokemon (.join " " raid-pokemon))
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower raid-pokemon)) (= raid.guild-id ctx.guild.id))
            (do
              (setv raid raid)
              (break))
            (setv raid None)))
        (if raid
          (do
            (setv host-id raid.host-id)
            (setv queue (lfor user (.values self.bot.queue-data) (if (and (= (get user "raid-id") raid.id) (= (get user "guild-id") ctx.guild.id)) user)))
            (if (= (len queue) 0)
              (do
                (await (.send ctx "No raid is running for this pokemon."))
                (.pop self.bot.raid-data raid.id None)
                (await (.delete raid))
                (return)))
            (if-not (in ctx.message.author queue)
              (do
                (setv (get self.bot.queue-data f"{raid.id}+{ctx.message.author.id}") {"raid-id" raid.id  "user-id" ctx.message.author.id  "guild-id" ctx.guild.id})
                (setv host (await (get-create-user host-id)))
                (if (>= (len queue) 4)
                  (await (update-xp :user host :modifier 0.2))
                  (await (update-xp :user host :modifier 0)))
                (setv participant (await (get-create-user ctx.message.author.id)))
                (await (update-xp :user participant :modifer 0))
                (await (.send ctx f"Added to queue for the {(.capitalize raid.pokemon)} raid!")))
              (do
                (await (.send ctx "You are already in the queue for this raid."))
                (return))))
          (do
            (await (.send ctx "No raid is running for this pokemon."))
            (return)))))
  #@((.command commands)
      (defn/a leave [self ctx &rest ^str raid-pokemon]
        #[[*Leave a raid you are in.*

        `[pokemon]` is the Pokemon raid you want to leave
        **Usage**: `{prefix}leave [pokemon]`
        **Example**: `{prefix}leave Pikachu`]]
        (setv raid-pokemon (.join " " raid-pokemon))
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower raid-pokemon)) (= raid.guild-id ctx.guild.id))
              (do
                (setv raid raid)
                (break))
              (setv raid None)))
        (if raid
            (do
              (setv queue (lfor user (.values self.bot.queue-data) (if (and (= (get user "raid-id") raid.id) (= (get user "guild-id") ctx.guild.id)) (get user "user-id"))))
              (if (= ctx.message.author.id raid.host-id)
                  (do
                    (await (.send ctx "You cannot leave your own raid. Please close it if you are done hosting."))
                    (return))))
            (do
              (await (.send ctx "No such raid."))
              (return))))))

            elif ctx.message.author.id not in queue:
                await ctx.send("You are not in the queue for this raid.")
                return
            else:
                await ctx.send(
                    f"Removed from the queue for the {raid.pokemon.capitalize()} raid!"
                )
                self.bot.queue_data.pop(f"{raid.id}+{ctx.message.author.id}", None)
                return

    @commands.command()
    async def host(self, ctx, gmax: str, shiny: str, *, pokemon_name: str):
        """*Host your own Pokemon raid.*

        `[pokemon]` is the Pokemon you want to host
        `[gmax]` is a y or n and is whether or not your Pokemon is gmax
        `[shiny]` is a y or n and is whether or not your Pokemon is shiny
        **Usage**: `{prefix}host [gmax] [shiny] [pokemon]`
        **Example**: `{prefix}host y y Pikachu`
        """
        raid = None
        for raid_id, raid in self.bot.raid_data.items():
            if raid.host_id == ctx.message.author.id and raid.guild_id == ctx.guild.id:
                await ctx.send(
                    "You cannot host multiple raids at once. Please close your existing one."
                )
                return
            if raid.pokemon == pokemon_name.lower() and raid.guild_id == ctx.guild.id:
                raid = raid
                break
            else:
                raid = None
        if raid:
            await ctx.send(
                "A raid for this pokemon is already running in this server. Consider joining it!"
            )
            return

        pokemon_name = pokemon_name.lower()

        if shiny == "y" or shiny == "n":
            shiny = True if shiny == "y" else False

        if gmax == "y" or gmax == "n":
            gmax = True if gmax == "y" else False

        if type(gmax) != bool or type(shiny) != bool:
            await ctx.send(
                "Please say 'y' or 'n' for gmax and shiny. Try running the command again."
            )
            return

        if pokemon_name not in self.bot.pokemon_images.keys():
            await ctx.send(
                "This is not a valid Pokemon name, or it has been misspelled. "
                "Try running this command again."
            )
            return

        raid = await Raid.create(
            guild_id=ctx.guild.id,
            pokemon=pokemon_name,
            shiny=shiny,
            gmax=gmax,
            host_id=ctx.message.author.id,
        )

        self.bot.raid_data[raid.id] = raid

        self.bot.queue_data[f"{raid.id}+{ctx.message.author.id}"] = {
            "raid_id": raid.id,
            "user_id": ctx.message.author.id,
            "guild_id": ctx.guild.id,
        }

        user = await get_create_user(ctx.message.author.id)
        await user.update(times_hosted=user.times_hosted + 1).apply()

        await ctx.send(
            "Raid started, you have been automatically added to the queue, and you can check on the current "
            "raid using the queue command."
            " Invite your friends to join!"
        )

        await ctx.send(
            "**TIP:** In order to get XP, get 3 or more people to be in the queue!"
        )

    @commands.command()
    async def close(self, ctx, pokemon_name: str):
        """*Close a raid you started.*

        `[pokemon]` is the Pokemon raid you want to close
        **Usage**: `{prefix}close [pokemon]`
        **Example**: `{prefix}close Pikachu`
        """
        raid = None
        for raid_id, raid in self.bot.raid_data.items():
            if raid.pokemon == pokemon_name.lower() and raid.guild_id == ctx.guild.id:
                raid = raid
                break
            else:
                raid = None

        if not raid:
            await ctx.send(
                "This raid cannot be found. Please type in a valid Pokemon name."
            )
            return
>>>>>>> 394b9b4ad1ea4ad3a06fe1e8567e843ec1d718bd

        `pokemon` is the Pokemon raid you want to join
        **Usage**: `{prefix}join pokemon`
        **Example**: `{prefix}join Pikachu`]]
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower raid-pokemon)) (= raid.guild-id ctx.guild.id))
              (do
                (setv raid raid)
                (break))
              (setv raid None)))
        (if raid
            (do
              (setv host-id raid.host-id)
              (setv queue (lfor user (.values self.bot.queue-data) (if (and (= (get user "guild-id") (ctx.guild.id)) (= (get user "raid-id") (raid.id))) (user))))
              (if (= (len queue) 0)
                  (do
                    (await (.send ctx "No raid is running for this pokemon."))
                    (.pop self.bot.raid-data raid.id None)
                    (await (.delete raid))
                    (return)))
              (if-not (.contains queue ctx.message.author)
                      (do
                        (setv (get self.bot.queue-data f"{raid.id}+{ctx.message.author.id}") {"raid-id" raid.id  "user-id" ctx.message.author.id  "guild-id" ctx.guild.id})
                        (setv host (await (get-create-user host-id)))
                        (if (>= (len queue) 4)
                            (await (update-xp :user host :modifier 0.2))
                            (await (update-xp :user host :modifier 0)))
                        (setv participant (await (get-create-user ctx.message.author.id)))
                        (await (update-xp :user participant :modifier 0))
                        (await (.send ctx "Added to queue for the {(.capitalize raid.pokemon)} raid!")))
                      (do
                        (await (.send ctx "You are already in the queue for this raid."))
                        (return))))
            (do
              (await (.send ctx "No raid is running for this pokemon."))
              (return)))))
  #@((.command commands)
      (defn/a leave [self ctx &rest ^str raid-pokemon]
        #[[*Leave a raid you are in.*

        `pokemon` is the Pokemon raid you want to leave
        **Usage**: `{prefix}leave pokemon`
        **Example**: `{prefix}leave Pikachu`]]
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower raid-pokemon)) (= raid.guild-id ctx.guild.id))
              (do
                (setv raid raid)
                (break))
              (setv raid None)))
        (if raid
            (do
              (setv queue (lfor user (.values self.bot.queue-data) (if (and (= (get user "guild-id") (ctx.guild.id)) (= (get user "raid-id") (raid.id))) (user))))
              (if (= ctx.message.author.id raid.host-id)
                  (do
                    (await (.send ctx "You cannot leave your own raid. Please close it if you are done hosting."))
                    (return))
                  (not (.contains queue ctx.message.author.id))
                  (do
                    (await (.send ctx "You are not in the queue for this raid."))
                    (return))
                  (do
                    (await (.send ctx f"Removed from the queue for the {(.capitalize raid.pokemon)} raid!"))
                    (.pop self.bot.queue-data f"{raid.id}+{ctx.message.author.id}" None)
                    (return))))
            (do
              (await (.send ctx "No such raid."))
              (return)))))
  #@((.command commands)
      (defn/a host [self ctx ^str gmax ^str shiny &rest ^str pokemon-name]
        #[[*Host your own Pokemon raid.*

        `pokemon` is the Pokemon you want to host
        `gmax` is a y or n and is whether or not your Pokemon is gmax
        `shiny` is a y or n and is whether or not your Pokemon is shiny
        **Usage**: `{prefix}host gmax shiny pokemon`
        **Example**: `{prefix}host y y Pikachu`]]
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.host-id ctx.message.author.id) (= raid.guild-id ctx.guild.id))
              (do
                (await (.send ctx "You cannot host multiple raids at once. Please close your existing one."))
                (return)))
          (if (and (= raid.pokemon (.lower pokemon-name)) (= raid.guild-id ctx.guild.id))
              (do
                (setv raid raid)
                (break))
              (setv raid None)))
        (if raid
            (do
              (await (.send ctx "A raid for this pokemon is already running in this server. Consider joining it!"))
              (return)))
        (setv pokemon-name (.lower pokemon-name))
        (if (or (= shiny "y") (= shiny "n"))
            (if (= shiny "y") (setv shiny True) (setv shiny False)))
        (if (or (= gmax "y") (= gmax "n"))
            (if (= gmax "y") (setv gmax True) (setv gmax False)))
        (if (or (not (isinstance gmax bool)) (not (isinstance shiny bool)))
            (do
              (await (.send ctx "Please say 'y' or 'n' for gmax and shiny. Try running the command again."))
              (return)))
        (if (not (.contains (.keys self.bot.pokemon-images) pokemon-name))
            (do
              (await (.send ctx
                (+ "This is not a valid Pokemon name, or it has been misspelled. "
                   "Try running this command again.")))
              (return)))
        (setv raid (.create Raid
                            :guild-id ctx.guild.id
                            :pokemon pokemon-name
                            :shiny shiny
                            :gmax gmax
                            :host-id ctx.message.author.id))
        (setv (get self.bot.raid-data raid.id) raid)
        (setv (get self.bot.queue-data f"{raid.id}+{ctx.message.author.id}") {"raid-id" raid.id  "user-id" ctx.message.author.id  "guild-id" ctx.guild.id})
        (setv user (await (get-create-user ctx.message.author.id)))
        (await (.apply (.update user :times-hosted (+ user.times-hosted 1))))
        (await (.send ctx
                      (+
                        "Raid started, you have been automatically added to the queue, and you can check on the current "
                        "raid using the queue command."
                        " Invite your friends to join!")))
        (await (.send ctx "**TIP:** In order to get XP, get 3 or more people to be in the queue!"))))
  #@((.command commands)
      (defn/a close [self ctx &rest ^str pokemon-name]
        #[[*Close a raid you started.*

        `pokemon` is the Pokemon raid you want to close
        **Usage**: `{prefix}close pokemon`
        **Example**: `{prefix}close Pikachu`]]
        (setv raid None)
        (for [[raid-id raid] (.items self.bot.raid-data)]
          (if (and (= raid.pokemon (.lower pokemon-name)) (= raid.guild-id ctx.guild.id))
              (do
                (setv raid raid)
                (break))
              (setv raid None)))
        (if-not raid
                (do
                  (await (.send ctx "This raid cannot be found. Please type in a valid Pokemon name."))
                  (return)))
        (if (and (!= raid.host-id ctx.message.author.id) (not ctx.message.author.guild-permissions.administrator))
            (do
              (await (.send ctx "You did not host this raid, and are not an admin. Please get someone else to close it."))
              (return)))
        (try
          (for [[queue-id queue] (.items self.bot.queue-data)]
            (if (= (get queue "raid-id") raid.id)
                (.pop self.bot.raid-data queue-id None)))
          (await (.delete raid))
          (.pop self.bot.raid-data raid.id None)
          (except [e Exception]
            (print e)
            (return)))
        (await (.send ctx "Raid has been closed, and the queue has been purged!")))))

<<<<<<< HEAD

=======
>>>>>>> 394b9b4ad1ea4ad3a06fe1e8567e843ec1d718bd
(defn setup [bot]
  (.add-cog bot (Raids bot)))
